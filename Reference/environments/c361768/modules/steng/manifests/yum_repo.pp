define steng::yum_repo ($reponame=$title,$baseurl=undef,$enabled=1,$gpgcheck=0,$sslverify=0){
  file{"/etc/yum.repos.d/$reponame.repo":
    ensure=>present,
    owner=>root,
    group=>root,
    mode =>0644,
    content => template("${module_name}/etc/yum.repos.d/yum_repo.erb")
  }
}
