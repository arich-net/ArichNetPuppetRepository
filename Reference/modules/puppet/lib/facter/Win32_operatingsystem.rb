# http://msdn.microsoft.com/en-us/library/aa394239(v=vs.85).aspx

if Facter.fact(:kernel).value == "windows"
  win32_names = Array.new

  results = Facter::Util::WMI.execquery("select * from win32_OperatingSystem")

  for result in results do
	for property in result.properties_ do
		win32_names.push(property.name)
	end	
  end
  
  win32_names.each do |name|
	Facter::Util::WMI.execquery("select * from win32_OperatingSystem").each do |x|
		Facter.add("win32os_#{name}") do
			confine :kernel => :windows
			setcode do
				vlaue = eval("x.#{name}")
			end
			value
			end
		end
	end
end