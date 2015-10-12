define steng::download_file(
        $filename = $title,
        $base_url="",
        $cwd="",
        ) {                                                                                         

    exec { $name:                                                                                                                     
        command => "/usr/bin/curl --fail --silent --insecure -O ${base_url}/${filename}",                                                         
        cwd => $cwd,
        creates => "${cwd}/${filename}",                                                              
    }
}

