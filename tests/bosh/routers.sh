#!/usr/bin/env bash

. lib/curl.sh
. lib/output.sh

vms_dataset="vms_$$"
validation_data="data/bosh/routers.json"

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
    find_instance_name xjkevin-cf
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
