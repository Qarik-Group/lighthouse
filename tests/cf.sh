#!/usr/bin/env bash

set -eu

# helpers
. lib/curl.sh
. lib/output.sh

# run cf tests
. lib/cf/apps.sh
. lib/cf/orgs.sh
. lib/cf/spaces.sh