#!/usr/bin/env bash

#lh_test_requires uaa

if [[ "" == "${LH_DIRECTORY}" ]] ; then
    echo "Please run this test through Lighthouse or set the LH_DIRECTORY and BASE_ENV variables"
    exit 1
fi

. ${LH_DIRECTORY}/lib/curl.sh
. ${LH_DIRECTORY}/lib/output.sh

vms_dataset="vms_$$"
base_validation_data="data/uaa/local_users.json"

echo "Checking ${LH_DIRECTORY}/templates/${base_validation_data}"
validation_data="${LH_DIRECTORY}/templates/${base_validation_data}"

if [[ -e "${base_validation_data}" ]] ;
then
    echo "Found ./${base_validation_data}"
    validation_data="${base_validation_data}"
fi

if [[ "" != "${BASE_ENV}" ]] && [[ -e "${BASE_ENV}/${base_validation_data}" ]] ;
then
    echo "Found and using ${BASE_ENV}/${base_validation_data}"
    validation_data="${BASE_ENV}/${base_validation_data}"
fi


lh_result="true"

# Dynamically set the rules file and dataset temporary file based on the name and path of this file
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
    # Expected Structure
    #   [
    #       {
    #           "userName": "someuser",
    #           "active": <boolean>,
    #           "groups": [
    #               "Group1",
    #               "Group2",
    #               ...
    #           ]
    #       },
    #   ]
    
    jq '[.|(type=="array",length > 0),
    (.[]|(type=="object",((keys - ["userName","active","groups"])|length == 0),(keys|length==3)   ,
        (.userName|(type=="string",length>0)),
        (.active|(type=="boolean")),
        (.groups|(type=="array",length > 0),
           (.[]|(type=="string",length>0)))))]|all' ${test_data}
}

lh_has_users() {
    jq '.|arrays|length > 0' ${dataset}
}

lh_test_length() {
    jq '.|arrays|length' ${test_data}
}

get_test_data() {
    idx="${1:?Missing index argument $(caller 0)}"
    key="${2:?Missing type argument $(caller 0)}"
    jq --arg i ${idx} --arg key ${key} -r '.[$i|tonumber]|.[$key|tostring]' ${test_data}
}

groups_for_user() {
    test_user="${1:?Missing user argument $(caller 0)}"
    test_active="${2:?Missing active argument $(caller 0)}"
    jq ".[]|select((.userName==\"$test_user\") and (.active==$test_active))|.groups" ${dataset}
}

lh_test() {
    declare -i i tests
    
    active "Verify Local Users"
    uaa users | jq "[ .[] | {userName, active, groups: [.groups[].display]} ]" > ${dataset}
    
    # verify results from UAA
    if [[ $(lh_has_users) != "true" ]]
    then
        not_ok
        lh_result="false"
        return 0
    fi
    
    # Consider all the UAA test results collectively.
    collected_result="true"
    # loop over result, and confirm each is in the test data
    tests=$(lh_test_length)
    for ((i=0; i < tests;i++))
    do
        unset test_user
        unset test_active
        unset test_groups
        unset found_groups
        # Select the test case
        test_user=$(get_test_data ${i} 'userName')
        test_active=$(get_test_data ${i} 'active')
        test_groups=$(get_test_data ${i} 'groups')
        info "Check user '${test_user}' with state '${test_active}' for Groups..."
        
        # Lookup the corresponding result in the data
        found_groups=$(groups_for_user ${test_user} ${test_active})
        # if not found, error
        if [[ "${found_groups}" == "" ]] || [[ "${test_groups}" == "" ]] || [[ "${test_user}" == "" ]] || [[ "${test_active}" == "" ]]
        then
            warn "- user does not exist or is not associated with any groups"
            collected_result="false"
            lh_result="false"
            continue
        fi

        # else for each group in the test case
        while read test_group
        do
            group_result="false"
            while read found_group
            do
                if [[ "${found_group}" == "${test_group}" ]]
                then
                    group_result="true"
                    info "- Found group: ${test_group}"
                fi
            done <<< "$(echo "${found_groups}" | jq -c -r '.[]')"
            
            if [[ "${group_result}" == "false" ]]
            then
                warn "- user is not assigned to '${test_group}'"
                # if any group is not found the collective result is a failure
                collected_result="${group_result}"
            fi
        done <<< "$(echo "${test_groups}" | jq -c -r '.[]')"

        lh_result="${collected_result}"
    done
    if [[ "${lh_result}" == "true" ]]
    then
        ok
    else
        not_ok "One or more UAA tests have not passed successfully."
    fi
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
unset -f lh_has_users

# Cleanup
rm -f ${dataset}

# Pass result
[[ "${lh_result}" == "true" ]]
