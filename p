#!/bin/bash 

#= Options for the flags
OPT_OPTS=":c:a:b-:"

while getopts "$OPT_OPTS" OPTION; do
    case "${OPTION}" in
        -)
            case "${OPTARG}" in
                arg ) echo "LONG: arg: $1"; exit;
                ;;
                bool ) echo "LONG: bool"; exit;
                ;;
                *)  error "${SCRIPT_NAME}: -$OPTARG: option requires an argument"
                    OPT_ERR=1
                ;;
            esac
        ;;
        b ) echo "SHORT: bool B";
        ;;
        a ) echo "SHORT: arg A: $2";
        ;;
        c ) echo "SHORT: arg C: $2";
        ;;
        : ) echo "${SCRIPT_NAME}: -$OPTARG: option requires an argument"
            exit 1;
        ;;
        ? ) echo "${SCRIPT_NAME}: -$OPTARG: unknown option"
            exit 1;
        ;;
        *)  echo "${SCRIPT_NAME}: -$OPTARG: option requires an argument"
            exit 1;
        ;;
    esac
done
shift $((${OPTIND} - 1)) ## shift options

#show_commands

exit
