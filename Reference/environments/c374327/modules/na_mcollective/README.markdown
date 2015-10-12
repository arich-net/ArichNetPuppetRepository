####Table of Contents

1. [Overview](#overview)
2. [Setup - The basics of getting started with na_mcollective](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Development - Configuration options and additional functionality](#development)

##Overview

NTTEAM manifests for MCollective using CLENG packages. This module wraps
Puppetlabs MCollective module.

##Setup

See [Puppetlabs/Mcollective module](https://github.com/puppetlabs/puppetlabs-mcollective),
since this module is just a wrapper.

##Usage

This module will help you setting up MCollective servers/clients with CLENG
packages, providing almost the same interface as the Puppetlabs module:

```puppet
class { 'na_mcollective':
  middleware_hosts => [ 'broker1.example.com' ],
}
```

### The `na_mcollective` class

The `na_mcollective` class is the main entry point to the module. From here you
can configure the behaviour of your MCollective install of server or client.
Since this module is just a wrapper over puppetlbas/mcollective, most
parameters are the same and they have the same defaults, exceptions:

#### `core_libdir`

Sring: defaults to '/opt/cleng/libexec/mcollective/'. This directory changes on
cleng pacakges, so we need change the default value.

#### `site_libdir`

String: defaults to '/opt/cleng/local/libexec/mcollective/'. This directory changes
on cleng pacakges, so we need change the default value.

#### `classfile`

String: defaults to '/var/opt/lib/cleng-puppet/state/classes.txt'. cleng-puppet
libdir directory changes, so we need change the default value.

#### `confdir`

String: defaults to '/etc/cleng/mcollective'. The MCollective configuration
directory.

#### `server_logfile`

String: defaults to '/var/log/cleng-mcollective/mcollective.log'. cleng-mcollective
package changes the default logging directory, so we need to change the default
value.

#### `securityprovider`

String: defaults to 'none'. For development the 'none' provider is the best
option, since it enables very easy debugging.

#### `mco_manage_packages`

Boolean: defaults to false. mcollective::manage_packages value.

#### `packages_ensure`

String: defaults to undef. CLENG MCollective packages ensure value.

#### `service_name`

String: defaults to 'cleng-mcollective'. MCollective service name.

### The `na_mcollective::puppetlabs` class

Temporal class created for supporting MCollective deployment based on Puppetlabs
packages under Ubuntu 14.04. This class should be removed as soon as CLENG
repository includes packages for MCollective.

#### `middleware_hosts`

Array: defaults to []. Same configuration option as mcollective module.

## Development

Running acceptance is not fully supported yet and you should have clones for
MCollective and Cleng modules at the same level than this module (since both
module are installed from local clones).
