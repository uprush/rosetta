require 'yaml'
require 'json'
require 'erb'

def remote_chef(role, options=[])
  env = ENV["ROSETTA_ENV"] || "vagrant"
  zone = ENV["ROSETTA_ZONE"] || "a"

  here = File.expand_path(File.dirname(__FILE__))
  attr_file = File.join(here, "../chef/attributes/#{env}.yml")
  attrs = YAML.load(File.read(attr_file))

  role_file = File.join(here, "../chef/roles/#{role}.json")
  roles = JSON.load(File.read(role_file))

  attrs.merge!(roles)
  solo_attr = "/tmp/rosetta-#{role}.json"
  File.open(solo_attr, "w") { |f| f.write(JSON.pretty_generate(attrs)) }

  # arguments
  solo_args = options.join(" ")

  # runner
  runner = File.join(here, "solo_runner.erb")
  erb = ERB.new(File.read(runner))

  locals = {
    :solo_attr    => solo_attr,
    :solo_args    => solo_args
  }
  rendered = erb.result(OpenStruct.new(locals).instance_eval { binding })
  chef_exec = "/tmp/solo_runner.sh"
  File.open(chef_exec, "w") { |f| f.write(rendered) }

  solo_config = File.join(here, "solo.rb")
  servers = find_servers :role => role
  servers.each do |server|
    `scp #{chef_exec} #{solo_config} #{solo_attr} #{server}:/tmp`
  end

  run "bash #{chef_exec}", :roles => role

end
