#!/bin/bash

myscript=/vagrant/home/.myscript.sh
[ -f $myscript ] && exec $myscript $*
[ -f $myscript.$1 ] && exec $myscript.$1 $*

service iptables stop

echo pre-yum.$1 >> /vagrant/home/progress
for i in openssh-server git zsh vim-minimal
do
  yum install -y $i
done
echo post-yum.$1 >> /vagrant/home/progress

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

echo pre-install.$1 >> /vagrant/home/progress
case "$1" in
  vm-puppetmaster)
    answerfile $1 y |tee /home/vagrant/answers.puppetmaster;
    /home/vagrant/$pename/puppet-enterprise-installer -a /home/vagrant/answers.puppetmaster;;
  vm-pgmaster)
    answerfile $1 n |tee /home/vagrant/answers.pgmaster;
    /home/vagrant/$pename/puppet-enterprise-installer -a /home/vagrant/answers.pgmaster;;
  vm-pgslave)
    answerfile $1 n |tee /home/vagrant/answers.pgslave;
    /home/vagrant/$pename/puppet-enterprise-installer -a /home/vagrant/answers.pgslave;;
  *) echo "XXXXX NONE XXXXXX"; exit 1;;
esac
rm -rf /home/vagrant/modules
mv /opt/puppet/share/puppet/modules /home/vagrant/modules
echo done-install.$1 >> /vagrant/home/progress
case "$1" in
  vm-puppetmaster)
    /opt/puppet/bin/gem install librarian-puppet
    export PATH=/opt/puppet/bin:$PATH
    ( cd /opt/puppet/share/puppet; rm -rf modules.old; cp /vagrant/etc/Puppetfile . ; /opt/puppet/bin/librarian-puppet install --verbose --clean)
    cp /vagrant/etc/site.pp /etc/puppetlabs/puppet/manifests/site.pp
     while true;
     do echo "wait for sign:";
        /opt/puppet/bin/puppet cert list
        /opt/puppet/bin/puppet cert sign vm-pgmaster vm-pgslave
        sleep 10
     done
    ;;
  *)
   while true;
   do echo "wait for sign:";
      /opt/puppet/bin/puppet agent -t -w 60
      sleep 10
   done
   ;;
esac
echo done.$1 >> /vagrant/home/progress
echo "Shell for $1"
/bin/env PS1='| ' bash
