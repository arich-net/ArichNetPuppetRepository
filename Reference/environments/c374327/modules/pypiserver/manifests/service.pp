# == Class pypiserver::service
#
# This class is meant to be called from pypiserver
# It ensure the service is running
#
class pypiserver::service {
  include '::apache'
  include '::apache::mod::wsgi'

  File {
    owner => $apache::params::user,
  }

  mkdir_p("${pypiserver::docroot}/packages")

  if $pypiserver::manage_host {
    # Ensure the host know how to resolve this address
    host { $pypiserver::server_name_real:
      ip => '127.0.0.1',
    }
  }

  file { "${pypiserver::docroot}/wsgi.py":
    content => inline_template("PACKAGES = '${pypiserver::docroot}/packages'
HTPASSWD = '${pypiserver::docroot}/htpasswd'

import pypiserver
application = pypiserver.app(PACKAGES,
                             redirect_to_fallback=True,
                             password_file=HTPASSWD)
"),
  }

  $user_hash = $pypiserver::user_hash
  file { "${pypiserver::docroot}/htpasswd":
    content => inline_template("<% @user_hash.each_pair do |user,password| -%>
<%= user %>:<%= password %>
<% end -%>"),
  }

  apache::vhost { $pypiserver::server_name_real:
    port                => 80,
    custom_fragment     => 'WSGIPassAuthorization On',
    docroot             => $pypiserver::docroot,
    wsgi_script_aliases => { '/' => "${pypiserver::docroot}/wsgi.py" },
  }
}
