chef_home = "/var/chef"
file_cache_path "#{chef_home}/cache"
temp_dir "#{chef_home}/cache"
cookbook_path [
  "#{chef_home}/cookbooks"
]
