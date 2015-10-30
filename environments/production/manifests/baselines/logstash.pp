# Logstash class for environment production
class production::logstashenv {
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
   
   # Install GeoLite Data
   deploy::file { "GeoLiteCity.tar.gz":
      target => '/etc/logstash/geolitecity',
      url => "http://${geoliteserver}/logstash",
      strip => true,
      strip_level => 0,
      require => Class['deploy'],   
   }
   ########################
   #     END LOGSTASH     #
   ########################
}
