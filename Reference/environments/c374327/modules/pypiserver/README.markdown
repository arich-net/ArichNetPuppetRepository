####Table of Contents

1. [Overview](#overview)
2. [Setup - The basics of getting started with pypiserver](#setup)
    * [What pypiserver affects](#what-pypiserver-affects)
    * [Beginning with pypiserver](#beginning-with-pypiserver)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)

##Overview

Apache based [pypiserver](https://github.com/schmir/pypiserver) Pypi compatible
mirror Puppet module.

##Setup

###What pypiserver affects

This module will install pypiserver from Pypi and will setup an Apache vhost
for it, keeping all packages under /var/www/pypi/packages by default.

###Beginning with pypiserver

You just need to include this module with desired options:

```puppet
class { 'pypiserver':
  user_hash => {'username' => 'password'},
}
```

##Usage

Put the classes, types, and resources for customizing, configuring, and doing the fancy stuff with your module here.

##Reference

### Classes

#### pypiserver

This is the main entry point for this module and the only class that should be
used in your manifests.

*docroot*

The docroot for your Apache vhost (same parameter as puppetlabs-apache
apache::vhost type). By default, /var/www/pypi.

*server_name*

The server name for your Apache vhost (resource name for your puppetlabs-apache
apache::vhost). By default, pypi.$domain.

##Limitations

This module has been tested only with Ubuntu 12.04 and CentOS 6.
