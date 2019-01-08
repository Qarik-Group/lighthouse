#!/usr/bin/env bash

. lib/curl.sh
. lib/output.sh

lh_result="true"

# Dynamically set the rules file and dataset temporary file based on the name and path of this file
this_test_file=$(basename ${0})
this_test=$(echo ${this_test_file%.*})
this_path=$(dirname ${0})
test_defn_path=$(echo "${this_path/tests/rules}")

# Create Temp Directory
temp_path='/tmp/lh'
mkdir -p ${temp_path}

test_data="${test_defn_path}/${this_test}.json"
dataset="${temp_path}/${this_test}_$$"


lh_validate_data() {
    # Add a statement that validates the test data defined in the rules for this test are in the correct format
}

lh_test() {
    # Define the test that compares real world against the test data
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
