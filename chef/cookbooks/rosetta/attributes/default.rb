## agent ##
default['rosetta']['agent']['include_loggen'] = false
default['rosetta']['agent']['loggen_bin'] = '/home/vagrant/.rbenv/shims/apache-loggen'
default['rosetta']['agent']['loggen_options'] = '--rate 2 --rotate 86400'
default['rosetta']['agent']['apache_access_dir'] = '/var/log/apache2'
default['rosetta']['agent']['apache_access_file'] = 'access.log'


## broker ##
default['rosetta']['broker']['redis_host'] = 'localhost'
default['rosetta']['broker']['redis_port'] = 6379
default['rosetta']['broker']['redis_db'] = 0

## filter ##
default['rosetta']['filter']['flush_size'] = 100
default['rosetta']['filter']['s3']['access_key_id'] = ""
default['rosetta']['filter']['s3']['secret_access_key'] = ""
default['rosetta']['filter']['s3']['bucket'] = ""
default['rosetta']['filter']['s3']['endpoint_region'] = "us-east-1"
default['rosetta']['filter']['s3']['size_file'] = 0
default['rosetta']['filter']['s3']['time_file'] = 0
default['rosetta']['filter']['s3']['codec'] = 'json'
default['rosetta']['filter']['s3']['format'] = 'json'
default['rosetta']['filter']['s3']['use_ssl'] = false
