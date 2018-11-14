#!/bin/bash

query_cf_api()
{
    declare next_url="${1:?Missing cf api url}"
    declare result_file="${2:?Missing result filename}"
    declare -i i=0
    declare dataset
    declare -a datasets
    ((i=0))
    mkdir -p /tmp/fab/apps.$$
    dataset="/tmp/fab/apps.$$/dataset.${i}"
    while [[ "${next_url}" != "null" ]]; do
        cf curl "${next_url}" > "${dataset}"
        # TODO error handling
        datasets[i]="${dataset}"
        next_url=$(jq -r -c ".next_url" "${dataset}")
        ((i += 1))
        dataset="/tmp/fab/apps.$$/dataset.${i}"
    done

    # TODO error handling if no files created
    jq -s 'map(.resources[])' "${datasets[@]}" > "/tmp/fab/${result_file}"
    rm -rf /tmp/fab/apps.$$
}
