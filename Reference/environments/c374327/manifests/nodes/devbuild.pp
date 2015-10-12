node /^slave*/ {
  include 'ci::jenkins::slave'
}

node devbuild {
  include 'ci'
  include 'ci::projects::monitoring_ng'
  include 'ci::projects::packaging'
  include 'ci::projects::ruby'
  include 'ci::projects::pentest'
}
node devbuild_ubuntu inherits devbuild {}
node "VM00734" inherits devbuild {}
