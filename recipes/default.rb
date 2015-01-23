require 'chef/config'

Chef::Config[:nodes_path] ||= Chef::Config.canonicalize(File.join(Chef::Config[:data_bag_path], "node"))

# create this directory before the converge
d = directory "#{Chef::Config[:nodes_path]}" do
  mode "0775"
  recursive true
end.run_action(:create)
