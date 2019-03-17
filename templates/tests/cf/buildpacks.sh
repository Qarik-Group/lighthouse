#!/usr/bin/env bash

#lh_test_requires cf

# TODO add test that authorization was done already
# TODO add trap for cleanup

if [[ "" == "${LH_DIRECTORY}" ]] ; then
    echo "Please run this test through Lighthouse or set the LH_DIRECTORY and USE_ENV variables"
    exit 1
fi

. ${LH_DIRECTORY}/lib/output.sh
. ${LH_DIRECTORY}/lib/curl.sh

mkdir -p /tmp/lh

dataset="buildpacks.$$"
lh_result="true"

fab_validate_data()
{
    echo "true"
}

fab_has_buildpacks()
{
    jq '.total_results > 0' "/tmp/lh/${dataset}"
}

fab_test()
{
    active "List Buildpacks"
    query_cf_raw_api /v2/buildpacks "${dataset}"
    (( $? > 0)) && {
      not_ok $(query_get_error "/tmp/lh/${dataset}")
      lh_result="false"
      return 0
      continue
    }
    if [[ $(fab_has_buildpacks) == "true" ]]
    then
        ok
    else
        not_ok
        lh_result="false"
        return 0
    fi
    declare prev_stack="asdfgh"
    jq -r '[.resources[].entity]|sort_by(.stack,.position)[]|[.stack//" ",.position,.name]|@tsv' "/tmp/lh/${dataset}" | 
    while IFS=$'\t' read stack position name 
    do
        if [[ "${prev_stack}" !=  ${stack} ]]
        then

            result ""
            result "stack: ${stack}"
            prev_stack=${stack}
        fi
        result  "        ${name}"
    done 
    return 0
}

if [[ $(fab_validate_data) == "true" ]] 
then
    fab_test
else
    active "Perform buildpacks list"
    not_ok  $(fab_validate_description)
    lh_result="false"
fi
            
rm -f "/tmp/lh/${dataset}"
[[ "${lh_result}" == "true" ]]
