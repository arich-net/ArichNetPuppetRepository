class MCollective::Application::Healthcheck<MCollective::Application

  description "Compare nodes in puppet and mcollective"
  usage "Usage: healthcheck [OPTIONS]"

  option :nodesdir,
      :description    => "The directory where .pp node files are stored",
      :arguments      => ["--nodesdir <NODESDIR>"]


  def post_option_parser(configuration)
  end

  def validate_configuration(configuration)
  end

  def get_puppet_nodes
    dir = configuration[:nodesdir] ? configuration[:nodesdir] : "puppetmaster/manifests/nodes"

    nodes = Dir.entries(dir).grep(/pp$/).map{|n| File.basename(n, ".pp")}

    return nodes
  end

  def get_mco_nodes
    nodes = {}

    rpcclient("rpcutil").get_fact(:fact => "fqdn").each do |resp|
      value = resp[:data][:value]
      nodes.include?(value) ? nodes[value] << resp[:senderid] : nodes[value] = [ resp[:senderid] ]
    end

    return nodes
  end

  def check_morethanonce(nodes)
    morethanonce = {}

    nodes.keys.each do |n|
      if nodes[n].length > 1
        morethanonce[n] = nodes[n].length
      end
    end

    if morethanonce.keys.length > 0
       puts "Nodes found more than once:"
       morethanonce.keys.sort.each do |n|
         puts "      %-40s found %d times" % [ n, morethanonce[n] ]
       end
       puts
    end
  end

  def check_mcoonly(puppet_nodes, mco_nodes)
    mco_only = mco_nodes - puppet_nodes
    if mco_only.length > 0
      puts "Nodes not found in puppet:\n      %s\n\n" % [ mco_only.sort.join("\n      ") ]
    end
  end

  def check_puppetonly(puppet_nodes, mco_nodes)
    puppet_only = puppet_nodes - mco_nodes
    if puppet_only.length > 0
      puts "Puppet nodes not found:"

      puppet_only.sort.each do |n|
        begin
          Resolv.getaddress(n)
          icmp = Net::Ping::External.new(n)

            if icmp.ping? then
              puts "      %s is alive" % n
            else
              puts "      %s seems down" % n
            end

        rescue Resolv::ResolvError
            puts "      %s failed to resolve" % n
        end
      end
    end
  end

  def main
    require 'net/ping/external'
    require 'resolv'

    puppet_nodes = get_puppet_nodes()
    mco_nodes = get_mco_nodes()

    check_morethanonce(mco_nodes)
    check_mcoonly(puppet_nodes, mco_nodes.keys)
    check_puppetonly(puppet_nodes, mco_nodes.keys)
  end
end
