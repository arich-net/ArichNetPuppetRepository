class test-file_2 {
    file { "/tmp/test-file":
       ensure => present,
       mode   => 644,
       owner  => root,
       group  => root,
       content => template("test-file/test-file.erb"),
    }
}
