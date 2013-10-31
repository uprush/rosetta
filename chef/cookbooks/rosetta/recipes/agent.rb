include_recipe "rosetta::default"

# install apache log generator
if node['rosetta']['agent']['include_loggen']
  package "ruby-dev" # install mkmf, which is required by apache-loggen
  gem_package "apache-loggen"

  # create log dir
  directory node['rosetta']['agent']['apache_access_dir'] do
    owner "root"
    group "root"
    action :create
  end

  # create apache-loggen init script
  template "/etc/init.d/apache-loggen" do
    source "apache-loggen/init.erb"
    mode 0755
    action :create
  end

  service "apache-loggen"
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
package "td-agent" do
  action :install
  options "--force-yes"
end

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
gem_package "fluent-redislist" do
  gem_binary "/usr/lib/fluent/ruby/bin/gem" # TODO: /usr/lib32 on 32 bit OS
  options "--no-ri --no-rdoc"
  action :install
end

# tail apache access log
template "/etc/td-agent/conf.d/apache_access.conf" do
  source "td-agent/conf.d/apache_access.conf.erb"
  mode 0644
  action :create
  notifies :restart, "service[td-agent]", :immediately
end
