#!/usr/bin/env bash

query_get_error()
{
    declare dataset="${1:?Missing dataset file   $(caller 0)}"
     
    exec 3< "${dataset}"
    read line <&3
    if [[ "${line}" == '{' ]]
    then
        jq -c -r '"cf query failure: " + .description' "${dataset}"
    elif [[ "${line}" == "FAILED" ]]
    then
        read line <&3
        [[ "${line}" == *: ]] && read line <&3
        echo "${line}"
    else
        echo "${line}"
    fi
    exec 3<&-
}

query_get_error_codes()
{
    declare dataset="${1:?Missing dataset file   $(caller 0)}"
     
    jq -c -r '"(" + .error_code + " " + .code + ")"' "${dataset}"
}

query_has_error()
{
    declare dataset="${1:?Missing dataset path   $(caller 0)}"
    jq '[type=="object" and length==3 and
        has("error_code","code","description")]|all' "${dataset}"
}

has_multi_result_packet()
{
    declare dataset="${1:?Missing dataset path   $(caller 0)}"
    jq '[type=="object",has("next_url","prev_url","total_results","total_pages")]|all' "${dataset}"
}

query_cf_api()
{
    declare next_url="${1:?Missing cf api url   $(caller 0)}"
    declare result_file="${2:?Missing result filename   $(caller 0)}"
    [[ ${next_url} == "x" ]] && { next_url=""; }
    declare -i i=0
    declare dataset
    declare -a datasets
    mkdir -p /tmp/lh/apps.$$
    dataset="/tmp/lh/apps.$$/dataset.${i}"
    while [[ "${next_url}" != "null" ]]; do
        cf curl "${next_url}" > "${dataset}"
        if (( $? > 0 ))
        then
            cp ${dataset} "/tmp/lh/${result_file}"
            rm -rf /tmp/lh/apps.$$
            if is_lh_debug_enabled "curl"; then
              debug "cf curl return a non-zero return status"
            fi
            return 2  # cf detected an error
        elif [[ $(query_has_error "${dataset}") == "true" ]]
        then
            cp ${dataset} "/tmp/lh/${result_file}"
            rm -rf /tmp/lh/apps.$$
            if is_lh_debug_enabled "curl"; then
              debug "cf curl was successfull but returned an error"
            fi
            return 1  # cf detected an error
        elif [[ $(has_multi_result_packet "${dataset}") != "true" ]]
        then
            cp ${dataset} "/tmp/lh/${result_file}"
            rm -rf /tmp/lh/apps.$$
            if is_lh_debug_enabled "curl"; then
              debug "cf curl was successfull but output data format was unexpected"
            fi
            return 2 # unexpected output for this fuction
        fi
        datasets[i]="${dataset}"
        next_url=$(jq -r -c ".next_url" "${dataset}")
        ((i += 1))
        dataset="/tmp/lh/apps.$$/dataset.${i}"
    done

    # TODO error handling if no files created
    jq -s 'map(.resources[])' "${datasets[@]}" > "/tmp/lh/${result_file}"
    rm -rf /tmp/lh/apps.$$
    return 0
}

#For when a query does not use the next_url convention
query_cf_raw_api()
{
    declare url="${1:?Missing cf api url   $(caller 0)}"
    declare result_file="${2:?Missing result filename   $(caller 0)}"
    declare dataset="/tmp/lh/${result_file}"
    cf curl "${url}" > "${dataset}"
    (($? > 0)) && return 2
    [[ $(query_has_error "${dataset}") == "false" ]]
}

find_instance_name()
{
    declare deployment="${1:?Missing deployment name   $(caller 0)}"
    declare dataset
    mkdir -p /tmp/lh/vms.$$
    dataset=$(mktemp /tmp/instances.XXXXXX)
    bosh vms -d ${deployment} --json > ${dataset}
    jq -r '.Tables[].Rows[]|.instance|contains("router")' $dataset
    rm -rf /tmp/lh/vms.$$
}
