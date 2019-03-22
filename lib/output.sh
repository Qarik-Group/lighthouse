#!/usr/bin/env bash

[[ ${LH_SOURCED_LIB_OUTPUT:-} == "sourced" ]] && return 0
export LH_SOURCED_LIB_OUTPUT="sourced"

# This file contains the output commands used in lighthouse tests.
# See documentation at the bottom of the file

# Define colors for output.
         BLACK="\e[0;30m"
           RED="\e[0;31m"
         GREEN="\e[0;32m"
        YELLOW="\e[0;33m"
          BLUE="\e[0;34m"
        PURPLE="\e[0;35m"
          CYAN="\e[0;36m"
         WHITE="\e[0;37m"
         RESET="\e[0m"
  UNDERLINE_ON="\e[4m"
 UNDERLINE_OFF="\e[24m"
  CROSS_OUT_ON="\e[9m"
 CROSS_OUT_OFF="\e[29m"
    BKGD_BLACK="\e[40m"
      BKGD_RED="\e[41m"
    BKGD_GREEN="\e[42m"
   BKGD_YELLOW="\e[43m"
     BKGD_BLUE="\e[44m"
   BKGD_PURPLE="\e[45m"
     BKGD_CYAN="\e[46m"
    BKGD_WHITE="\e[47m"
   SAVE_CURSOR="\e[s"
RESTORE_CURSOR="\e[u"

# Format the results of test messages.

# When a test passes

info() {
  declare message="$@"
  declare status="INFO"
  printf "${PURPLE}%-7s${RESET} %-.70s\n" "${status}" "${message}"
  return 0
}

result() {
  declare message="$@"
  declare status="RESULT"
  printf "${CYAN}%-7s${RESET} %-.70s\n" "${status}" "${message}"
  return 0
}

warn() {
  declare message="$@"
  declare status="WARN"
  printf "${YELLOW}%-7s${RESET} %-.70s\n" " ${status}" "${message}"
}

ok() {
  declare message="$@"
  declare status="PASSED"
  printf "${GREEN}%-7s${RESET} %-.70s\n" "${status}"
  return 0
}

# when a test fails
# TODO: how can a test be red and yellow, just because it has a message?

not_ok() {
  declare message="$@"
  declare status="FAILED"
  printf "${RED}%-7s${RESET}\n" "${status}"
  [[ -n "${message}" ]] && {
    printf "${YELLOW}REASON ${RESET} %-.70s\n" "${message}"
  }
  return 0
}

# TODO: What is an "active" test?

active() {
  declare message="$@"
  declare status="ACTIVE"
  printf "${YELLOW}%-7s${RESET} %-.70s\r" "${status}" "${message}"
  return 0
}

if  [[ $(type -t is_lh_debug_enabled) != "function" ]]
then

  is_lh_debug_enabled() {
    [[ -n ${LH_DEBUG+is_set} ]] && {
      for word in ${1/,/ }; do
        [[ ",${LH_DEBUG}" == *,${word},* ]] && return 0
      done
    }
  }

  is_lh_trace_enabled() {
    [[ -n ${LH_TRACE+is_set} ]] && {
      for word in ${1/,/ }; do
        [[ ",${LH_TRACE}" == *,${word},* ]] && return 0
      done
    }
  }

  debug() {
    declare debug_type=${1?debug() - no debug keyword given   $(caller 0)}
    if is_lh_debug_enabled "${debug_type}"
    then
      shift
      echo -e "DEBUG: $*" >&2
    fi
  }

  trace() {
    declare trace_type=${1?debug() - no trace keyword given   $(caller 0)}
    if is_lh_trace_enabled "${trace_type}"
    then
      shift
      echo -e "TRACE: $*" >&2
    fi
  }
fi

return 0

# These commands are meant to work in terminal windows and in pipelines..
# The convention for test output lines is
#   <7-character-color-coded-word> <message>
