#!/usr/bin/env bash

# TODO add test that authorization was done already
# TODO add trap for cleanup

. lib/output.sh

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
    jq -r '[.resources[].entity]|sort_by(.stack,.position)[]|[.stack//"",.position,.name]|@sh' ${dataset} | 
    while read stack position name 
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
