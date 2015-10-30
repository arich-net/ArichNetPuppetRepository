# Logstash class for environment production
class production::javaenv {
   #####################
   #    START JAVA     #
   #####################    
   
   deploy::file { "jre-8u65-linux-${architecture}.tar.gz":
      target => '/opt/java/jdk',
      url => "http://${serverjava}/packages/${architecture}",
      strip => true,
      require => Class['deploy'],   
   }

   alternative_entry { '/opt/java/jdk/bin/java':
     altlink => '/usr/bin/java',
     altname => 'java',
     priority => 1,
     require => Deploy::File["jre-8u65-linux-${architecture}.tar.gz"],
   }
   
   #####################
   #     END JAVA      #
   #####################
  
}
