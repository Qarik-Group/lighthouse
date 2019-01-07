#!/usr/bin/env bash

. lib/bash.sh
. lib/curl.sh
. lib/output.sh


# make sure we have associative arrays and -v testing

need_bash_minimum_version 4 3 || {
    active "Quota Plans Testing"
    not_ok "Bash version is too old - Want: 4 3   Got: ${BASH_VERSINFO[0]} ${BASH_VERSINFO[1]} ${BASH_VERSINFO[2]}"
    exit 1
}

quotas_dataset="quota_$$"
validation_data="rules/cf/quotas.json"

lh_result="true"

declare -A quota_map
quota_map["allow_paid_service_plans"]="non_basic_services_allowed"
quota_map["service_instances"]="total_services"
quota_map["routes"]="total_routes"
quota_map["private_domains"]="total_private_domains"
quota_map["total_memory"]="memory_limit"
quota_map["instance_memory"]="instance_memory_limit"
quota_map["app_instances"]="app_instance_limit"
quota_map["app_tasks"]="app_task_limit"
quota_map["service_keys"]="total_service_keys"
quota_map["reserved_route_ports"]="total_reserved_route_ports"

# echo "${!quota_map[@]}"

fab_validate_data()
{
    jq '[(type=="array",length > 0),
        (.[]|(type=="object"),(keys - [ "allow_paid_service_plans", "app_instances", "app_tasks",
                                        "instance_memory", "private_domains", "quota_name", "reserved_route_ports",
                                        "routes", "service_instances", "service_keys", "total_memory" ]|length == 0),
            (.quota_name|(type == "string",length>0)),
            (if has("allow_paid_service_plans") then 
                (.allow_paid_service_plans|(.value|type=="boolean"))
             else true end),
            (if has("app_instances") then 
                (.app_instances|((.operator|(type=="string",
                                      (length>0 and length<=2),
                                      ([contains("==",">=","<=",">","<","!=")]|any)))),
                (.value|(type=="number",.>=-1)))
             else true end),
            (if has("instance_memory") then 
                (.instance_memory|((.operator|(type=="string",
                                        (length>0 and length<=2),
                                        ([contains("==",">=","<=",">","<","!=")]|any)))),
                (.value|(type=="number",.>=-1)))
             else true end),
            (if has("reserved_route_ports") then 
                (.reserved_route_ports|((.operator|(type=="string",
                                             (length>0 and length<=2),
                                             ([contains("==",">=","<=",">","<","!=")]|any)))),
                (.value|(type=="number",.>=-1)))
             else true end),
            (if has("routes") then 
                (.routes|((.operator|(type=="string",
                               (length>0 and length<=2),
                               ([contains("==",">=","<=",">","<","!=")]|any)))),
                (.value|(type=="number",.>=-1)))
             else true end),
            (if has("service_instances") then 
                (.service_instances|((.operator|(type=="string",
                                          (length>0 and length<=2),
                                          ([contains("==",">=","<=",">","<","!=")]|any)))),
                (.value|(type=="number",.>=-1)))
             else true end),
            (if has("total_memory") then 
                (.total_memory|((.operator|(type=="string",
                                     (length>0 and length<=2),
                                     ([contains("==",">=","<=",">","<","!=")]|any)))),
                (.value|(type=="number",.>=-1)))
             else true end)
            )]|all' ${validation_data}
}

fab_validate_description()
{
    echo "Expecting an array of quota objects." 
}

get_org_quota_plans()
{
    query_cf_api '/v2/quota_definitions' "${quotas_dataset}"
}

has_any_quota_plans()
{
    jq '.|(type=="array" and length>0)' "/tmp/lh/${quotas_dataset}"
}

does_quota_plan_exist()
{
    declare plan="${1:?Missing quota plan argument   $(caller 0)}"
    jq --arg plan "${plan}" -r '.[].entity|select(.name==$plan)|.name==$plan' "/tmp/lh/${quotas_dataset}"
}

