# == Definition: mcollective::actionpolicy
#
# Sets up an action policy for an MCollective agent.
#
# See http://projects.puppetlabs.com/projects/mcollective-plugins/wiki/AuthorizationActionPolicy
# for informations on how action policy rules.
#
# You should declare mcollective::node before using this.
# You should also declare an mcollective::actionpolicy::base resource
# for the agent you wish to add a rule to.
#
# === Parameters
#
#   ['ensure']         - Whether the policy rule should be present or absent.
#   ['agent']          - The agent to which to apply the policy rule.
#                        If unspecified, the resource title will be
#                        parsed as '$rpccaller@$agent'.
#   ['rpccaller']      - The rpc caller (e.g. 'cert=foo' or 'uid=1001')
#                        If unspecified, the resource title will be
#                        parsed as '$rpccaller@$agent'.
#   ['auth']           - Auth rule ('allow' or 'deny').
#                        Defaults is 'allow'.
#   ['rule_actions']   - The array of actions managed by this rule.
#                        Defaults to ['*'].
#   ['rule_facts']     - An array of facts for which this rule applies.
#                        Defaults to ['*'].
#   ['rule_classes']   - An array of classes for which this rule applies.
#                        Defaults to ['*'].
#   ['order']          - Order for concatenation.
#                        Defaults to 50.
#
# === Actions
#
# - Deploys an MCollective Action Policy rule for an agent
#
# === Requires
#
# - `ripienaar/concat`
# - `puppetlabs/stdlib`
#
# === Sample Usage
#
#   mcollective::actionpolicy { 'Allow puppetd status for cert foo':
#     ensure         => present,
#     agent          => 'puppetd',
#     rpccaller      => 'cert=foo',
#     actions        => ['status', 'runonce'],
#   }
#
#   mcollective::actionpolicy { 'cert=foo@puppetd':
#     ensure         => present,
#   }
#
define mcollective::actionpolicy (
  $ensure = 'present',
  $agent = undef,
  $rpccaller = undef,
  $auth = 'allow',
  $rule_actions = ['*'],
  $rule_facts = ['*'],
  $rule_classes = ['*'],
  $order = '50',
) {
  $_rpccaller = $rpccaller ? {
    undef   => inline_template('<%= @name.split("@")[0] %>'),
    default => $rpccaller,
  }

  validate_re($_rpccaller, '(uid|cert)=\S+',
    "\$rpccaller must be of the form 'uid=' or 'cert=', got '${_rpccaller}'")

  $_agent = $agent ? {
    undef   => inline_template('<%= @name.split("@")[1] %>'),
    default => $agent,
  }

  validate_re($_agent, '^\S+$',
    "Wrong value for \$agent '${_agent}'")

  if !defined(Mcollective::Actionpolicy::Base[$_agent]) {
    fail("You must declare an mcollective::actionpolicy::base for agent '${_agent}' before you can declare rules for it")
  }

  if defined(Class['mcollective::node']) {
    $policies_dir = $mcollective::node::policies_dir
  } else {
    fail('You must declare the mcollective::node class before you can use mcollective::actionpolicy')
  }

  # Validate parameters
  validate_re($ensure, '^(present|absent)$',
    "\$ensure must be either 'present' or 'absent', got '${ensure}'")
  validate_re($policies_dir, '^/.*', # This should never happen
    "\$policies_dir must be a valid path, got '${policies_dir}'")
  validate_re($auth, '^(allow|deny)$',
    "\$auth must be either 'allow' or 'deny', got '${auth}'")
  validate_array($rule_actions)
  validate_array($rule_facts)
  validate_array($rule_classes)

  $fragment_title    = regsubst($name, '/', '_', 'G')
  concat::fragment { "mcollective.actionpolicy.${fragment_title}":
    ensure  => $ensure,
    order   => $order,
    target  => "${policies_dir}/${_agent}.policy",
    content => template("${module_name}/actionpolicy.erb"),
  }
}
