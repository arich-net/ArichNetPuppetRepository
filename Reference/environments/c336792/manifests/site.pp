#
# Site.pp for environment: c336792
#
# Global
import "/etc/puppet/manifests/nodes/*.pp"
import "/etc/puppet/manifests/baselines/*.pp"
import "/etc/puppet/manifests/roles/*.pp"
import "/etc/puppet/manifests/defaults.pp"
import "/etc/puppet/manifests/exec.pp"
# Local to environment
import "baselines/*.pp"
import "nodes/*.pp"
import "roles/*.pp"
import "defines.pp"