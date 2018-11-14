#!/bin/sh

. support/curl.sh

org_results="/tmp/fab/organizations"

[[ ! -f "${org_results}" ]] && {
    echo did not run organizations test yet
    exit 1
}

spaces_url=$(jq -r ".[].entity|select(.name==\"starkandwayne\")|.spaces_url" "${org_results}")

[[ -z "${spaces_url}" ]] && {
    echo did not find a matching organizations
    exit 1
}

query_cf_api "${spaces_url}" starkandwayne_spaces

[[ -f /tmp/fab/starkandwayne_spaces ]] && {
    jq '.[].entity.name' /tmp/fab/starkandwayne_spaces
}

