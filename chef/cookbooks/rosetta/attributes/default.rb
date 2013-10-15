## agent ##
default['rosetta']['agent']['include_loggen'] = false
default['rosetta']['agent']['apache_access_log'] = '/var/log/apache2/access.log'


## broker ##
default['rosetta']['broker']['redis_host'] = 'localhost'
default['rosetta']['broker']['redis_port'] = 6379
default['rosetta']['broker']['redis_db'] = 0

## filter ##
default['rosetta']['filter']['flush_size'] = 100
