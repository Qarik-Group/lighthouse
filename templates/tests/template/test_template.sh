#!/usr/bin/env bash

#lh_test_requires

if [[ -z ${LH_DIRECTORY:+is_set_and_not_empty} ]] ; then
    echo "Please run this test through Lighthouse or export LH_DIRECTORY"
    echo "and USE_ENV variables."
    echo LH_DIRECTORY ${LH_DIRECTORY:-"is not set or is an empty string"}
    echo USE_ENV ${USE_ENV:-"is not set or is an empty string"}
    exit 1
fi

[[ ":$PATH:" != *":${LH_DIRECTORY}/lib:"* ]] && {
    PATH="${LH_DIRECTORY}/lib:${PATH}"
}

. curl.sh
. output.sh

base_validation_data="data/cf/data_name.json"

echo "Checking ${LH_DIRECTORY}/templates/${base_validation_data}"
validation_data="${LH_DIRECTORY}/templates/${base_validation_data}"

if [[ -e "${base_validation_data}" ]] ; 
then 
    echo "Found ./${base_validation_data}" 
    validation_data="${base_validation_data}"
fi

if [[ "" != "${USE_ENV}" && -e "${USE_ENV}/${base_validation_data}" ]] ;
then
    echo "Found and using ${USE_ENV}/${base_validation_data}"
    validation_data="${USE_ENV}/${base_validation_data}"
fi

lh_result="true"

# Dynamically set the data file and dataset temporary file based on the name and path of this file
this_test_file=$(basename ${0})
this_test=$(echo ${this_test_file%.*})
this_path=$(dirname ${0})
test_defn_path=$(echo "${this_path/tests/data}")

# Create Temp Directory
temp_path='/tmp/lh'
mkdir -p ${temp_path}

test_data="${test_defn_path}/${this_test}.json"
dataset="${temp_path}/${this_test}_$$"


lh_validate_data() {
    # Add a statement that validates the test data defined in the rules for this test are in the correct format
    return 0
}

lh_test() {
    # Define the test that compares real world against the test data
    return 0
}

if [[ $(lh_validate_data) == "true" ]]
then
    lh_test
else
    active "Perform ${this_test} tests"
    not_ok  "Expecting a non-empty array of non-empty strings"
    lh_result="false"
fi

# reset function definitions to avoid conflicts with other tests.
unset -f lh_validate_data
unset -f lh_test

# Cleanup
rm -f ${dataset}

# Pass result
[[ "${lh_result}" == "true" ]]
