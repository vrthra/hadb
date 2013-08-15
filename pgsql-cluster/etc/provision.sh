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
SECONDS=0
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
rpm -ivh /home/vagrant/$pename/packages/el-6-x86_64/pe-postgresql-*
echo "It took $SECONDS for $1 install"
case "$1" in
  vm-puppetmaster)
    /opt/puppet/bin/gem install librarian-puppet
    export PATH=/opt/puppet/bin:$PATH
    ( cd /opt/puppet/share/puppet; cp /vagrant/etc/Puppetfile . ; /opt/puppet/bin/librarian-puppet install --verbose --clean)
    cp /vagrant/etc/site.pp /etc/puppetlabs/puppet/manifests/site.pp
    echo "service pe-puppet stop; service pe-httpd stop; \
      /opt/puppet/bin/puppet master --verbose --no-daemonize 2>&1 | tee /home/vagrant/master.log" \
      > /home/vagrant/start-master.sh
    echo "service pe-puppet restart; service pe-httpd restart; tail -f /var/log/messages" \
      > /home/vagrant/restart-master.sh
    (while true;
    do echo "wait for sign:";
        case $(/opt/puppet/bin/puppet cert list | wc -l) in
           2) /opt/puppet/bin/puppet cert sign vm-pgmaster vm-pgslave; exit 0;;
           *) sleep 10;;
        esac
    done)
    ;;
  *)
    echo "service pe-puppet stop; \
      /opt/puppet/bin/puppet agent --verbose --no-daemonize 2>&1 | tee /home/vagrant/agent.log" \
      > /home/vagrant/start-agent.sh
   (while true;
   do echo "wait for sign:";
      /opt/puppet/bin/puppet agent -t -w 10;
      /opt/puppet/bin/puppet agent -t && exit 0;
      sleep 10
   done)
    # We dont stop puppetmaster because we dont know when the agents would request for signing.
    /sbin/service pe-puppet stop;
   ;;
esac
echo done.$1 >> /vagrant/home/progress
echo "Shell for $1"
chmod +x /home/vagrant/*.sh
cat <<EOF > /etc/profile.d/puppet.sh
export PATH=/opt/puppet/bin:$PATH
p_conf=/etc/puppetlabs/puppet p_dir=/opt/puppet/share/puppet
PS1="$1# "
pg() {
  sudo -E -H -i -u pe-postgres /bin/bash
}
EOF
cat <<EOF > /etc/sudoers.d/pe-postgres
pe-postgres        ALL=(ALL)       NOPASSWD: ALL
EOF
sudo chmod 400 /etc/sudoers.d/pe-postgres

cat <<EOF > /opt/puppet/var/lib/pgsql/.bashrc
[ -e /vagrant/etc/bashrc.$1 ] && . /vagrant/etc/bashrc.$1
EOF

bash

