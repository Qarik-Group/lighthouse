#!/usr/bin/env bash

#lh_test_requires bosh

if [[ "" == "${LH_DIRECTORY}" ]] ; then
    echo "Please run this test through Lighthouse or set the LH_DIRECTORY and BASE_ENV variables"
    exit 1
fi

. ${LH_DIRECTORY}/lib/curl.sh
. ${LH_DIRECTORY}/lib/output.sh

vms_dataset="vms_$$"
base_validation_data="data/bosh/routers.json"

echo "Checking ${LH_DIRECTORY}/templates/${base_validation_data}"
validation_data="${LH_DIRECTORY}/templates/${base_validation_data}"

if [[ -e "${base_validation_data}" ]] ;
then
    echo "Found ./${base_validation_data}"
    validation_data="${base_validation_data}"
fi

if [[ "" != "${BASE_ENV}" ]] && [[ -e "${BASE_ENV}/${base_validation_data}" ]] ;
then
    echo "Found and using ${BASE_ENV}/${base_validation_data}"
    validation_data="${BASE_ENV}/${base_validation_data}"
fi

fab_validate_data()
{
    jq '[.|(type=="array",length > 0),
    (.[]|(type=="object",((keys - ["deployment","routers"])|length == 0),(keys|length==2),
        (.deployment|(type=="string",length>0)),
        (.routers|(type=="string",length>0)),
           (.[]|(type=="string",length>0))))]|all' ${validation_data}
}

fab_test()
{
    ok
    return 0
}

if [[ $(fab_validate_data) == "true" ]]
then
    fab_test
else
    active "Perform space existence tests"
    not_ok  $(fab_validate_description)
fi

rm -f /tmp/lh/${vms_dataset}
