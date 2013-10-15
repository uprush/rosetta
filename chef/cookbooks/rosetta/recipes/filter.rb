include_recipe "rosetta::default"

# configure logstash redis input plugin
template "#{node['logstash']['basedir']}/server/etc/conf.d/apache_access.conf" do
  source "logstash/conf.d/apache_access.conf.erb"
  mode 0644
  action :create
  notifies :restart, "service[logstash_server]", :immediately
end
