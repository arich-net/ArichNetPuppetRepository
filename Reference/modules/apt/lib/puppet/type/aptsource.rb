Puppet::Type.newtype(:aptsource) do
    @doc = "Manage apt-repo source files - one repo per file

    Example: 
        aptsource { 'backports':
            uri          => 'http://www.backports.org/debian',
            distribution => $lsbdistcodename,
            components   => [ 'main', 'contrib' ],
        }

        aptsource { 'internalrepo.list':
	        repotype     => 'deb-src'
            uri          => 'http://localhost/debian',
            distribution => $lsbdistcodename,
	        components   => [ 'main', 'nonfree' ],
	        ensure       => present   # optional
        }
    "

    ensurable do
       newvalue(:present) do
           provider.create
       end

       newvalue(:absent) do
           provider.destroy
       end

       # create if no ensure is present
       defaultto :present
    end


    newparam(:sourcename) do
        desc "The repos symbolic name (also used as the filename)"

        validate do | value |
            if value =~ /\//
                raise ArgumentError, "Repo sources must not contain /"
            end
        end

        # Append .list to anme
        munge do |value|
            value.gsub!(/\.list$/, '') || value
        end

        isnamevar
    end


    newparam(:repotype) do
        desc "The repository type"

	defaultto "deb"

	validate do | value |
            unless value =~ /deb|deb-src/
	        raise ArgumentError, "repo type must be deb or deb-src"
            end
	end
    end


    newparam(:uri) do
        desc "The repos URI"

        validate do | value |
            if value.empty?
                raise ArgumentError, "Must specify a URI"
            end
        end
    end


    newparam(:distribution) do
        desc "The distribution"

	validate do | value |
            unless value =~ /^\w+$/
	        raise ArgumentError, "Supply a valid distribution name - e.g karmic or squeeze"
	    end
	end
    end


    newparam(:components) do
        desc "The components to use."

	validate do | value |
            if value.empty?
                raise ArgumentError, "Supply at least one component - e.g main or nonfree"
            end
	end
	
	munge do |value|
            if value.is_a?(Array)
                value.join(" ")
            else
                value
            end
        end
    end
end
