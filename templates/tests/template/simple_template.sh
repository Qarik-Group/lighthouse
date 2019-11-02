#!/usr/bin/env bash

#lh_test_requires cf

if [[ "" == "${LH_DIRECTORY}" ]] ; then
    echo "Please run this test through Lighthouse or set the LH_DIRECTORY and BASH_ENV variables" ; exit 1
fi

. ${LH_DIRECTORY}/lib/helpers.sh

result = 1
#===============================================================================
# Start test here


cf m | grep "redis" && result = 0


#===============================================================================
# Finish Here

exit $result
