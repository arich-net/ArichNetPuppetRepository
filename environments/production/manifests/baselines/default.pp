# Default class for environment production
class production::defaultenv {
   class { 'deploy':
      tempdir => '/tmp',      
   }   
}
