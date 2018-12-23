#!/usr/bin/env bash

# args [major] [minor] [patch]
need_bash_minimum_version()
{
    case $# in
        0)
            true
            ;;
        1)
            [[ $1 =~ ^[0-9]+$ ]] && ((${BASH_VERSINFO[0]} >= $1))
            ;;
        2)
            [[ $1 =~ ^[0-9]+$ && $2 =~ ^[0-9]+$ ]] && 
            ((${BASH_VERSINFO[0]} > $1 || (${BASH_VERSINFO[0]} == $1 && ${BASH_VERSINFO[1]} >= $2) ))
            ;;
        3)
            [[ $1 =~ ^[0-9]+$ && $2 =~ ^[0-9]+$ && $3 =~ ^[0-9]+$ ]] && 
            (( ${BASH_VERSINFO[0]} > $1 ||
              (${BASH_VERSINFO[0]} == $1 && ${BASH_VERSINFO[1]} > $2) ||
              (${BASH_VERSINFO[0]} == $1 && ${BASH_VERSINFO[1]} == $2 && ${BASH_VERSINFO[2]} >= $3) ))
            ;;
        *)
            false
            ;;
    esac
}
