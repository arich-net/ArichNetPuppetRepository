# Set up the @INC paths for a perl script using the Verio conventions


use strict;

use FindBin;
use File::Basename;

$^W = 1;

require 'lib.pm';

if ($FindBin::RealScript =~ /\.pl$/) {
    # We are running from a source directory - use the shared
    # source lib directory to find utility modules.

    my $start_path = my $path = $FindBin::RealBin;
    my $libpath;

    for (;;) {
        my $child_path = $path;
        $path = dirname($child_path);

        $path ne $child_path or
            die "$0: Can't find a lib directory anywhere above $start_path";

        $libpath = "$path/lib/perl";
        last if -d $libpath;
    }

    import lib $FindBin::RealBin;
    import lib $libpath;
}
else {
    # We are running from a production directory.  Ensure that
    # we don't pick up modules from anywhere except the private
    # lib/script-name directory (this is so we don't accidentally
    # affect unrelated scripts when we do an install).

    unimport lib '.';
    my $libpath = dirname($FindBin::RealBin) . '/lib/perl';
    import lib "$libpath/$FindBin::RealScript";
}

1;
