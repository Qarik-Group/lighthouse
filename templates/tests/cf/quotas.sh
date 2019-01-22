#!/usr/bin/env bash

if [[ "" == "${LH_DIRECTORY}" ]] ; then
    echo "Please run this test through Lighthouse or set the LH_DIRECTORY and USE_ENV variables"
    exit 1
fi

. ${LH_DIRECTORY}/lib/bash.sh
. ${LH_DIRECTORY}/lib/curl.sh
. ${LH_DIRECTORY}/lib/output.sh

# make sure we have associative arrays and -v testing

need_bash_minimum_version 4 3 || {
    active "Quota Plans Testing"
    not_ok "Bash version is too old - Want: 4 3   Got: ${BASH_VERSINFO[0]} ${BASH_VERSINFO[1]} ${BASH_VERSINFO[2]}"
    exit 1
}

dataset="quota_$$"
base_validation_data="data/cf/quotas.json"

echo "Checking ${LH_DIRECTORY}/templates/${base_validation_data}"
validation_data="${LH_DIRECTORY}/templates/${base_validation_data}"

if [[ -e "${base_validation_data}" ]] ; 
then 
    echo "Found ./${base_validation_data}" 
    validation_data="${base_validation_data}"
fi

if [[ "" != "${USE_ENV}" ]] && [[ -e "${USE_ENV}/${base_validation_data}" ]] ;
then
    echo "Found and using ${USE_ENV}/${base_validation_data}"
    validation_data="${USE_ENV}/${base_validation_data}"
fi

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

lh_validate_data()
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

lh_validate_description()
{
    echo "Expecting an array of quota objects." 
}

get_org_quota_plans()
{
    query_cf_api '/v2/quota_definitions' "${dataset}"
}

has_any_quota_plans()
{
    jq '.|(type=="array" and length>0)' "/tmp/lh/${dataset}"
}

does_quota_plan_exist()
{
    declare plan="${1:?Missing quota plan argument   $(caller 0)}"
    jq --arg plan "${plan}" -r '.[].entity|select(.name==$plan)|.name==$plan' "/tmp/lh/${dataset}"
}

get_quota_value()
{
    declare plan="${1:?Missing quota plan argument   $(caller 0)}"
    declare quota="${2:?Missing quota argument   $(caller 0)}"
    quota=${quota_map[${quota}]}
    jq --arg plan "${plan}" --arg quota "${quota}" -r '.[].entity|select(.name==$plan)|.[$quota]' "/tmp/lh/${dataset}"
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

lh_test()
{
    declare -i i tests
    declare name quota plan

    tests=$(get_test_array_length)
    if ! get_org_quota_plans
    then
        active "Quota Plans Testing "
        not_ok $(query_get_error "/tmp/lh/${dataset}")
        lh_result="false"
        return 0
    fi

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
                    lh_result="false"
                fi
            fi
        done
    done
    return 0
}

if [[ $(lh_validate_data) == "true" ]]
then
    lh_test
else
    active "Perform quota tests"
    not_ok  $(lh_validate_description)
    lh_result="false"
fi

unset -f lh_validate_data
unset -f lh_validate_description
unset -f get_org_quota_plans
unset -f has_any_quota_plans
unset -f does_quota_plan_exist
unset -f get_quota_value
unset -f get_test_array_length
unset -f get_test_quota_name
unset -f get_test_quota
unset -f get_test_quota_list
unset -f lh_test

rm -f /tmp/lh/${dataset}
[[ "${lh_result}" == "true" ]]
