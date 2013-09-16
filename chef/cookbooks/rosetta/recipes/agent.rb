# install apache log generator
if node['rosetta']['agent']['include_loggen']
  package "ruby-dev" # install mkmf, which is required by apache-loggen
  gem_package "apache-loggen"
end

# add treasure-data sources
bash "install_td-agent" do
  user "root"
  code <<-EOH
    echo "deb http://packages.treasure-data.com/precise/ precise contrib" > /etc/apt/sources.list.d/treasure-data.list
    apt-get update
    EOH
  not_if { ::File.exists?("/etc/apt/sources.list.d/treasure-data.list") }
end

# install td-agent
package "td-agent"

bash "configure_td-agent" do
  user "root"
  code <<-EOH
    mkdir /etc/td-agent/conf.d
    echo "" >> /etc/td-agent/td-agent.conf
    echo "include conf.d/*.conf" >> /etc/td-agent/td-agent.conf
    EOH
  not_if { ::File.exists?("/etc/td-agent/conf.d") }
end

service "td-agent"

# install redis output plugin for fluentd

# tail apache access log
template "/etc/td-agent/conf.d/apache_access.conf" do
  source "td-agent/conf.d/apache_access.conf.erb"
  mode 0644
  action :create
  notifies :restart, "service[td-agent]", :immediately
end

