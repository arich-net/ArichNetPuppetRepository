####Table of Contents

1. [Overview](#overview)
2. [Setup - The basics of getting started with mng_server](#setup)
    * [What mng_server affects](#what-mng_server-affects)
    * [Beginning with mng_server](#beginning-with-mng_server)
3. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
4. [Limitations - OS compatibility, etc.](#limitations)

##Overview

[monitoring-ng](https://confluence.ntt.eu/display/AMMONIT/AM%3A+Monitoring+Home)
server Puppet module. This module will also manage all related services to the
server side: database, MCollective middleware,...

##Setup

###What mng_server affects

* monitoring-ng web interface (to be done)
* monitoring-ng STOMP worker (to be done)
* monitoring-ng Celery agents (to be done)
* ActiveMQ as MCollecive middleware (development only purposes)
* PostgreSQL as database (to be done)
* Riemann as event stream processor (to be done)

###Beginning with mng_server

This module doesn't has any special requirement in order to be used, check
dependencies for their requirements.

##Reference

### Classes

*mng_server*

monitoring-ng web server manifest.

* allowed_hosts: a string containing a list of comma separated allowed hosts
  (see Django docs.), by default *server_name* is used.
* fixtures: a hash containing required Django fixtures, see
  spec/acceptance/mng_server_pec.rb for examples. Default is empty hash.
* fixtures_dir: The directory where Django fixtures reside. Default is
  /var/lib/ntteam_fixtures.
* ipaddress: this is the IP address used when *manage_host* is set to true.
* manage_host: whether we should add an entry to /etc/hosts or not (the host
  FQDN must be resolvable). If you set it to true, then a host definition will
  be added with `ip` set to *ipaddress* parameter. False by default.
* ntteam_root: Directory containing monitoring-ng packages shared files. By
  default /usr/share/ntteam.
* server_name: Apache vhost server name, by default "mng.$domain".
* src_root: Directory containing Python code, by default
  /usr/lib/python2.7/dist-packages.

*mng_server::activemq*

Development only ActiveMQ manfiest, just a NTT module fork for development only
purposes:

* config_file: Template used for ActiveMQ configuration file, by default
  mng_server/activemq.xml.erb.
* console: Whether ActiveMQ web console should be enabled or not, enabled by
  default.
* memory_usage: ActiveMQ memory usage configuration parameter, 20 Mb by default.
* middleware_admin_password: Admin user password, by default 'changeme'.
* middleware_admin_user: Admin user, by default 'admin'.
* middleware_password: User name clients will be using for connecting, by
  default 'mcollective'.
* middleware_port: ActiveMQ STOMP listening port, by default 61613.
* storage_usage: ActiveMQ storage usage configuration parameter, by default
  1 Gb.
* temp_usage: ActiveMQ temporal directory usage parameter, by default 100 Mb.

*mng_server::broker*

Celery broker support:

* address: bind address
* admin: Whether RabbitMQ user should be administrator or not, false by default.
* delete_guest_user: Whether we should delete the guest user or not, false by
  default.
* password: RabbitMQ user password
* user: RabbitMQ user name
* vhost: RabbitMQ vhost, '/' by default.


*mng_server::db*
monitoring-ng database manifests. It supports creating monitoring-ng Django and
Graphite databases, as well as Django testing database.:

* backend: Database backend, by default postgresql
* django_address: Hosts from which we can connect to this database (where
  needed), by default 127.0.0.1
* django_database: Django database name, by default 'management'
* django_password: Django database password, by default 'management'
* django_user: Django database user, by default 'management'
* graphite_address: Same as Django
* graphite_database: Same as Django, default 'graphite'
* graphite_password: Same as Django, default 'graphite'
* graphite_user: Same as Django, default 'graphite'
* listen_addresses: Server listening interfaces (where needed), by default
  undef (== localhost)
* manage_firewall: Whether we should manage server database firewall or not
  (where needed), true by default.
* manage_django_db: Whether we should manage Django database or not
* $manage_django_test_db: Same for Django testing database
* $manage_graphite_db: Same for Graphite database
* $server_password: Database server password (where needed)

*mng_server::params*

monitoring-ng parameters class. This manifest will allow you override common
options for more monitoring-ng manifests (web and workers).

* activemq_host: by default 'localhost'
* activemq_password: by default 'marionette'
* activemq_port: by default 61613
* activemq_user: by default 'mcollective'
* broker_url: Celery broker URL, by default 'amqp://guest:guest@localhost:5672//'
* database_url: monitoring-ng Django database URL, by default
  'sqlite:///var/lib/ntteam/monitoring.db'
* debug: Django DEBUG setting, by default false.
* graphite_url: Graphite URL for monitoring-ng web service, by default
  http://graphite.atlasit.local
* nexus_sab_password: by default 'changeme'
* riemann_host: by default 'localhost'
* secret_key: by default 't7qk!2og26)%71aq@l&1d887_+mbvvhl#v0&c5d6*ao_(1hfl='
* settings: Django settings module, by default ntteam.management.settings.prod

This manifest also provides two variables that cannot be changed:

* wrapper: This file contains contains environment variables and can be used as
  bash script for wrapping any monitoring.ng.web command. Its value is
  '/etc/cleng/monitoring_ng_rc'.
* sh_wrapper: This variable adds a shell to the *wrapper* value, so it can be
  used for users without a shell. Its value is '/bin/bash $wrapper'.

*mng_server::riemann*

Riemann server and dashboard manifest, just a wrapper over _riemann_ module
with our own configuration:

* bind: Riemann bind address, '127.0.0.1' by default
* django_host_ip: monitoring-ng Django IP address, undefined by default.
* django_host: monitoring-ng Django host, default localhost.
* graphite_host_ip: monitoring-ng Graphite IP address, undefined by default.
* graphite_host: monitoring-ng Graphite host, default localhost.
* manage_django_host: Whether we should add a host entry for Django server
  or not, false by default.
* manage_graphite_host: Whether we should add a host entry for Graphite server
  or not, false by default.

*mng_server::workers*

Celery and monitoring-ng STOMP Supervisor based workers job management:

* celery_beat: Whether we should manage Celery beat or not, true by default.
* celery_flower: Same for Celery flower.
* celery_worker: Same for Celery worker.
* env: Array of environment variables to be set for all supervisor workers.
* flower_port: Listening port for Celery flower daemon, by default 5555.
* groups: Extra groups Supervisor jobs user should belong to. By default undef.
* pids_dir: Celery daemons pid files directory, by default '/var/run/celery'.
* stomp_worker: Same for STOMP worker.
* user: Supervisor jobs user, by default 'celery'

##Limitations

###ActiveMQ

SSL is not supported and it probably won't be ever supported, since we will be
using NTT ActiveMQ deployment for production.

### Broker

Only RabbitMQ is supported.

### Database

Only PostgreSQL is supported.

### Web

Only Apache is supported.
