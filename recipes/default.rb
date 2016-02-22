#
# Cookbook Name:: projecthermes
# Recipe:: default
#
# Copyright (C) 2016 Adam Leonard
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'selinux::permissive'

execute 'update yum' do
  command 'yum update -y'
  notifies :run, 'execute[add rpm]', :immediately
  not_if { ::File.exist?('/etc/yum.repos.d/webtatic.repo') }
end

execute 'add rpm' do
  command 'rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm'
  action :nothing
  notifies :run, 'execute[add rpm2]', :immediately
  not_if { ::File.exist?('/etc/yum.repos.d/webtatic.repo') }
end

execute 'add rpm2' do
  command 'rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm'
  action :nothing
  not_if { ::File.exist?('/etc/yum.repos.d/webtatic.repo') }
end

packages = ['php55w', 'php55w-mysql', 'php55w-pdo', 'php55w-mcrypt', 'php55w-mbstring', 'mariadb', 'unzip']

packages.each do |pkg|
  package pkg
end

include_recipe 'apache2::default'
include_recipe 'apache2::mod_php5'
include_recipe 'projecthermes::reload_override'

item_data = data_bag_item('projecthermes-bag', 'projecthermes')

template '/var/www/cgi-bin/connectToDB.php' do
  source 'connectToDB.php.erb'
  mode '0644'
  variables(connect: item_data['connection_string'],
            user: item_data['user'],
            userid: item_data['userid']
           )
end

remote_file "#{Chef::Config[:file_cache_path]}/projecthermes-src.zip" do
  source 'https://s3.amazonaws.com/leoninestudios/projecthermes/projecthermes-src.zip'
  mode '0755'
  action :create
end

execute 'unzip_source' do
  command "unzip -o -u #{Chef::Config[:file_cache_path]}/projecthermes-src.zip -d /var/www/"
end

template '/var/www/cgi-bin/checkout/config.php' do
  source 'config.php.erb'
  mode '0644'
  variables(stripe_sk: item_data['stripe_sk'],
            stripe_pk: item_data['stripe_pk']
           )
end

execute 'download composer' do
  command 'curl -s https://getcomposer.org/installer | php && php composer.phar install'
  cwd '/var/www/cgi-bin/composer/'
  not_if { ::File.directory?('/var/www/cgi-bin/composer/vendor') }
end

template '/var/www/cgi-bin/users/signin.php' do
  source 'signin.php.erb'
  mode '0644'
  variables(google_client: item_data['google_client'],
            google_secret: item_data['google_secret']
           )
end

service 'apache2' do
  action [:enable, :start]
end
