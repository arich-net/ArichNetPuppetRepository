# Logstash class for environment production
class production::logstashenv(
  $lookup              = false,
  $lookuptable         = undef
) {
   ########################
   #    START LOGSTASH    #
   ########################
   file { '/usr/lib/x86_64-linux-gnu/libcrypt.so':
     ensure => 'link',
     target => '/lib/x86_64-linux-gnu/libcrypt.so.1',
   }

   class { 'logstash': 
     status => 'enabled',
     restart_on_change => true,
     require => File['/usr/lib/x86_64-linux-gnu/libcrypt.so'],
   }      
      
   logstash::configfile { "output_${hostname}":
      content => template("/opt/puppetmaster/codedir/environments/${environment}/templates/logstash/output_${hostname}.erb"),
      order   => 30
   }
   logstash::configfile { "input_${hostname}":
      content => template("/opt/puppetmaster/codedir/environments/${environment}/templates/logstash/input_${hostname}.erb"),
      order   => 10
   }
   logstash::configfile { "filter_${hostname}":
      content => template("/opt/puppetmaster/codedir/environments/${environment}/templates/logstash/filter_${hostname}.erb"),
      order   => 20
   }
   logstash::patternfile { "patterns_${hostname}":
      source => "puppet:///path/to/extra_patterns",
      filename => "patterns_${hostname}",
      template => "/opt/puppetmaster/codedir/environments/${environment}/templates/logstash/patterns_${hostname}.erb",
   }

   #logstash::plugin { 'logstash-filter-translate': }
   
   # Install GeoLite Data
   deploy::file { "GeoLiteCity.tar.gz":
      target => '/etc/logstash/geolitecity',
      url => "http://${geoliteserver}/logstash",
      strip => true,
      strip_level => 0,
      require => Class['deploy'],   
   }
   
   # Include lookup tables if needed   
   if ($lookup) {
     notify { "Using template /opt/puppetmaster/codedir/environments/${environment}/templates/logstash/lookup-${lookuptable}_${hostname}.erb": }
     file { '/etc/logstash/lookups':
       ensure => 'directory',
     }
     file { "/etc/logstash/lookups/lookup-${lookuptable}.yaml":
       ensure => file,
       content => template("/opt/puppetmaster/codedir/environments/${environment}/templates/logstash/lookup-${lookuptable}_${hostname}.erb"),
       require => File["/etc/logstash/lookups"],
     }
   }
   ########################
   #     END LOGSTASH     #
   ########################
}
