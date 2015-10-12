class steng::backup::ecpackages{
  package{["ftp","nmap","ksh","apr","gcc","lynx","subversion"]:
    ensure => latest,
  }
  package{["httpd","httpd-tools","mod_ssl"]:
    ensure => absent,
  }
}
