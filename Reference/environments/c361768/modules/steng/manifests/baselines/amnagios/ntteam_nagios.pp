class steng::baselines::amnagios::ntteam_nagios{
  package{["ntteam-scripts-base","ntteam-nrpe","ntteam-nrpe-plugins-base"]:
    ensure => latest,
  }
}
