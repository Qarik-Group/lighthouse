#!/usr/bin/env bash

#lh_test_requires cf

if [[ "" == "${LH_DIRECTORY}" ]] ; then
    echo "Please run this test through Lighthouse or set the LH_DIRECTORY and BASH_ENV variables"
    exit 1
fi

. ${LH_DIRECTORY}/lib/curl.sh
. ${LH_DIRECTORY}/lib/output.sh

base_validation_data="data/cf/orgs.json"
dataset="organizations_$$"

echo "Checking ${LH_DIRECTORY}/templates/${base_validation_data}"
validation_data="${LH_DIRECTORY}/templates/${base_validation_data}"

if [[ -e "${base_validation_data}" ]] ; 
then 
    echo "Found ./${base_validation_data}" 
    validation_data="${base_validation_data}"
fi

if [[ "" != "${BASH_ENV}" ]] && [[ -e "${BASH_ENV}/${base_validation_data}" ]] ;
then
    echo "Found and using ${BASH_ENV}/${base_validation_data}"
    validation_data="${BASH_ENV}/${base_validation_data}"
fi

lh_result="true"
fab_validate_data()
{
    jq '[.|(type=="array",length > 0),(.[]|(type=="string",length>0))]|all' ${validation_data}
}

fab_validate_description()
{
    echo "Expecting a non-empty array of non-empty strings"
}


org_exists() {
    declare org="${1:?Missing org argument   $(caller 0)}"
    jq ".[]|.entity|select(.name==\"${org}\")|true" /tmp/lh/${dataset}
}

fab_test() {
    query_cf_api "/v2/organizations" ${dataset}
    (( $? > 0)) && {
      active "Organization Existence Tests"
      not_ok $(query_get_error "/tmp/lh/${dataset}")
      lh_result="false"
      return 0
    }

    # TODO add validation
    for org in $(jq -r '.[]' ${validation_data})
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
