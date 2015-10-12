#
# Environment template : Site.pp
#
# Global imports
import "/etc/puppet/manifests/baselines/*.pp"
import "/etc/puppet/manifests/defaults.pp"
import "/etc/puppet/manifests/exec.pp"
# Local imports
import 'nodes/default.pp'
import 'ntteam.pp'
