#!/usr/bin/env bash

#lh_test_requires cf

# TODO add test that authorization was done already
# TODO add trap for cleanup

if [[ "" == "${LH_DIRECTORY}" ]] ; then
    echo "Please run this test through Lighthouse or set the LH_DIRECTORY and USE_ENV variables"
    exit 1
fi

. ${LH_DIRECTORY}/lib/output.sh

mkdir -p /tmp/lh

dataset="/tmp/lh/buildpacks.$$"
lh_result="true"

fab_validate_data()
{
    echo "true"
}

fab_has_buildpacks()
{
    jq '.total_results > 0' ${dataset} 
}

fab_test()
{
    active "List Buildpacks"
    cf curl /v2/buildpacks > "${dataset}"
    if [[ $(fab_has_buildpacks) == "true" ]]
    then
        ok
    else
        not_ok
        lh_result="false"
        return 0
    fi
    declare prev_stack="asdfgh"
    jq -r '[.resources[].entity]|sort_by(.stack,.position)[]|[.stack//" ",.position,.name]|@tsv' ${dataset} | 
    while IFS=$'\t' read stack position name 
    do
        if [[ "${prev_stack}" !=  ${stack} ]]
        then

            info ""
            info "stack: ${stack}"
            prev_stack=${stack}
        fi
        info  "        ${name}"
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
            
rm -f ${dataset}
[[ "${lh_result}" == "true" ]]
