#!/usr/bin/env bash

query_cf_api()
{
    declare next_url="${1:?Missing cf api url $(caller 0)}"
    declare result_file="${2:?Missing result filename $(caller 0)}"
    declare -i i=0
    declare dataset
    declare -a datasets
    mkdir -p /tmp/lh/apps.$$
    dataset="/tmp/lh/apps.$$/dataset.${i}"
    while [[ "${next_url}" != "null" ]]; do
        cf curl "${next_url}" > "${dataset}"
        # TODO error handling
        datasets[i]="${dataset}"
        next_url=$(jq -r -c ".next_url" "${dataset}")
        ((i += 1))
        dataset="/tmp/lh/apps.$$/dataset.${i}"
    done

    # TODO error handling if no files created
    jq -s 'map(.resources[])' "${datasets[@]}" > "/tmp/lh/${result_file}"
    rm -rf /tmp/lh/apps.$$
}

find_instance_name()
{
    declare deployment="${1:?Missing deployment name $(caller 0)}"
    declare dataset
    mkdir -p /tmp/lh/vms.$$
    dataset=$(mktemp /tmp/instances.XXXXXX)
    bosh vms -d ${deployment} --json > ${dataset}
    jq -r '.Tables[].Rows[]|.instance|contains("router")' $dataset
    rm -rf /tmp/lh/vms.$$
}
