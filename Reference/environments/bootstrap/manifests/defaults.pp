##  defaults.pp
#
# All global defaults are defined in puppet/manifests/defaults.pp.
# These are overrides for those plus anything specific for this environment.
#
# Sample Usage:
# included within the site.pp as a local import.
#
#####

# During the bootstrap we don't need or want backups of file modifications.
# This also helps solve issues with connections to the master during the run preventing
# the backup.
File <| |> { backup => false }