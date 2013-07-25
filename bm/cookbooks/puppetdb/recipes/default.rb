#
# Cookbook Name:: devops
# Recipe:: default

directory node[:devops][:puppetdir] do
  owner 'root'
  group 'root'
  mode "0755"
  action :create
end

bash "puppet_repo" do
  cwd node[:devops][:puppetdir]
  code <<-EOH
   wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
   dpkg -i puppetlabs-release-precise.deb
   apt-get update --fix-missing
   EOH
  creates "#{node[:devops][:puppetdir]}/puppetlabs-release-precise.deb"
end

package "git-core" do
  action :install
end
package "zsh" do
  action :install
end
package "vim" do
  action :install
end
package "rake" do
  action :install
end
package "openjdk-6-jdk" do
  action :install
end
package "openssh-server" do
  action :install
end
package "tmux" do
  action :install
end
package "puppetmaster" do
  action :install
end
package "facter" do
  action :install
end

group node[:devops][:group] do
  action :create
end

user node[:devops][:user] do
  action :create
  system true
  gid node[:devops][:group]
  gid 'sudo'
  password node[:devops][:password]
  shell "/usr/bin/zsh"
end

user_home = "/home/#{node[:devops][:user]}"
directory user_home do
  owner node[:devops][:user]
  group node[:devops][:group]
  mode "0755"
  action :create
end

cookbook_file "#{user_home}/home.tar.gz" do
  source "home.tar.gz"
  mode 00644
  action :create_if_missing
end

bash "update_home" do
  cwd user_home
  code <<-EOH
     zcat home.tar.gz | (cd /home/rahul; tar -xvpf -)
     (cd #{user_home}; git reset --hard )
     chown -R #{node[:devops][:user]}:#{node[:devops][:group]} #{user_home}
  EOH
  creates "#{user_home}/.git"
end

template "devops.conf" do
  path "#{node[:devops][:puppetdir]}/devops.conf"
  source "devops.conf.erb"
  owner node[:devops][:user]
  group node[:devops][:group]
  mode "0644"
end

#file "/etc/puppet/puppet.conf" do
#  owner "root"
#  group "root"
#  mode '0755'
#  content <<EOF
#[main]
#logdir=/var/log/puppet
#vardir=/var/lib/puppet
#ssldir=/var/lib/puppet/ssl
#rundir=/var/run/puppet
#factpath=$vardir/lib/facter
#templatedir=$confdir/templates
#dns_alt_names=vm-puppetdb
#certname=vm-puppetdb

#[master]
## These are needed when the puppetmaster is run by passenger
## and can safely be removed if webrick is used.
#ssl_client_header = SSL_CLIENT_S_DN
#ssl_client_verify_header = SSL_CLIENT_VERIFY
#EOF
#end

file "/etc/hosts" do
  owner "root"
  group "root"
  mode '0755'
  content <<EOF
127.0.0.1       localhost

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
192.168.33.15 vm-postgres-master
192.168.33.16 vm-postgres-slave
192.168.33.17 vm-puppetdb
192.168.33.18 vm-bm1
192.168.33.19 vm-bm2
EOF
end

#file "/etc/puppet/manifests/site.pp" do
#  owner "root"
#  group "root"
#  mode '0755'
#  content <<EOF
#node default {
# include devmachine
# class {'puppetdb':
#   listen_address => 'vm-puppetdb',
#   listen_port => '8080',
#   ssl_listen_address => 'vm-puppetdb',
#   ssl_listen_port => '8081',
# }
# class {'puppetdb::master::config':
#   puppetdb_server => 'vm-puppetdb',
# }
#}
#EOF
#end
