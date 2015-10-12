#
# Netbackup local master/media using datacenter fact
# 
# Uses OOB IP's in order to be used in serverqa connectivity checks,
# plus this is what the nb client will use for backups, so makes sense!
#
# Requires:
# 1) Update/maintain facter fact 'datacenter' with correct values.
#
nb_mediaservers = Array.new

begin
  dc = Facter.value('datacenter')
  case dc
  when "Slough"
    nb_masterserver = "10.231.183.69"
    nb_mediaservers.push("10.231.183.70", "10.231.183.71")
  when "Hemel"
    nb_masterserver = "10.46.0.1"
    nb_mediaservers.push("10.46.0.2", "10.46.0.2")
  when "London"
    nb_masterserver = "10.130.46.25"
    nb_mediaservers.push("10.130.255.1", "10.130.255.4")
  when "Frankfurt"
    nb_masterserver = "10.198.77.33"
    nb_mediaservers.push("10.198.77.42")
  when "Paris 2"
    nb_masterserver = "10.25.193.36"
    nb_mediaservers.push("10.25.193.34")
  when "Paris 3"
    nb_masterserver = "10.20.0.5"
    #nb_mediaservers.push("")
  when "Madrid 2"
    nb_masterserver = "10.19.9.33"
    nb_mediaservers.push("10.19.9.37")  
  else
  end
rescue Exception => msg
  puts msg
end

Facter.add( "nb_master" ) do
        setcode do
                nb_masterserver
        end
end

begin
  q = 1
  nb_mediaservers.each do |item|
    Facter.add( "nb_media" + q.to_s ) do
      setcode { item }
      q = q+1
    end
  end
rescue Exception => msg
  puts msg
end

# join them all.. 
Facter.add("nb_mediaservers") do
  setcode do
    nb_mediaservers.join(",")
  end
end
