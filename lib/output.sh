#!/usr/bin/env bash
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
ok() {
    declare message="$@"
    declare status="PASSED"
    # printf "${RESTORE_CURSOR}%-70s   ${GREEN}%-7s${RESET}\n" "${message}" "${status}"
    # printf "${GREEN}%-7s${RESET}   %-70s\n" "${status}" "${message}"
    printf "${GREEN}%-7s${RESET}\n" "${status}"
}

not_ok() {
    declare message="$@"
    declare status="FAILED"
    # printf "${RESTORE_CURSOR}%-70s   ${RED}%-7s${RESET}\n" "${message}" "${status}"
    # printf "${RED}%-7s${RESET}   %-70s\n" "${status}" "${message}"
    printf "${RED}%-7s${RESET}\n" "${status}"
    [[ -n "${message}" ]] && {
        printf "${YELLOW}REASON${RESET}  %-.70s\n" "${message}"
    }
}

active() {
    declare message="$@"
    declare status="ACTIVE"
    printf "${YELLOW}%-7s${RESET} %-.70s\r" "${status}" "${message}"
}

