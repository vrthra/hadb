#!/bin/bash

echo pre-yum.$1 >> /vagrant/progress
for i in openssh-server git zsh vim-minimal
do
  yum install -y $i
done
echo post-yum.$1 >> /vagrant/progress

cat <<EOF >> /etc/hosts
192.168.33.21 vm-puppetmaster
192.168.33.22 vm-pgmaster
192.168.33.23 vm-pgslave
EOF

function answerfile {
  cat <<EOF
q_install=y
q_vendor_packages_install=y
q_puppet_symlinks_install=y
q_puppetmaster_install=$2
q_puppetdb_install=$2
q_puppet_enterpriseconsole_install=$2
q_puppetagent_install=y
q_puppet_cloud_install=n
q_puppetagent_certname=$1
q_puppetmaster_certname=$1
q_puppetmaster_dnsaltnames=vm-puppetmaster.vm
q_puppet_enterpriseconsole_auth_user_email=vagrant@localhost.com
q_puppet_enterpriseconsole_auth_password=abc123
q_puppet_enterpriseconsole_smtp_host=localhost.com
q_puppetagent_server=vm-puppetmaster
q_fail_on_unsuccessful_master_lookup=n
q_pe_database=$2
q_all_in_one_install=$2
q_continue_or_reenter_master_hostname=c
q_database_install=$2
q_puppetdb_hostname=vm-puppetmaster
q_puppetca_install=n
q_run_updtvpkg=n
EOF
}
pename=puppet-enterprise-3.0.0-el-6-x86_64
cat /vagrant/home/$pename.tar.gz | gzip -dc | tar -xvpf -

echo pre-install.$1 >> /vagrant/progress
case "$1" in
  vm-puppetmaster)
    answerfile $1 y |tee /vagrant/answers.puppetmaster;
    /vagrant/home/$pename/puppet-enterprise-installer -a /vagrant/answers.puppetmaster;;
  vm-pgmaster)
    answerfile $1 n |tee /vagrant/answers.pgmaster;
    /vagrant/home/$pename/puppet-enterprise-installer -a /vagrant/answers.pgmaster;;
  vm-pgslave)
    answerfile $1 n |tee /vagrant/answers.pgslave;
    /vagrant/home/$pename/puppet-enterprise-installer -a /vagrant/answers.pgslave;;
  *) echo "XXXXX NONE XXXXXX";;
esac
echo done.$1 >> /vagrant/progress

