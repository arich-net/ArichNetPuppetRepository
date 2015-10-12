#
# Environment template : Site.pp
#
# Global imports
import "/etc/puppet/manifests/nodes/*.pp"
import "/etc/puppet/manifests/baselines/*.pp"
import "/etc/puppet/manifests/roles/*.pp"
import "/etc/puppet/manifests/defaults.pp"
import "/etc/puppet/manifests/exec.pp"
# Local imports
import "baselines/*.pp"
import "nodes/*.pp"
import "roles/*.pp"
import "defines.pp"

