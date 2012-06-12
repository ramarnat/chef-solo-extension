require 'chef/config'

directory "#{Chef::Config[:node_path]}" do
  mode "0775"
  owner "root"
  group "root"
  action :create
  recursive true
end