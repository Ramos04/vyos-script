#!/bin/bash
#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    ${SCRIPT_NAME} [-hv] [-o[file]] args ...
#%
#% DESCRIPTION
#%    static_ip is used for setting up a static ip mapping, nat rules, 
#%    and firewall rules. You need to specify the following items
#%
#%    template created by Michel VONGVILAY (https://www.uxora.com).
#%
#%
#% OPTIONS
#%    -h, --help                    Print this help
#%    -V, --version                 Print script information
#%    -d, --debug                   Print all commands to screen
#%    -h, --help                    show this help page
#%
#%   Global 
#%    -a, --ip-address              internal host ip address
#%    -m, --mac-address             internal host mac address
#%    -r, --rule-num                rule number
#%        --rule-desc               rule description
#%    -d, --dest-port               incoming port on the firewall
#%    -t, --tran-port               internal host port to route to 
#%    -p, --protocol                protocol used by the traffic
#%  
#%   Firewall 
#%    -i, --interface               interface on the firewall
#%    -f, --firewall                firwall name
#%
#%   DHCP Static Leasing 
#%        --net-name                dchp network name
#%        --sub-name                dhcp subnet address (eg. 192.168.0.0/24)
#%        --map-name                dhcp mapping name
#%
#% EXAMPLES
#%    ${SCRIPT_NAME} -h -v -d
#%
#================================================================
#- IMPLEMENTATION
#-    version         ${SCRIPT_NAME} 0.0.1
#-    author          Vincent Ramos (https://github.com/Ramos04)
#-    license         N/A
#================================================================
#  HISTORY
#     2020/09/15 : Ramos04 : Started the script
# 
#================================================================
#  DEBUG OPTION
#    set -n  # Uncomment to check your syntax, without execution.
#    set -x  # Uncomment to debug this shell script
#
#================================================================
# END_OF_HEADER
#================================================================

#╔═════════════════════════════════════════════════════════════════════════════╗
#║                               GLOBAL VARS                                   ║
#╚═════════════════════════════════════════════════════════════════════════════╝

  #╔═══════════════════╗
  #║    SCRIPT VARS    ║
  #╚═══════════════════╝
readonly SCRIPT_VERSION="0.0.1"
readonly SCRIPT_NAME_EXT="$(basename ${0})"                 # scriptname without path
readonly SCRIPT_NAME="${SCRIPT_NAME_EXT%.*}"                # scriptname without .sh
readonly SCRIPT_DIR="$( cd $(dirname "$0") && pwd )"        # Script Directory
readonly SCRIPT_ROOT="${SCRIPT_DIR%/*}"	                    # Add a /* depending on script depth
readonly SCRIPT_FULLPATH="${SCRIPT_DIR}/${SCRIPT_NAME}"     # Full path of the script
readonly SCRIPT_HOSTNAME="$(hostname)"                      # Hostname
readonly SCRIPT_COMMAND_FULL="${0} $*"                      # Full command
readonly SCRIPT_EXEC_ID=${$}                                # Exec ID
readonly SCRIPT_HEADSIZE=$(grep -sn "^# END_OF_HEADER" ${0} | head -1 | cut -f1 -d:)

  #╔═══════════════════╗
  #║     RULE VARS     ║
  #╚═══════════════════╝
RULE_NUM=""             # rule number to be used for nat and fw
RULE_DESC=""            # rule description

  #╔═══════════════════╗
  #║     ADDR VARS     ║
  #╚═══════════════════╝
ADDR_IP=""              # internal host ip address
ADDR_MAC=""             # internal host mac address

  #╔══════════════════╗
  #║    PORT VARS     ║
  #╚══════════════════╝
PORT_DEST=""            # port that traffic is entering fw from
PORT_TRANS=""           # port that is used to send to internal host

  #╔═══════════════════╗
  #║    PROTO VARS     ║
  #╚═══════════════════╝
PROTOCOL=""             # protocol 


  #╔═══════════════════╗
  #║   STATIC VARS     ║
  #╚═══════════════════╝
STATMAP_NET_NAME=""     # static mapping network name
STATMAP_SUB_NAME=""   # static mapping network subnet
STATMAP_MAP_NAME=""     # static mapping name

  #╔══════════════════╗
  #║     NAT VARS     ║
  #╚══════════════════╝
NAT_IFACE=""            # nat interface

  #╔══════════════════╗
  #║     FW VARS      ║
  #╚══════════════════╝
FW_NAME=""              # firewall name 

#╔═════════════════════════════════════════════════════════════════════════════╗
#║                                FUNCTIONS                                    ║
#╚═════════════════════════════════════════════════════════════════════════════╝
script_man () {
    head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "^#[%+]" | \
        sed -e "s/^#[%+]//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g";
}

script_usage () {
    head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "^#+" | \
        sed -e "s/^#+//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g";
}
cript_usage () {
    headFilter="^#+"
    head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "${headFilter}" | \
        sed -e "s/${headFilter}//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g";
}

script_version () {
    head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "^#-" | \
        sed -e "s/^#-//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g";
}

cript_version () {
    headFilter="^#-"
    head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "${headFilter}" | \
        sed -e "s/${headFilter}//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g";
}

