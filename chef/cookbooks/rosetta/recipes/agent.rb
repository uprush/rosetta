# install apache log generator
if node['rosetta']['agent']['include_loggen']
  gem_package "apache-loggen"
end

# install td-agent
