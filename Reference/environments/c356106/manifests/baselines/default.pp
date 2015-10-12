# Default.pp
# Use to specify default classes/defines for this specific environment
# 
# WARNING :: This will be applied to all systems defined in this environment
#
# Modify and uncomment the below to use
#
# class $::environment::default {
#
# }
class c356106::default {
  # Move to a move global scope as its used for all modules?
  # i.e core::default?
  include concat::setup
  class { 'nttedir': envsource => true }
}