get_quota_value()
{
    declare plan="${1:?Missing quota plan argument   $(caller 0)}"
    declare quota="${2:?Missing quota argument   $(caller 0)}"
    quota=${quota_map[${quota}]}
    jq --arg plan "${plan}" --arg quota "${quota}" -r '.[].entity|select(.name==$plan)|.[$quota]' "/tmp/lh/${quotas_dataset}"
}

get_test_array_length()
{
    jq -r '.|arrays|length' "${validation_data}"
}

get_test_quota_name()
{
    declare idx="${1:?Missing test index argument   $(caller 0)}"
    jq --arg i ${idx} -r '.[$i|tonumber]|.quota_name|@sh' ${validation_data}
}

get_test_quota()
{
    declare idx="${1:?Missing test index argument   $(caller 0)}"
    declare quota_set="${2:?Missing quota set argument   $(caller 0)}"
    declare quota="${3:?Missing quota argument   $(caller 0)}"
    jq --arg i "${idx}" --arg qs "${quota_set}" --arg q "${quota}" -r '.[$i|tonumber]|select(.quota_name==$qs)|.[$q]|(.operator//"",.value//"")|@sh' ${validation_data}
}

get_test_quota_list()
{
    declare idx="${1:?Missing test index argument   $(caller 0)}"
    declare quota_set="${2:?Missing quota set argument   $(caller 0)}"
    jq --arg i "${idx}" --arg qs "${quota_set}" -r '.[$i|tonumber]|select(.quota_name==$qs)|(keys-["quota_name"])|.[]' ${validation_data}
}



fab_test()
{
    declare -i i tests
    declare name quota plan

    tests=$(get_test_array_length)
    get_org_quota_plans
    [[ $(has_any_quota_plans) != "true" ]] && {
        active "Quota Plans Testing "
        not_ok "No quota plans found"
        ((tests=0)) || true
        lh_result="false"
        return 0
    }

    for ((i=0; i < tests;i++))
    do
        declare -a "plan=($(get_test_quota_name ${i}))"

        # does quota plan exist

        [[ $(does_quota_plan_exist "${plan}") != "true" ]] && {
            active "Quota Plans Testing "
            not_ok "quota plan ${plan} does not exist"
            lh_result="false"
            continue
        }
        for quota in $(get_test_quota_list ${i} "${plan}")
        do
            declare -a "operation=($(get_test_quota ${i} "${plan}" "${quota}"))"
            declare -a "quota_value=($(get_quota_value "${plan}" "${quota}"))"
            active "Testing ${quota} in quota plan ${plan} "
            if [[ "${quota}" == "allow_paid_service_plans"  ]]
            then
                if [[ ${operation[1]} == ${quota_value} ]]
                then
                    ok
                else
                    not_ok "${operation[1]} != ${quota_value}"
                    lh_result="false"
                fi
            else
                # -1 represents the largest value, 
                # so negate test when -1 and positive integers are compared with with < or > for first approximation

                declare negate=""

                if  [[ ${operation[0]} =~ ^[\<\>] ]] &&
                    (((${quota_value} == -1 && ${operation[1]} > -1) || (${quota_value} > -1 && ${operation[1]} == -1) )) 
                then
                    negate='!'
                fi

                if ((${negate}(${quota_value} ${operation[0]} ${operation[1]}) ))
                then
                    ok 
                    info "${negate}(${quota_value} ${operation[0]} ${operation[1]})"
                else
                    not_ok "${negate}(${quota_value} ${operation[0]} ${operation[1]})"
                fi
            fi
                #*)
                    #echo unknown quota "${quota}"
                    #;;
        done
    done
    return 0
}

if [[ $(fab_validate_data) == "true" ]]
then
    fab_test
else
    active "Perform quota tests"
    not_ok  $(fab_validate_description)
    lh_result="false"
fi

rm -f /tmp/lh/${quotas_dataset}
[[ "${lh_result}" == "true" ]]
