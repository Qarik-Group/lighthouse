#!/usr/bin/env bash

. support/curl.sh
. support/output.sh


org_dataset="organization_$$"
spaces_dataset="spaces_$$"
validation_data="data/spaces.json"


fab_validate_data()
{
    jq -r '[(type=="array",length > 0),
       (.[]|(type=="object",(keys - ["org","spaces"]|length == 0),
           (.org|(type=="string",length>0)),
           (.spaces|(type=="array",length>0),
               (.[]|(type=="string",length>0)))))]|all' ${validation_data}
}

fab_validate_description()
{
    echo "Expecting an array of space objects." 
}

get_org_space_url()
{
    declare org="${1:?Missing org argument}"
    query_cf_api "/v2/organizations?q=name:${org}" ${org_dataset}
    jq --arg org "${org}" -r '.[].entity|select(.name==$org)|.spaces_url' "/tmp/fab/${org_dataset}"
}

does_space_exist()
{
    declare space="${1:?Missing space argument}"
    declare dataset="${2:?Missing organizationdataset argument}"
    jq --arg space "${space}" -r '.[]|.entity|select(.name==$space)|.name==$space' "/tmp/fab/${dataset}"
}

get_test_array_length()
{
    jq -r '.|arrays|length' "${validation_data}"
}

get_test_org()
{
    declare idx="${1:?Missing test index argument}"
    jq --arg i ${idx} -r '.[$i|tonumber]|.org|@sh' ${validation_data}
}

get_test_spaces_list()
{
    declare idx="${1:?Missing test index argument}"
    jq --arg i ${idx} -r '.[$i|tonumber]|.spaces|.[]|@sh' ${validation_data}
}

fab_test()
{
    declare -i i tests
    declare org spaces spaces_url

    tests=$(get_test_array_length)
    for ((i=0; i < tests;i++))
    do
        declare -a "org=($(get_test_org ${i}))"
        spaces_url=$(get_org_space_url "${org}")
        [[ -z "${spaces_url}" ]] && {
            active "Does the expected spaces exist in org ${org}?"
            not_ok "Org does not exit"
            continue
        }

        query_cf_api "${spaces_url}" "${spaces_dataset}"

        declare -a "spaces=($(get_test_spaces_list "${i}"))"
        for space in "${spaces[@]}"
        do
            active "Does space ${space} exist in org ${org}"
            if [[ $(does_space_exist "${space}" "${spaces_dataset}") == "true" ]]
            then
                ok
            else
                not_ok
            fi
        done
    done
    return 0
}

if [[ $(fab_validate_data) == "true" ]]
then
    fab_test
else
    active "Perform space existence tests"
    not_ok  $(fab_validate_description)
fi

rm -f /tmp/fab/${org_dataset}
rm -f /tmp/fab/${spaces_dataset}

exit 0
