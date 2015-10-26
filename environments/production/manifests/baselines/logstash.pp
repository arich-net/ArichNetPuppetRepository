# Logstash class for environment production
class production::logstashenv {
   ########################
   #    START LOGSTASH    #
   ########################
   class { 'logstash': }
   
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
      order   => 10
   }
   ########################
   #     END LOGSTASH     #
   ########################
}
