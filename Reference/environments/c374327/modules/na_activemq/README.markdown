####Table of Contents

1. [Overview](#overview)
2. [Setup - The basics of getting started with na_activemq](#setup)
    * [What na_activemq affects](#what-na_activemq-affects)
    * [Beginning with na_activemq](#beginning-with-na_activemq)
3. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
4. [Limitations - OS compatibility, etc.](#limitations)

##Overview

[monitoring-ng](https://confluence.ntt.eu/display/AMMONIT/AM%3A+Monitoring+Home)
ActiveMQ Puppet module for development purposes only, since we will use NTT
cluster for production.

##Setup

###What na_activemq affects

ActiveMQ as a MCollecive middleware.

###Beginning with na_activemq

This module doesn't have any special requirement.

##Reference

### Classes

*na_activemq*

Parameters:

* activemq_config: an string representing the template to be used for
  _activemq.xml_ configuration file, by default na_activemq/activemq.xml.erb.
* apache_mirror: the base URL for downloading ACtiveMQ's tarball. By default
  http://archive.apache.org/dist
* group: ActiveMQ files group, by default _activemq_.
* home: ACtiveMQ home parents directory, where all ActiveMQ files will be
  placed. By default /opt.
* user: ActiveMQ files owner and the user that will run the service. By default
  _activemq_.
* version: ActiveMQ version, by default 5.5.0

##Limitations

SSL and LDAP are not supported and it probably won't be ever supported, since we
will be using NTT ActiveMQ deployment for production. Only tested with
Ubuntu 14.04.
