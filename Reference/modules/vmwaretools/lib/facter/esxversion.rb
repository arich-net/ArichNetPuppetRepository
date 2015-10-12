Facter.add("esxversion") do
  setcode do
    vmbios = Facter::Util::Resolution.exec('dmidecode | grep -A4 "BIOS Information" | awk \'/Address:/ { print $2 }\'')

    case vmbios
      when "0xE8480"
        esxversion = '2.5'
      when "0xE7C70"
        esxversion = '3.0'
      when "0xE7910"
        esxversion = '3.5'
      when "0xEA6C0"
        esxversion = '4.0'
      when "0xEA550"
        esxversion = '4.0u1'
      when "0xEA2E0"
        esxversion = '4.1'
      when "0xE72C0"
        esxversion = '5.0'
      else
        esxversion = 'unknown'
    end
    esxversion
  end
end