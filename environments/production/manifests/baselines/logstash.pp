# Logstash class for environment production
class production::logstashenv {
   ########################
   #    START LOGSTASH    #
   ########################
   class { 'logstash': 
     status => 'enabled',
     restart_on_change => true
   }
   
   $rabbit_password = hiera("rabbit_password")
      
   logstash::configfile { 'output_$hostname':
      content => template("/opt/puppetmaster/codedir/environments/${environment}/templates/logstash/output_${hostname}.erb"),
      order   => 30
   }
   logstash::configfile { 'input_$hostname':
      content => template("/opt/puppetmaster/codedir/environments/${environment}/templates/logstash/input_${hostname}.erb"),
      order   => 10
   }
   logstash::configfile { 'filter_$hostname':
      content => template("/opt/puppetmaster/codedir/environments/${environment}/templates/logstash/filter_${hostname}.erb"),
      order   => 20
   }     
   
   # Install GeoLite Data   
   archive { 'GeoLiteCity.tar.gz':
      target => '/etc/logstash/geolitecity',
      url => 'http://192.168.1.2/logstash',
      ensure => present,
      require => Deploy['deploy'],
   }
   ########################
   #     END LOGSTASH     #
   ########################
}
