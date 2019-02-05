#!/usr/bin/env bash

#lh_test_requires cf

if [[ "" == "${LH_DIRECTORY}" ]] ; then
    echo "Please run this test through Lighthouse or set the LH_DIRECTORY and USE_ENV variables"
    exit 1
fi

. ${LH_DIRECTORY}/lib/curl.sh
. ${LH_DIRECTORY}/lib/output.sh

base_validation_data="data/cf/envvars.json"
dataset="environment_variables_$$"

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
    jq '[type=="object",(keys-["staging","running"]|length==0),
            if has("staging") then (.staging|(type=="object",length)) else true end,
            if has("running") then (.running|(type=="object",length)) else true end]|all' "${validation_data}"
}

fab_validate_description()
{
    echo "Expecting a object with keys staging and running with contains an object with key value pairs"
}


get_envvar() {
    declare envvar="${1:?Missing org argument   $(caller 0)}"
    jq --arg envvar "${envvar}" -r '.|select(.[$envvar])|to_entries[]|[.value|@text]|@sh' "/tmp/lh/${dataset}"
}

get_test_envvars() {
    declare envtype="${1:?Missing environment type  argument   $(caller 0)}"
    jq --arg envtype "${envtype}" -r '.[$envtype]|to_entries[]|[.key,.value|@text]|@tsv' "${validation_data}"

}

test_environment() {
    declare envtype="${1:?Missing environment type  argument   $(caller 0)}"
    query_cf_raw_api  "/v2/config/environment_variable_groups/${envtype}" ${dataset}
    
    get_test_envvars ${envtype} | while IFS=$'\t' read name test_value 
    do
        declare -a "value=($(get_envvar ${name}))"
        active "Does the ${envtype} environment have the variable ${name}?"
        if [[ "${test_value}" == "${value}" ]]
        then
            ok
        else
            not_ok
            lh_result="false"
        fi
    done
    
    return 0
}


fab_test() {
    test_environment staging
    test_environment running
    return 0
}


if [[ $(fab_validate_data) == "true" ]]
then
    fab_test
else
    active "Perform environmental variable tests"
    not_ok  $(fab_validate_description)
    lh_result="false"
fi

unset -f get_envvar
unset -f test_environment
unset -f get_test_envars
unset -f fab_test
unset -f fab_validate_data
unset -f fab_validate_description

rm -f /tmp/lh/${dataset}
[[ "${lh_result}" == "true" ]]
