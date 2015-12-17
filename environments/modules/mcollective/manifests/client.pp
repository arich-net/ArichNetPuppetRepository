# == Class: mcollective::client
#
# This class provides a simple way to deploy an MCollective client.
# It will install and configure the necessary packages.
#
# This module supports generic STOMP, ActiveMQ and RabbitMQ connectors,
# with optional SSL support.
#
# It supports PSK and SSL as authentication methods.
#
# === Parameters
#
#   ['broker_host']       - The middleware broker host to use.
#   ['broker_port']       - The middleware broker port to use.
#   ['broker_vhost']      - The middleware broker vhost to use.
#                           Currently only used with RabbitMQ.
#   ['broker_user']       - The middleware broker user to use.
#                           If set to false, the user entry will be
#                           ommited from the configuration file
#                           (useful if you want to force using
#                           environment variables instead).
#                           Setting broker_user to false will
#                           avoid setting it in client.cfg
#                           and export STOMP_USER per shell user.
#   ['broker_password']   - The middleware broker password to use.
#   ['broker_ssl']        - Whether to use stomp over SSL
#   ['broker_ssl_cert']   - If using SSL, the path to the SSL public key.
#                           Defaults to Puppet's public certicate.
#   ['broker_ssl_key']    - If using SSL, the path to the SSL private key.
#                           Defaults to Puppet's private certicate.
#   ['broker_ssl_ca']     - If using SSL, the path to the SSL CA certificate.
#                           Defaults to Puppet's CA certificate.
#   ['security_provider'] - The security provider to use.
#                           Currently supported are 'psk' and 'ssl'.
#   ['security_secret']   - If PSK is used, the value of the shared password.
#   ['security_ssl_server_public']  - If SSL is used, the path to the SSL
#                                     public server key (shared).
#   ['security_ssl_client_private'] - If SSL is used, the path to the SSL
#                                     private client key.
#   ['security_ssl_client_public']  - If SSL is used, the path to the SSL
#                                     public client key.
#   ['security_aes_client_private'] - If AES is used, the path to the AES
#                                     private server key (shared).
#   ['security_aes_client_public']  - If AES is used, the path to the AES
#                                     public server key (shared).
#   ['security_aes_send_pubkey']    - If AES is used, whether to send
#                                     the AES public key.
#   ['security_aes_learn_pubkeys']  - If AES is used, whether to learn
#                                     the AES public keys.
#   ['security_aes_enforce_ttl']    - If AES is used, whether to enforce TTL.
#   ['connector']         - The connector to use. Either 'stomp', 'activemq'
#                           or 'rabbitmq'.
#                           Defaults to 'rabbitmq'.
#   ['puppetca_cadir']    - Path to the Puppet CA directory.
#   ['cert_dir']          - Path to the client certificates directory.
#                           Defaults to '/etc/mcollective/ssl/clients'.
#   ['direct_addressing'] - Enable direct addressing.
#                           Defaults to '0'.
#   ['ssl_source_dir']    - Where to get certificates from.
#                           Defaults to undef.
#   ['default_discovery_method' ]  - The default discovery method for clients
#                                    Defaults to 'mc'
#
# === Actions
#
# - Deploys an MCollective client
#
# === Sample Usage
#
#   class { '::mcollective::client':
#     broker_host       => 'rabbitmq.example.com',
#     broker_port       => '61614',
#     security_provider => 'psk',
#     security_secret   => 'P@S5w0rD',
#   }
#
#   class { '::mcollective::client':
#     broker_host                 => 'rabbitmq.example.com',
#     broker_port                 => '61614',
#     security_provider           => 'ssl',
#   }
#
class mcollective::client (
  $broker_host = $mcollective::broker_host,
  $broker_port = $mcollective::broker_port,
  $security_provider = $mcollective::security_provider,
  $broker_vhost = $mcollective::broker_vhost,
  $broker_user = $mcollective::broker_user,
  $broker_password = $mcollective::broker_password,
  $broker_ssl = $mcollective::broker_ssl,
  $broker_ssl_cert = $mcollective::broker_ssl_cert,
  $broker_ssl_key = $mcollective::broker_ssl_key,
  $broker_ssl_ca = $mcollective::broker_ssl_ca,
  $security_secret = $mcollective::security_secret,
  $security_ssl_server_public = $mcollective::security_ssl_server_public,
  $security_ssl_client_private = $mcollective::security_ssl_client_private,
  $security_ssl_client_public = $mcollective::security_ssl_client_public,
  $security_aes_client_private = $mcollective::security_aes_client_private,
  $security_aes_client_public = $mcollective::security_aes_client_public,
  $security_aes_send_pubkey = $mcollective::security_aes_send_pubkey,
  $security_aes_learn_pubkeys = $mcollective::security_aes_learn_pubkeys,
  $connector = $mcollective::connector,
  $puppetca_cadir = $mcollective::puppetca_cadir,
  $cert_dir = $mcollective::cert_dir,
  $direct_addressing = $mcollective::direct_addressing,
  $ssl_source_dir = $mcollective::ssl_source_dir,
  $default_discovery_method = $mcollective::default_discovery_method,
) {

  if !defined(Class['::mcollective']) {
    fail ('You must declare the mcollective class before the mcollective::client class')
  }

  anchor { 'mcollective::client::begin': } ->
  class { '::mcollective::client::packages': } ->
  class { '::mcollective::client::files': } ->
  anchor { 'mcollective::client::end': }
}
