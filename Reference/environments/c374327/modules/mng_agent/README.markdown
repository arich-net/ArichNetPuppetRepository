####Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup - The basics of getting started with mng_agent](#setup)
    * [What mng_agent affects](#what-mng_agent-affects)
    * [Beginning with mng_agent](#beginning-with-mng_agent)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)

##Overview

[monitoring-ng](https://confluence.ntt.eu/display/AMMONIT/AM%3A+Monitoring+Home)
agent Puppet module. This module will also manage MCollective, since the agent
depends on it.

##Setup

###What mng_agent affects

* monitoring-ng agent
* monitoring-ng plugins
* MCollective (package, service, plugins,...)

###Beginning with mng_agent

In order to use this module just include it in your manifests, see an example:

```puppet
class { 'mng_agent':
  mco_middleware_hosts => ['localhost'],
}
```

MCollective can be configured using the same options from the na_mcollective
module, but prefixed with *mco_* (as you can see in the example above).

##Usage

##Reference

### Classes

*mng_agent*

Right now it only support a subset of na_mcollective options:

* mco_client
* mco_server
* mco_main_collective
* mco_collectives
* mco_middleware_admin_password
* mco_middleware_admin_user
* mco_middleware_hosts
* mco_middleware_password
* mco_middleware_port
* mco_middleware_ssl
* mco_middleware_ssl_port
* mco_middleware_user
* mco_server_daemonize
* mco_server_logfile
* mco_server_loglevel
* mco_securityprovider
* mco_client_logger_type
* mco_client_loglevel

##Limitations

This module, so far, only works for CentOS 6 due to the *cleng* module
limitations (we have support only for CentOS 6 repository).

This module do not support configuration changes yet, so default configuration
from the package will be used.
