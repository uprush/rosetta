home = File.expand_path(File.dirname(__FILE__))
require File.join(home, "./capistrano/utils.rb")

# load config
env = ENV["ROSETTA_ENV"] || "vagrant"
zone = ENV["ROSETTA_ZONE"] || "a"
require File.join(home, "./config/#{env}-#{zone}.rb")

# register roles
configured_role.each do |r, nodes|
  nodes.each { |x| role(r, x) }
end

# load tasks
tasks = Dir.glob(File.join(home, "./capistrano/tasks/*.rb"))
tasks.each do |t|
  load t
end
