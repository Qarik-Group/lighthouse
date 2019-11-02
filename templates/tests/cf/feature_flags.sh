#!/usr/bin/env bash

#lh_test_requires cf

if [[ "" == "${LH_DIRECTORY}" ]] ; then
    echo "Please run this test through Lighthouse or set the LH_DIRECTORY and BASH_ENV variables"
    exit 1
fi

. ${LH_DIRECTORY}/lib/output.sh
. ${LH_DIRECTORY}/lib/curl.sh

dataset="feature_flags.$$"
base_validation_data="data/cf/feature_flags.json"
lh_result="true"

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
fab_validate_data()
{
    jq '[(type == "object"),(keys|length > 0),(keys - ["disabled","enabled"]|length == 0),
        (if has("disabled") then
           (.disabled|((type == "array"),length > 0,(.[]|type=="string",length>0)))
         else true end),
        (if has("enabled") then
           (.enabled|((type == "array"),length > 0,(.[]|type=="string",length>0)))
       else true end)]|all' "${validation_data}"
}

feature_flag_exists() {
    declare feature_flag="${1:?Missing feature flag argument   $(caller 0)}"
    jq "[.[] | select(.name==\"${feature_flag}\") ]| length" "/tmp/lh/${dataset}"
}

feature_flag_enabled() {
    declare feature_flag="${1:?Missing feature flag argument   $(caller 0)}"
    jq ".[] | select(.name==\"${feature_flag}\") | .enabled" "/tmp/lh/${dataset}"
}

get_test_enabled_list()
{
   jq -r '.enabled[]|@sh' ${validation_data}
}

get_test_disabled_list()
{
   jq -r '.disabled[]|@sh' ${validation_data}
}


fab_test()
{
    declare feature_flag
    query_cf_raw_api /v2/config/feature_flags "${dataset}"
    (( $? > 0)) && {
      active "Feature Flag Tests"
      not_ok $(query_get_error "/tmp/lh/${dataset}")
      lh_result="false"
      return 0
      continue
    }

    declare -a "test_flags=($(get_test_enabled_list))"
    for feature_flag in "${test_flags[@]}"
    do
        active "Is feature flag ${feature_flag} enabled?"
        if (( $(feature_flag_exists "${feature_flag}") == 1 )); then
            if [[ $(feature_flag_enabled "${feature_flag}") == true ]]; then
                ok
            else
                not_ok
                lh_result="false"
            fi
        else
            not_ok Feature flag "${feature_flag}" does not exist
            lh_result="false"
        fi
    done

    declare -a "test_flags=($(get_test_disabled_list))"
    for feature_flag in "${test_flags[@]}"
    do
        active "Is feature flag ${feature_flag} disabled?"
        if (( $(feature_flag_exists "${feature_flag}") == 1 )); then
            if [[ $(feature_flag_enabled "${feature_flag}") == false ]]; then
                ok
            else
                not_ok
                lh_result="false"
            fi
        else
            not_ok Feature flag  "${feature_flag}" does not exist
            lh_result="false"
        fi
    done
}

if [[ $(fab_validate_data) == "true" ]]
then
    fab_test
else
    active "Perform feature flag tests"
    not_ok  $(fab_validate_description)
    lh_result="false"
fi
            
rm -f "/tmp/lh${dataset}"
[[ "${lh_result}" == "true" ]]
