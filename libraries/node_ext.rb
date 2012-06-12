require 'forwardable'
require 'chef/config'
require 'json'

class Chef
  # == Chef::Client
  # The main object in a Chef run. Preps a Chef::Node and Chef::RunContext,
  # syncs cookbooks if necessary, and triggers convergence.
  class Client
    include Chef::Mixin::PathSanity

    def save_updated_node
      Chef::Log.debug("Saving the current state of node #{node_name}")
      if(@original_runlist)
        @node.run_list(*@original_runlist)
        @node[:runlist_override_history] = {Time.now.to_i => @override_runlist.inspect}
      end
      @node.save
    end
  end
end

class Chef
  class Node

    extend Forwardable

    # Save this node via the REST API
    def save
      if Chef::Config[:solo]
        json_file = File.join(Chef::Config[:node_path], "#{name.to_s}.json")
        node_json = JSON.pretty_generate(self)
        Chef::Log.debug("Node Attributes: \n #{node_json}")
        Chef::Log.info("Writing attributes to #{json_file}")
        begin
          # open file for write node
          fh = File.new(json_file, "w")
          fh.write(node_json)
          fh.close
        end
      else
        # Try PUT. If the node doesn't yet exist, PUT will return 404,
        # so then POST to create.
        begin
          chef_server_rest.put_rest("nodes/#{name}", self)
        rescue Net::HTTPServerException => e
          raise e unless e.response.code == "404"
          chef_server_rest.post_rest("nodes", self)
        end
        self
      end
    end
  end
end