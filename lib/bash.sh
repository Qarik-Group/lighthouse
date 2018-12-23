#!/usr/bin/env bash

need_bash_minimum_version()
{
    case $# in
        0)
            true
            ;;
        1)
            ((${BASH_VERSINFO[0]} >= $1))
            ;;
        2)
            ((${BASH_VERSINFO[0]} > $1 || (${BASH_VERSINFO[0]} == $1 && ${BASH_VERSINFO[1]} >= $2) ))
            ;;
        3)
            (( ${BASH_VERSINFO[0]} > $1 ||
              (${BASH_VERSINFO[0]} == $1 && ${BASH_VERSINFO[1]} > $2) ||
              (${BASH_VERSINFO[0]} == $1 && ${BASH_VERSINFO[1]} == $2 && ${BASH_VERSINFO[2]} >= $3) ))
            ;;
        *)
            false
            ;;
    esac
}
