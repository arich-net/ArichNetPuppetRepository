module MCollective
  module Agent
    class Megaraid<RPC::Agent
      activate_when do
        Facts["virtual"] == 'physical'
      end

      def startup_hook
        @megacli = "/usr/bin/MegaCli" 
        @megacli_fwtermlog_run="#{@megacli} -FwTermLog -Dsply -aALL -NoLog"
        @megacli_info_run="#{@megacli} -AdpAllInfo -aAll -NoLog"
        @megacli_summary_run="#{@megacli} -ShowSummary -aAll -NoLog"
        @megacli_physicalinfo_run="#{@megacli} -PDList -aALL -NoLog"
        @megacli_logicalinfo_run="#{@megacli} -LDInfo -Lall -aALL -NoLog"
      end

      def megacli_exists?
        `which MegaCli`
        $?.success?
      end

      def get_summary_action
        ### Overall summary info
        cmd = `#{@megacli_summary_run}`
        data = {}
        index_n = nil 
        pd_index_n = -1
        vd_index_n = -1
        cmd.each do |line|
          match=line.strip.match /^([a-zA-Z0-9_\/.\-, ]+):([a-zA-Z0-9_\/.\-, ]+)/
          if line.strip.match /^System/ then
            index_n = :system 
            data[index_n] = {}
          end
          if line.strip.match /^Controller/ then
            index_n = :controller
            data[index_n] = {}
          end
          if line.strip.match /^Enclosure/ then
            index_n = :enclosure
            data[index_n] = {}
          end
          if line.strip.match /^PD/ then
            index_n = :physical_drives
            data[index_n] = {}
          end
          if line.strip.match /^Virtual Drives$/ then
            index_n = :virtual_drives
            data[index_n] = {}
          end
          if match then
            key = match[1].strip
            value = match[2].strip
            next if key == "Exit Code"
            if key == "Connector" and index_n == :physical_drives then
              pd_index_n += 1
              data[index_n][pd_index_n] = {}
            elsif key == "Virtual drive" and index_n == :virtual_drives then
              vd_index_n += 1
              data[index_n][vd_index_n] = {}
            end

            if index_n == :physical_drives and pd_index_n > -1 then
              data[index_n][pd_index_n] = data[index_n][pd_index_n].merge(key => value)
            elsif index_n == :virtual_drives and vd_index_n > -1 then
              data[index_n][vd_index_n] = data[index_n][vd_index_n].merge(key => value)
            else 
              data[index_n] = data[index_n].merge(key => value)
            end
          end
        end
        reply[:summary] = data
      end

      def get_fwtermlog_action
        data = []
        cmd = `#{@megacli_fwtermlog_run}`
        cmd.reverse!
        cmd.take(10).each do |log|
          data.push(log)
        end
        data.reverse!
        reply[:fwtermlog] = data
      end  

      def get_physical_info_action
        ### Physical info
        ### outputs as { adapter_number => { logical_drive_number => {} }
        cmd = `#{@megacli_physicalinfo_run}`
        data = {}
        adapter_n=-1
        physical_n=-1
        cmd.each do |line|
          match=line.match /^([a-zA-Z0-9_\/.\-, ]+):([a-zA-Z0-9_\/.\-, ]+)/
          if line.match /^Adapter/ then
            adapter_n += 1
            data[adapter_n] = {}
          end
          if line.match /^Enclosure Device ID/ then
            physical_n += 1
            data[adapter_n][physical_n] = {}
          end
          if match and ! line.match /^(Adapter|Enclosure Device ID)/ then
            key = match[1].strip
            value = match[2].strip
            data[adapter_n][physical_n] = data[adapter_n][physical_n].merge(key => value)
          end
        end
        reply[:physical_info] = data 
      end
   
      def get_logical_info_action
        ### logical info
        ### outputs as { adapter_number => { logical_drive_number => {} }
        cmd = `#{@megacli_logicalinfo_run}`
        data = {}
        adapter_n=-1
        logical_n=-1
        cmd.each do |line|
          match=line.match /^([a-zA-Z0-9_\/.\-, ]+):([a-zA-Z0-9_\/.\-, ]+)/
          if line.match /^Adapter/ then
            adapter_n += 1
            data[adapter_n] = {}
          end
          if line.match /^Virtual Drive/ then
            logical_n += 1
            data[adapter_n][logical_n] = {}
          end
          if match and ! line.match /^(Adapter|Virtual)/ then
            key = match[1].strip
            value = match[2].strip 
            data[adapter_n][logical_n] = data[adapter_n][logical_n].merge(key => value)
          end
        end
        reply[:logical_info] = data
      end
     
      # Battery backup unit relearn 
      def run_bbu_relearn(action)
        reply[:status] = run(action, :stdout => :out, :stderr => :err, :environment => {})
        reply.fail "Error",1 unless reply[:status] == 0
      end
 
      def get_bbu_status
      end
            
    end
  end
end