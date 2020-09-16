# vyos-script

Currently the script only prints to console and to the default file ./vyos_commands
unless you specify the -o flag with a file
```
#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    ${SCRIPT_NAME} [-hvfsn] [-a] [-o[file]] 
#%
#% DESCRIPTION
#%    static_ip is used for setting up a static ip mapping, nat rules, 
#%    and firewall rules. You need to specify the following items
#%
#%    template created by Michel VONGVILAY (https://www.uxora.com).
#%
#%
#% OPTIONS
#%    -h, --help                    print this help
#%    -V, --version                 print script information
#%    -D, --debug                   print all debug info to screen
#%    -h, --help                    show this help page
#%
#%    -a, --all                     run all modules 
#%    -f, --firewall                run firewall module
#%    -s, --static-map              run the dhcp static mapping module
#%    -n, --nat-translation         run the nat translation module
#%
#%    -d, --dry-run                 instead of running it prints all commands
#%    -o, --output                  write rules to file, default vyos_commands
#%
#% EXAMPLES
#%    ${SCRIPT_NAME} -a --dry-run
#%    ${SCRIPT_NAME} -fsno ./vyos_commands
#%    ${SCRIPT_NAME} -fsn
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
```

## FOREWARD/WARNING
currently the script does no input validation, due to that fact the print
to file flag and output to terminal flag is automatically enabled to double
check your work before possibly totally fucking up your vyos box
you'be been warned lol my bash skills may be a bit rusty

## Example Vyos Commands

### DHCP Static Mapping

- set service dhcp-server shared-network-name 'LAN' subnet '192.168.0.0/24' static-mapping 'SERVER' ip-address '192.168.0.10'
- set service dhcp-server shared-network-name 'LAN' subnet '192.168.0.0/24' static-mapping 'SERVER' mac-address '00:53:00:00:00:01'

### NAT Destination 
- set nat destination rule 10 description 'Port Forward: HTTP to 192.168.0.100'
- set nat destination rule 10 destination port '8888'
- set nat destination rule 10 inbound-interface 'eth0'
- set nat destination rule 10 protocol 'tcp'
- set nat destination rule 10 translation address '192.168.0.100'
- set nat destination rule 10 translation port '22'

### Firewall 
- set firewall name OUTSIDE-IN rule 20 action 'accept'
- set firewall name OUTSIDE-IN rule 20 destination address '192.168.0.100'
- set firewall name OUTSIDE-IN rule 20 destination port '22'
- set firewall name OUTSIDE-IN rule 20 protocol 'tcp'
- set firewall name OUTSIDE-IN rule 20 state new 'enable'

