class test-file {
    file { "/tmp/core_test-file":
       ensure => present,
       mode   => 644,
       owner  => root,
       group  => root,
    }
}
