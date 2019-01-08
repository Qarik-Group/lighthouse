#!/usr/bin/env bash

. lib/bash.sh
. lib/curl.sh
. lib/output.sh

# make sure we have associative arrays and -v testing

need_bash_minimum_version 4 3 || {
    active "Services Testing "
    not_ok "Bash version is too old - Want: >= 4 3   Got: ${BASH_VERSINFO[0]} ${BASH_VERSINFO[1]} ${BASH_VERSINFO[2]}"
    exit 1
}

validation_data="rules/cf/services.json"
dataset="services_$$"
plans_dataset="plans_$$"
aggregated_plans_dataset="aggregated_plans_$$"

lh_result="true"

declare -A map_guid_to_service_name
declare -A map_service_name_to_guid

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

get_service_info()
{
    jq -r '.[]|[.metadata.guid,.entity.label,.entity.active,.entity.bindable]|@tsv' "/tmp/lh/${dataset}"
}

get_service_plan_info()
{
    query_cf_api "/v2/service_plans" ${plans_dataset}
    jq -r '.[]|[.entity.name,.entity.service_guid,.entity.active,.entity.free,.entity.public,.entity.bindable]|@tsv' "/tmp/lh/${plans_dataset}"
}

get_service_plan_info2()
{
    query_cf_api "/v2/service_plans" ${plans_dataset}
    jq '[[.[].entity|{g:.service_guid,a:.active,p:.public,f:.free,b:.bindable,sp:.name,c:0}]|group_by(.g,.a,.p,.f,.b)[]|(.[0].c=length)|(.[0].sp=([.[].sp]|join(", ")))|.[0]]' "/tmp/lh/${plans_dataset}" >"/tmp/lh/${aggregated_plans_dataset}"
}

get_aggregated_services()
{
    declare guid="${1:?Missing service guid argument   $(caller 0)}"
    jq --arg guid "${guid}" -r '.[]|select(.g==$guid)|[to_entries[].value]|@tsv' "/tmp/lh/${aggregated_plans_dataset}"
}

build_guid_and_service_name_maps()
{
    declare guid name active bindable
    query_cf_api "/v2/services" ${dataset}
    while IFS=$'\t' read guid name active bindable
    do
        # echo $guid $active $bindable $name
        map_guid_to_service_name["${guid}"]="$name"
        map_service_name_to_guid["${name}"]="$guid"
    done < <(get_service_info)
}

fab_test() {
    declare -i i tests
    declare service guid service_name

    build_guid_and_service_name_maps
    # echo "${!map_service_name_to_guid[@]}" 
    
    get_service_plan_info2

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
            if [[ ${map_service_name_to_guid[${service_name}]+isset} == "isset" ]]
            then
                guid="${map_service_name_to_guid["${service_name}"]}" 
                while IFS=$'\t' read service_guid active public free bindable plans plans_count 
                do
                    if [[ "${test_public}" == "${public}" ]]
                    then
                        (( match += plans_count ))
                    else
                        (( mismatch += plans_count ))
                    fi
                done < <(get_aggregated_services "${guid}")
                if (( match > 0 ))
                then
                    ok
                else
                    not_ok
                    lh_result="false"
                fi
            else
                not_ok "Service does not exist"
                lh_result="false"
                continue
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
unset -f get_service_info
unset -f get_service_plan_info
unset -f get_service_plan_info2
unset -f get_aggregated_services
unset -f build_guid_and_service_name_maps
unset -f fab_test

rm -f /tmp/lh/${dataset}
rm -f /tmp/lh/${plans_dataset}
rm -f /tmp/lh/${aggregated_plans_dataset}
[[ "${lh_result}" == "true" ]]

