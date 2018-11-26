#!/usr/local/bin/bash

# TODO add test that authorization was done already
# TODO add trap for cleanup

. support/output.sh

dataset="/tmp/feature_flags.$$"
validation_data="data/feature_flags.json"

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
            fi
        else
            not_ok Feature flag "${feature_flag}" does not exist
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
            fi
        else
            not_ok Feature flag  "${feature_flag}" does not exist
        fi
    done
}

[[ $(fab_validate_data) == "true" ]] && fab_test || {
    active "Perform feature flag tests"
    not_ok  $(fab_validate_description)
}
            
rm -f /tmp/feature_flags.$$
