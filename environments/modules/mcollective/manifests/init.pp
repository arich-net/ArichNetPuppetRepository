# == Class: mcollective
#
# This class provides a simple way to deploy MCollective nodes and clients.
# It will install and configure the necessary packages.
#
# This module supports generic STOMP, ActiveMQ and RabbitMQ connectors,
# with optional SSL support.
#
# It supports PSK and SSL as authentication methods.
#
# === Parameters
#
#   ['use_node']          - Whether to install an MCollective node.
#                           Defaults to true.
#   ['use_client']        - Whether to install an MCollective client.
#                           Defaults to false.
#   ['broker_host']       - The middleware broker host to use.
#                           Defaults to $::servername.
#   ['broker_port']       - The middleware broker port to use.
#                           Defaults to '61614'.
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
#                           Defaults to 'ssl'.
#   ['security_secret']   - If PSK is used, the value of the shared password.
#   ['security_ssl_server_private'] - If SSL is used, the path to the SSL
#                                     private server key (shared).
#   ['security_ssl_server_public']  - If SSL is used, the path to the SSL
#                                     public server key (shared).
#   ['security_ssl_client_private'] - If SSL is used, the path to the SSL
#                                     private client key.
#   ['security_ssl_client_public']  - If SSL is used, the path to the SSL
#                                     public client key.
#   ['security_aes_server_private'] - If AES is used, the path to the AES
#                                     private server key (shared).
#   ['security_aes_server_public']  - If AES is used, the path to the AES
#                                     public server key (shared).
#   ['security_aes_client_private'] - If AES is used, the path to the AES
#                                     private client key.
#   ['security_aes_client_public']  - If AES is used, the path to the AES
#                                     public client key.
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
#   ['node_identity']     - The node's identity
#   ['default_discovery_method' ]  - The default discovery method for clients
#                                    Defaults to 'mc'
#
# === Actions
#
# - Deploys MCollective nodes and clients
#
# === Sample Usage
#
#   class { '::mcollective':
#     broker_host       => 'rabbitmq.example.com',
#     broker_port       => '61614',
#     security_provider => 'psk',
#     security_secret   => 'P@S5w0rD',
#   }
#
#   class { '::mcollective':
#     broker_host                 => 'rabbitmq.example.com',
#     broker_port                 => '61614',
#     security_provider           => 'ssl',
#   }
#
class mcollective (
  $broker_host = $::servername,
  $broker_port = '61614',
  $security_provider = 'ssl',
  $use_node = $mcollective::params::use_node,
  $use_client = $mcollective::params::use_client,
  $broker_vhost = $mcollective::params::broker_vhost,
  $broker_user = $mcollective::params::broker_user,
  $broker_password = $mcollective::params::broker_password,
  $broker_ssl = $mcollective::params::broker_ssl,
  $broker_ssl_cert = $mcollective::params::broker_ssl_cert,
  $broker_ssl_key = $mcollective::params::broker_ssl_key,
  $broker_ssl_ca = $mcollective::params::broker_ssl_ca,
  $security_secret = $mcollective::params::security_secret,
  $security_ssl_server_private = $mcollective::params::security_ssl_server_private,
  $security_ssl_server_public = $mcollective::params::security_ssl_server_public,
  $security_ssl_client_private = $mcollective::params::security_ssl_client_private,
  $security_ssl_client_public = $mcollective::params::security_ssl_client_public,
  $security_aes_server_private = $mcollective::params::security_aes_server_private,
  $security_aes_server_public = $mcollective::params::security_aes_server_public,
  $security_aes_client_private = $mcollective::params::security_aes_client_private,
  $security_aes_client_public = $mcollective::params::security_aes_client_public,
  $security_aes_send_pubkey = $mcollective::params::security_aes_send_pubkey,
  $security_aes_learn_pubkeys = $mcollective::params::security_aes_learn_pubkeys,
  $security_aes_enforce_ttl = $mcollective::params::security_aes_enforce_ttl,
  $connector = $mcollective::params::connector,
  $puppetca_cadir = $mcollective::params::puppetca_cadir,
  $rpcauthorization = $mcollective::params::rpcauthorization,
  $rpcauthprovider = $mcollective::params::rpcauthprovider,
  $rpcauth_allow_unconfigured = $mcollective::params::rpcauth_allow_unconfigured,
  $rpcauth_enable_default = $mcollective::params::rpcauth_enable_default,
  $cert_dir = $mcollective::params::cert_dir,
  $policies_dir = $mcollective::params::policies_dir,
  $direct_addressing = $mcollective::params::direct_addressing,
  $registration = $mcollective::params::registration,
  $registerinterval = $mcollective::params::registerinterval,
  $registration_collective = undef,
  $ssl_source_dir = undef,
  $node_ensure_service = running,
  $node_identity = $mcollective::params::node_identity,
  $default_discovery_method = $mcollective::params::default_discovery_method,
  $collectives = ['mcollective'],
  $main_collective = 'mcollective',
) inherits ::mcollective::params {

  anchor { 'mcollective::begin': } ->
  class { '::mcollective::directories': } ->
  anchor { 'mcollective::end': }

  if ($use_node) {
    Anchor['mcollective::begin'] ->
    class { '::mcollective::node': } ->
    Anchor['mcollective::end']
  }

  if ($use_client) {
    Anchor['mcollective::begin'] ->
    class { '::mcollective::client': } ->
    Anchor['mcollective::end']
  }
}
