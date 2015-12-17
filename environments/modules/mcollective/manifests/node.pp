# == Class: mcollective::node
#
# This class provides a simple way to deploy an MCollective node.
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
#   ['security_ssl_private'] - If SSL is used, the path to the SSL
#                              private key (shared).
#   ['security_ssl_public']  - If SSL is used, the path to the SSL
#                              public key (shared).
#   ['security_aes_private'] - If AES is used, the path to the AES
#                                     private server key (shared).
#   ['security_aes_public']  - If AES is used, the path to the AES
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
#   ['rpcauthorization']  - Whether to use RPC authorization.
#                           False by default.
#   ['rpcauthprovider']   - The RPC authorization plugin to use.
#                           Defaults to 'action_policy'.
#   ['rpcauth_allow_unconfigured'] - Whether to allow unconfigured agents
#                                    with RPC auth. Values are '0' or '1'.
#                                    Defaults to '0'.
#   ['rpcauth_enable_default']     - Whether to enable RPC authorization
#                                    by default. Values are '0' or '1'.
#                                    Defaults to '1'.
#   ['cert_dir']          - Path to the client certificates directory.
#                           Defaults to '/etc/mcollective/ssl/clients'.
#   ['policies_dir']      - Path to the policies directory.
#                           Defaults to '/etc/mcollective/policies'.
#   ['direct_addressing'] - Enable direct addressing.
#                           Defaults to '0'.
#   ['registration']      - The registration plugin to use
#                           Defaults to 'AgentList.
#   ['registerinterval']  - Registration interval
#                           Defaults to '300'.
#   ['registration_collective']    - The registration collective to use
#                                    Defaults to undef.
#   ['ssl_source_dir']    - Where to get certificates from.
#                           Defaults to undef.
#   ['identity']          - The node's identity
#
# === Actions
#
# - Deploys an MCollective node
#
# Sample Usage:
#   class { '::mcollective::node':
#     broker_host       => 'rabbitmq.example.com',
#     broker_port       => '61614',
#     security_provider => 'psk',
#     security_secret   => 'P@S5w0rD',
#   }
#
#   class { '::mcollective::node':
#     broker_host                 => 'rabbitmq.example.com',
#     broker_port                 => '61614',
#     security_provider           => 'ssl',
#   }
#
class mcollective::node (
  $broker_host = $mcollective::broker_host,
  $broker_port = $mcollective::broker_port,
  $security_provider = $mcollective::security_provider,
  $broker_vhost = $mcollective::broker_vhost,
  $broker_user = $mcollective::broker_user,
  $broker_password = $mcollective::broker_password,
  $broker_ssl = $mcollective::broker_ssl,
  $broker_ssl_cert = "/var/lib/puppet/ssl/certs/${::clientcert}.pem",
  $broker_ssl_key = "/var/lib/puppet/ssl/private_keys/${::clientcert}.pem",
  $broker_ssl_ca = '/var/lib/puppet/ssl/certs/ca.pem',
  $security_secret = $mcollective::security_secret,
  $security_ssl_private = $mcollective::security_ssl_server_private,
  $security_ssl_public = $mcollective::security_ssl_server_public,
  $security_aes_private = $mcollective::security_aes_server_private,
  $security_aes_public = $mcollective::security_aes_server_public,
  $security_aes_send_pubkey = $mcollective::security_aes_send_pubkey,
  $security_aes_learn_pubkeys = $mcollective::security_aes_learn_pubkeys,
  $security_aes_enforce_ttl = $mcollective::security_aes_enforce_ttl,
  $connector = $mcollective::connector,
  $puppetca_cadir = $mcollective::puppetca_cadir,
  $rpcauthorization = $mcollective::rpcauthorization,
  $rpcauthprovider = $mcollective::rpcauthprovider,
  $rpcauth_allow_unconfigured = $mcollective::rpcauth_allow_unconfigured,
  $rpcauth_enable_default = $mcollective::rpcauth_enable_default,
  $cert_dir = $mcollective::cert_dir,
  $policies_dir = $mcollective::policies_dir,
  $direct_addressing = $mcollective::direct_addressing,
  $ssl_source_dir = $mcollective::ssl_source_dir,
  $registration = $mcollective::registration,
  $registration_collective = $mcollective::registration_collective,
  $registerinterval = $mcollective::registerinterval,
  $ensure_service = $mcollective::node_ensure_service,
  $identity = $mcollective::node_identity,
  $collectives = $mcollective::collectives,
  $main_collective = $mcollective::main_collective,
) {

  if !defined(Class['::mcollective']) {
    fail ('You must declare the mcollective class before the mcollective::node class')
  }

  include ::mcollective::params
  include ::ruby::gems

  anchor { 'mcollective::node::begin': } ->
  class { '::mcollective::node::packages': } ->
  class { '::mcollective::node::factsource::yaml': } ->
  class { '::mcollective::node::files': } ~>
  class { '::mcollective::node::service': } ->
  anchor { 'mcollective::node::end': }
}
