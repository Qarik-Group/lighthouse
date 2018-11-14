#!/bin/bash

# TODO add test that authorization was done already
# TODO add trap for cleanup

dataset="/tmp/feature_flags.$$"
cf curl /v2/config/feature_flags > "${dataset}"


feature_flag_exists() {
    declare feature_flag="${1:?Missing feature flag argument}"
    jq "[.[] | select(.name==\"${feature_flag}\") ]| length" "${dataset}"
}

feature_flag_enabled() {
    declare feature_flag="${1:?Missing feature flag argument}"
    jq ".[] | select(.name==\"${feature_flag}\") | .enabled" "${dataset}"
}

. data/feature_flags.sh

for feature_flag in "${enabled[@]}"
do
    if (( $(feature_flag_exists "${feature_flag}") == 1 )); then
        if [[ $(feature_flag_enabled "${feature_flag}") == true ]]; then
            echo success
        else
            echo enabled test failure "${feature_flag}" is disabled
        fi
    else
        echo enabled test failure "${feature_flag}" does not exist
    fi
done

for feature_flag in "${disabled[@]}"
do
    if (( $(feature_flag_exists "${feature_flag}") == 1 )); then
        if [[ $(feature_flag_enabled "${feature_flag}") == false ]]; then
            echo success
        else
            echo disabled test failure "${feature_flag}" is enabled
        fi
    else
        echo disabled test failure "${feature_flag}" does not exist
    fi
done
            
rm -f /tmp/feature_flags.$$
