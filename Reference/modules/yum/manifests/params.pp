# Class: yum::params
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
class yum::params {

# Manage Automatic Updates method
    $update = $yum_update ? {
        "cron" => "cron",
        "updatesd" => "updatesd",
        default => "off",
    }

# We Need EPEL for many modules: let's enable it by default
    $extrarepo = $yum_extrarepo ? {
        "" => "epel",
        default => $yum_extrarepo,
    }

# If existing /etc/yum.repos.d/ contents are purged (so that Puppet entirely controls it) or left as is
    $clean_repos = $yum_clean_repos ? {
         "" => false,
         "yes" => true,
         true => true,
         "true" => true,
         default => true,
    }

}