# Class: yum::setup
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class yum::setup {

    require yum::params

    # Purge /etc/yum.repos.d contents if yum_clean_repos is true
    file { "yum_repos_d":
        path => '/etc/yum.repos.d/',
        ensure => directory,
        recurse => true,
        purge => $yum::params::clean_repos ? {
            true => true,
            false => false,
        },
        force => true,
        ignore => ".svn",
        mode => 0755, owner => root, group => 0;
    }

	#
    # gpg key /etc/pki/rpm-gpg/
    #
    $lcase_os = inline_template("<%= operatingsystem.downcase -%>")
    file { "rpm_gpg":
        path => '/etc/pki/rpm-gpg/',
        source => "puppet:///yum/${lcase_os}/rpm-gpg/",
        recurse => true,
        # purge => $yum::params::clean_repos ? {
        # true => true,
        # false => false,
        # },
        ignore => ".svn",
        owner => root,
        group => 0,
        mode => '600',
    }
    
}


