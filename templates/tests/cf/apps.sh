#!/usr/bin/env bash

#lh_test_requires cf

if [[ "" == "${LH_DIRECTORY}" ]] ; then
    echo "Please run this test through Lighthouse or set the LH_DIRECTORY and USE_ENV variables"
    exit 1
fi

. ${LH_DIRECTORY}/lib/curl.sh
. ${LH_DIRECTORY}/lib/output.sh

org_dataset="organization_$$"
spaces_dataset="spaces_$$"
apps_dataset="apps_$$"

base_validation_data="data/cf/apps.json"

echo "Checking ${LH_DIRECTORY}/templates/${base_validation_data}"
validation_data="${LH_DIRECTORY}/templates/${base_validation_data}"

if [[ -e "${base_validation_data}" ]] ; 
then 
    echo "Found ./${base_validation_data}" 
    validation_data="${base_validation_data}"
fi

if [[ "" != "${USE_ENV}" ]] && [[ -e "${USE_ENV}/${base_validation_data}" ]] ;
then
    echo "Found and using ${USE_ENV}/${base_validation_data}"
    validation_data="${USE_ENV}/${base_validation_data}"
fi

lh_result="true"
fab_validate_data()
{
    jq -r '[(type=="array",length > 0),
    (.[]|(type=="object",((keys - ["org","space","apps"])|length == 0),(keys|length==3),
           (.org|(type=="string",length>0)),
           (.space|(type=="string",length>0)),
           (.apps|(type=="array",length>0),
               (.[]|(type=="string",length>0)))))]|all' ${validation_data}
}

fab_validate_description()
{
    echo "Expecting an array of apps objects." 
}

get_org_space_url()
{
    declare org="${1:?Missing org argument$(caller 0)}"
    query_cf_api "/v2/organizations?q=name:${org}" "${org_dataset}"
    jq --arg org "${org}" -r '.[].entity|select(.name==$org)|.spaces_url' "/tmp/lh/${org_dataset}"
}

does_space_exist()
{
    declare space="${1:?Missing space argument$(caller 0)}"
    declare dataset="${2:?Missing organization dataset argument$(caller 0)}"
    jq --arg space "${space}" -r '.[]|.entity|select(.name==$space)|.name==$space' "/tmp/lh/${dataset}"
}

get_space_apps_url()
{
    declare space_url="${1:?Missing org argument$(caller 0)}"
    declare space="${2:?Missing space argument$(caller 0)}"
    query_cf_api "${spaces_url}" "${spaces_dataset}"
    jq --arg space "${space}" -r '.[].entity|select(.name==$space)|.apps_url' "/tmp/lh/${spaces_dataset}"
}

does_app_exist()
{
    declare app="${1:?Missing space argument$(caller 0)}"
    declare dataset="${2:?Missing apps dataset argument$(caller 0)}"
    jq --arg app "${app}" -r '.[]|.entity|select(.name==$app)|.name==$app' "/tmp/lh/${dataset}"
}

get_test_array_length()
{
    jq -r '.|arrays|length' "${validation_data}"
}

get_test_org()
{
    declare idx="${1:?Missing test index argument$(caller 0)}"
    jq --arg i ${idx} -r '.[$i|tonumber]|.org|@sh' ${validation_data}
}

get_test_space()
{
    declare idx="${1:?Missing test index argument$(caller 0)}"
    jq --arg i ${idx} -r '.[$i|tonumber]|.space|@sh' ${validation_data}
}

get_test_apps_list()
{
    declare idx="${1:?Missing test index argument$(caller 0)}"
    jq --arg i ${idx} -r '.[$i|tonumber]|.apps|.[]|@sh' ${validation_data}
}

fab_test()
{
    declare -i i tests
    declare org spaces spaces_url

    tests=$(get_test_array_length)
    for ((i=0; i < tests;i++))
    do
        declare -a "org=($(get_test_org ${i}))"
        declare -a "space=($(get_test_space ${i}))"
        declare -a "apps=($(get_test_apps_list ${i}))"
        spaces_url=$(get_org_space_url "${org}")
        [[ -z "${spaces_url}" ]] && {
            active "Application data  validation for org '${org}'"
            not_ok "Org does not exist"
            lh_result="false"
            continue
        }
        apps_url=$(get_space_apps_url "${spaces_url}" "${space}")
        [[ -z "${apps_url}" ]] && {
            active "Application data validation for space '${space}'"
            not_ok "Space does not exist"
            lh_result="false"
            continue
        }

        query_cf_api "${apps_url}" "${apps_dataset}"

        for app in "${apps[@]}"
        do
            active "Does application ${app} exist in space  ${space}"
            if [[ $(does_app_exist "${app}" "${apps_dataset}") == "true" ]]
            then
                ok
            else
                not_ok
                lh_result="false"
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
    lh_result="false"
fi

rm -f /tmp/lh/${org_dataset}
rm -f /tmp/lh/${spaces_dataset}
rm -f /tmp/lh/${apps_dataset}
[[ "${lh_result}" == "true" ]]
