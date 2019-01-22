#!/usr/bin/env bash

if [[ "" == "${LH_DIRECTORY}" ]] ; then
    echo "Please run this test through Lighthouse or set the LH_DIRECTORY and USE_ENV variables"
    exit 1
fi

. ${LH_DIRECTORY}/lib/curl.sh
. ${LH_DIRECTORY}/lib/output.sh

# make sure we have associative arrays and -v testing

base_validation_data="data/cf/services.json"
dataset="services_$$"
plans_dataset="plans_$$"
aggregated_plans_dataset="aggregated_plans_$$"

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

fab_validate_data()
{
    jq -r '[(type=="array",length > 0),
        (.[]|(type=="object",((keys - ["public","services"])|length == 0),(keys|length==2),
           (.public|type=="boolean"),
           (.services|(type=="array",length>0),
               (.[]|(type=="string",length>0)))))]|all' ${validation_data}
}

fab_validate_description()
{
    echo "Expecting a non-empty array of objects containing public and services array"
}

get_test_array_length()
{
    jq -r '.|arrays|length' "${validation_data}"
}

get_test_public()
{
    declare idx="${1:?Missing test index argument$(caller 0)}"
    jq --arg i ${idx} -r '.[$i|tonumber]|.public|@sh' ${validation_data}
}

get_test_service_list()
{
    declare idx="${1:?Missing test index argument$(caller 0)}"
    jq --arg i ${idx} -r '.[$i|tonumber]|.services|.[]|@sh' ${validation_data}
}

get_service_plan_info()
{
    query_cf_api "/v2/services" ${dataset}
    query_cf_api "/v2/service_plans" ${plans_dataset}
    jq --slurpfile services /tmp/lh/${dataset} --slurpfile plans /tmp/lh/${plans_dataset} -n '[[$services[]|.[]|
                {sguid:.metadata.guid,name:.entity.label}] as $lookup|
              $plans[]|[.[].entity as $q|
                {g:$q.service_guid,a:$q.active,p:$q.public,f:$q.free,
                 b:$q.bindable,
                 sn:($lookup[]|select(.sguid==$q.service_guid)|.name),
                 sp:$q.name,c:0}]
                |group_by(.g,.a,.p,.f,.b)[]|
                (.[0].c=length)|
                (.[0].sp=([.[].sp]|join(", ")))|
             .[0]]' >"/tmp/lh/${aggregated_plans_dataset}"
}

get_aggregated_services()
{
    declare service_name="${1:?Missing service name argument   $(caller 0)}"
    jq --arg name "${service_name}" -r '.[]|select(.sn==$name)|[to_entries[].value]|@tsv' "/tmp/lh/${aggregated_plans_dataset}"
}

fab_test() {
    declare -i i tests
    declare service guid service_name

    get_service_plan_info

    tests=$(get_test_array_length)
    for ((i=0; i < tests;i++))
    do
        declare -a "test_public=($(get_test_public ${i}))"
        declare -a "services=($(get_test_service_list ${i}))"
        for service_name in "${services[@]}"
        do
            declare -i match=0 mismatch=0 
            declare display="public"
            [[ $test_public == 'false' ]] && display="private"
            active "Does sevice ${service_name} have ${display} plans?"
            while IFS=$'\t' read sguid active public free bindable sname plans plans_count 
            do
                if [[ "${test_public}" == "${public}" ]]
                then
                    (( match += plans_count ))
                else
                    (( mismatch += plans_count ))
                fi
            done < <(get_aggregated_services "${service_name}")
            if (( match > 0 ))
            then
                ok
            elif (( mismatch > 0 && match == 0 ))
            then
                not_ok "No ${display} plans found"
                lh_result="false"
            elif (( match == 0 && mismatch == 0 ))
            then
                not_ok "Service does not exist"
                lh_result="false"
            fi
        done
    done
    return 0
}


if [[ $(fab_validate_data) == "true" ]]
then
    fab_test
else
    active "Perform organization existence tests"
    not_ok  $(fab_validate_description)
    lh_result="false"
fi

unset -f fab_validate_data
unset -f fab_validate_description
unset -f get_test_array_length
unset -f get_test_public
unset -f get_test_service_list
unset -f get_service_plan_info
unset -f get_aggregated_services
unset -f fab_test

rm -f /tmp/lh/${dataset}
rm -f /tmp/lh/${plans_dataset}
rm -f /tmp/lh/${aggregated_plans_dataset}
[[ "${lh_result}" == "true" ]]

