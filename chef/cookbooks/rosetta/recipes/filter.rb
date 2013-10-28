include_recipe "rosetta::default"

# pre-requisites for logstash s3 output
directory "/opt/logstash/S3_temp" do
  owner node['logstash']['user']
  group node['logstash']['group']
  mode 00755
  action :create
end

# configure apache access log
template "#{node['logstash']['basedir']}/server/etc/conf.d/apache_access.conf" do
  source "logstash/conf.d/apache_access.conf.erb"
  mode 0644
  action :create
  notifies :restart, "service[logstash_server]", :immediately
end
