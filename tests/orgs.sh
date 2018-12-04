#!/usr/bin/env bash

# https://apidocs.cloudfoundry.org/6.1.0/organizations/list_all_organizations.html
. support/output.sh
. support/curl.sh


test_data="data/orgs.json"
dataset="organizations_$$"
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
    jq ".[]|.entity|select(.name==\"${org}\")|true" /tmp/fab/${dataset}
}

fab_test() {
    query_cf_api "/v2/organizations" ${dataset}

    # TODO add validation
    for org in $(jq -r '.[]' ${test_data})
    do
        active "Does org ${org} exist?"
        [[ $(org_exists "${org}") == "true" ]] && ok || not_ok
    done
    return 0
}


[[ $(fab_validate_data) == "true" ]] && fab_test || {
    active "Perform organization existence tests"
    not_ok  $(fab_validate_description)
}

unset -f org_exists
unset -f fab_test
unset -f fab_validate_input
unset -f fab_validate_description


rm -f /tmp/fab/${dataset}
