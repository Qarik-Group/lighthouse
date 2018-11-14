#!/bin/sh

(support/clear-auth.sh)

. data/env.sh

# TODO Add parameter checking
# TODO Do we Use CF API interface to get json results?
# TODO Do we use perl to be consistent with genesis?

cf api "${FAB_CF_API}" 

. data/auth.sh

CF_USERNAME="${FAB_CF_USERNAME}" CF_PASSWORD="${FAB_CF_PASSWORD}" cf auth

cf target -o "${FAB_CF_ORG}" -s "${FAB_CF_SPACE}"

