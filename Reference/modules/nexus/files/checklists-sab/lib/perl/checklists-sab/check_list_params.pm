package check_list_params;
use strict;
use warnings;

our $optional;
our $required;
our $script_config;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw($optional $required $script_config);

$optional = [
   qw(
             debug
             defaultGw
             snmpCommunity
             hostIp
             passFor
             pass
             raidDetails
             raidLevel
             type
             status
             osVersion
             os
             dataCenter
             systemName
             managementIp
             networkInterfaceIp
             networkInterfaceName
             networkInterfaceMAC
             allNetworkInterface
     )
            ];

$required = [
  qw(
          script
          run_uid
          log_limit
   )
  ];
$script_config = {
     'ls' =>{

            }
};
1;