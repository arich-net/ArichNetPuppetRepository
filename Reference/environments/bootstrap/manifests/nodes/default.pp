# # bootstrap environment default node
#
# This is used for nodes coming online from a new build.
node default {
  notify { "Welcome to the bootstrap environment": }

  class { 'core::default': puppet_environment => 'bootstrap', }

  class { 'mcollective::server': }

  case $::operatingsystem {
    /(?i)(debian|ubuntu)/ : { include apt }
    /(?i)(redhat|centos)/ : { include yum }
  }

  # Check if enable_build => true, then include bootstrap class
  # We use case statment here so we can slowly migrate the builds
  $enable_build = hiera(enable_build)
  $is_template = false

  # Assign DEDICATED containers for template creation
  $template_nodes = ['evl3301470','evw3300319']
  
  if $enable_build["data"]["enable_build"] {
    notify { "enable_build is set to true, building the system..": }

    case $::operatingsystem {
      /(?i)(centos|redhat|ubuntu|debian)/ : {
        if $::hostname in $template_nodes {
          notify { "Starting bootstrap::build_template for $::hostname": }
          class { 'bootstrap::build_template': }
        } else {
          notify { "Starting bootstrap for $::hostname": }
          class { 'bootstrap::default': }
        }
      }
    }

  } else {
    notify { "enable_build is set to false, not building..": }
  }

}
