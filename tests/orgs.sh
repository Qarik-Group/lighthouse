#!/bin/sh

# https://apidocs.cloudfoundry.org/6.1.0/organizations/list_all_organizations.html
. support/curl.sh

query_cf_api "/v2/organizations" organizations

jq '.[].entity.name' /tmp/fab/organizations