function show_commands {
     echo -e"
╔═════════════════════════════════════════════════════════════════════════════╗
║                                ARGUMENTS                                    ║
╚═════════════════════════════════════════════════════════════════════════════╝

DHCP SERVER
═══════════
set service dhcp-server shared-network-name '$STATMAP_NET_NAME' subnet '$STATMAP_SUB_NAME' static-mapping '$STATMAP_SUB_NAME' ip-address '$ADDR_IP'
set service dhcp-server shared-network-name '$STATMAP_NET_NAME' subnet '$STATMAP_SUB_NAME' static-mapping '$STATMAP_SUB_NAME' mac-address '$ADDR_MAC'

NAT RULES
═══════════
set nat destination rule $RULE_NUM description '$RULE_DESC'
set nat destination rule $RULE_NUM destination port '$PORT_DEST'
set nat destination rule $RULE_NUM inbound-interface '$NAT_IFACE'
set nat destination rule $RULE_NUM protocol '$PROTOCOL'
set nat destination rule $RULE_NUM translation address '$ADDR_IP'
set nat destination rule $RULE_NUM destination port '$PORT_TRANS'

FIREWALL 
═══════════
set firewall name $FW_NAME rule $RULE_NUM action 'accept'
set firewall name $FW_NAME rule $RULE_NUM destination address '$ADDR_IP'
set firewall name $FW_NAME rule $RULE_NUM destination port '$PORT_TRANS'
set firewall name $FW_NAME rule $RULE_NUM protocol '$PROTOCOL'
set firewall name $FW_NAME rule $RULE_NUM state new 'enable'
"
}

#╔═════════════════════════════════════════════════════════════════════════════╗
#║                         VYATTA CFG GROUP CHECK                              ║
#╚═════════════════════════════════════════════════════════════════════════════╝
# There is a pitfall when working with configuration scripts. It is tempting to 
# call configuration scripts with “sudo” (i.e., temporary root permissions), 
# because that’s the common way on most Linux platforms to call system commands.

# On VyOS this will cause the following problem: After modifying the 
# configuration via script like this once, it is not possible to manually modify 
# the config anymore:

# This will result in the following error message: Set failed If this happens, 
# a reboot is required to be able to edit the config manually again.

# To avoid these problems, the proper way is to call a script with the vyattacfg 
# group, e.g., by using the sg (switch group) command:

#if [ "$(id -g -n)" != 'vyattacfg' ] ; then
#    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
#fi

#╔═════════════════════════════════════════════════════════════════════════════╗
#║                               PARSE ARGS                                    ║
#╚═════════════════════════════════════════════════════════════════════════════╝
# Check if args are empty
if [ $# -eq 0 ]; then
    script_usage
    exit
fi

#============================
#  PARSE OPTIONS WITH GETOPTS
#============================

  # +----------------------+
  # |-- option variables --|
  # +----------------------+

#= Gets set when an error occurs parsing flags
OPT_ERR=0

#= Change to reflect the number of options the program has
OPT_TOTAL=0

#= Options for the flags
OPT_OPTS=":hVlkseva:m:r:d:t:p:i:b:f:-:"

while getopts "$OPT_OPTS" OPTION; do
    case "${OPTION}" in
        -)
            case "${OPTARG}" in
                help ) script_man; exit;
                ;;
                version )  script_version; exit;
                ;;
                ip-address ) echo "IP ADDRESS: $2";
                ;;
                mac-address ) echo "MAC ADDRESS: $2";
                ;;
                rule-num ) echo "RULE NUM: $2"
                ;;
                dest-port) echo "DEST PORT: $2";
                ;;
                tran-port) echo "TRANS PORT: $2";
                ;;
                protocol) echo "PROTOCOL: $2";
                ;;
                interface) echo "NAT INTER: $2";
                ;;
                firewall) echo "FW NAME: $2"; 
                ;;
                rule-desc) echo "RULE DESC: $2"
                ;;
                net-name) echo "NET NAME: $2"
                ;;
                sub-name) echo "SUB NAME: $2"
                ;;
                map-name) echo "MAP NAME: $2"
                ;;
                *)  error "${SCRIPT_NAME}: -$OPTARG: option requires an argument"
                    OPT_ERR=1
                ;;
            esac
        ;;
        h ) script_man; exit 0;
        ;;
        V ) script_version; exit 0;
        ;;
        v ) echo "PH: v";
        ;;
        l ) echo "PH: l";
        ;;
        k ) echo "PH: k";
        ;;
        s ) echo "PH: s";
        ;;
        e ) echo "PH: e";
        ;;
        b)
            if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                echo "test b: $2"
                shift 2
            else
                echo "Error: Argument for $1 is missing" >&2
                exit 1
            fi
        ;;
        a ) echo "IP ADDRESS: $2";
        ;;
        m ) echo "MAC ADDRESS: $2";
        ;;
        r ) echo "RULE NUM: $2"
        ;;
        d ) echo "DEST PORT: $2";
        ;;
        t ) echo "TRANS PORT: $2";
        ;;
        p ) echo "PROTOCOL: $2";
        ;;
        i ) echo "NAT INTER: $2";
        ;;
        f ) echo "FW NAME: $2"; 
        ;;
        : ) echo "${SCRIPT_NAME}: -$OPTARG: option requires an argument"
            OPT_ERR=1; exit 1;
        ;;
        ? ) echo "${SCRIPT_NAME}: -$OPTARG: unknown option"
            OPT_ERR=1; exit 1;
        ;;
        *)  echo "${SCRIPT_NAME}: -$OPTARG: option requires an argument"
            OPT_ERR=1; exit 1;
        ;;
    esac
done
shift $((${OPTIND} - 1)) ## shift options

#show_commands

exit
