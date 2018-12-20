#!/usr/bin/env bash

. lib/curl.sh
. lib/output.sh

test_data="data/cf/orgs.json"
dataset="organizations_$$"

lh_result="true"
fab_validate_data()
{
    jq '[.|(type=="array",length > 0),(.[]|(type=="string",length>0))]|all' ${test_data}
}

fab_validate_description()
{
    echo "Expecting a non-empty array of non-empty strings"
}


org_exists() {
    declare org="${1:?Missing org argument}"
    jq ".[]|.entity|select(.name==\"${org}\")|true" /tmp/lh/${dataset}
}

fab_test() {
    query_cf_api "/v2/organizations" ${dataset}

    # TODO add validation
    for org in $(jq -r '.[]' ${test_data})
    do
        active "Does org ${org} exist?"
        [[ $(org_exists "${org}") == "true" ]] && ok || { 
            not_ok
            lh_result="false"
        }
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

unset -f org_exists
unset -f fab_test
unset -f fab_validate_input
unset -f fab_validate_description

rm -f /tmp/lh/${dataset}
[[ "${lh_result}" == "true" ]]
