require 'forwardable'
require 'chef/config'
require 'json'

class Chef
  # == Chef::Client
  # The main object in a Chef run. Preps a Chef::Node and Chef::RunContext,
  # syncs cookbooks if necessary, and triggers convergence.
  class Client
    include Chef::Mixin::PathSanity

    alias_method :original_save_updated_node, :save_updated_node

    def save_updated_node
      if Chef::Config[:solo]
        Chef::Log.debug("Saving the current state of node #{node_name}")
        if(@original_runlist)
          @node.run_list(*@original_runlist)
          @node[:runlist_override_history] = {Time.now.to_i => @override_runlist.inspect}
        end
        @node.save
      else
        original_save_updated_node
      end
    end
  end
end



class Chef
  class Config
    def self.canonicalize(path)
      Chef::Platform.windows? ? path.gsub('/', '\\') : path
    end
  end

  class Node

    extend Forwardable

    alias_method :original_save, :save

    # Save this node via the REST API
    def save
      if Chef::Config[:solo]
        json_file = Chef::Config.canonicalize(File.join(Chef::Config[:nodes_path], "#{name.to_s}.json"))
        node_json = JSON.pretty_generate(self)
        #Chef::Log.debug("Node Attributes: \n #{node_json}")
        Chef::Log.info("Writing attributes to #{json_file}")
        begin
          # open file for write node
          fh = File.new(json_file, "w")
          fh.write(node_json)
          fh.close
        end
        self
      else
        original_save
      end
    end
  end
end
