default['apache']['docroot_dir'] = '/var/www/cgi-bin'
default['apache']['default_site_enabled'] = true

default['projecthermes']['servername'] = 'postersasap.com'
default['projecthermes']['OAuth_URL'] = "http://#{node['projecthermes']['servername']}/users/signin.php"
