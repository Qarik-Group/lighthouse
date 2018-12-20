#!/usr/bin/env bash

# TODO add test that authorization was done already
# TODO add trap for cleanup

. lib/output.sh

dataset="/tmp/lh/feature_flags.$$"
validation_data="data/cf/feature_flags.json"
lh_result="true"

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
    declare feature_flag="${1:?Missing feature flag argument}"
    jq "[.[] | select(.name==\"${feature_flag}\") ]| length" "${dataset}"
}

feature_flag_enabled() {
    declare feature_flag="${1:?Missing feature flag argument}"
    jq ".[] | select(.name==\"${feature_flag}\") | .enabled" "${dataset}"
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
    cf curl /v2/config/feature_flags > "${dataset}"

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
            
rm -f ${dataset}
[[ "${lh_result}" == "true" ]]
