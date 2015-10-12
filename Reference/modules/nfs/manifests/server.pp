class nfs::server {
    package{'nfs-kernel-server':
        ensure => installed,
    }
}