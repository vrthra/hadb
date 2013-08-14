vagrant=/usr/bin/vagrant
myscript=./home/.myscript.sh
pename=puppet-enterprise-3.0.0-el-6-x86_64
peurl=https://pm.puppetlabs.com/cgi-bin/download.cgi?ver=latest&dist=el&arch=x86_64&rel=6
zcat=/bin/zcat
githubuser=git@github.com:vrthra
libevent=libevent-1.4.13-4.el6.x86_64.rpm
bintmux=tmux-1.6-1.el5.rf.x86_64.rpm
rpmforge=http://apt.sw.be/redhat/el5/en/x86_64/rpmforge/RPMS/
centospkg=http://mirror.centos.org/centos/6/os/x86_64/Packages/
key=etc/modules/pe_postgresql/files/.ssh/id_rsa

.PRECIOUS: home/$(pename).tar.gz mymodules home/$(bintmux) home/$(libevent)

update:
	echo > progress
	echo true > $(myscript)
	chmod +x $(myscript)
	$(vagrant) provision

home/$(libevent):
	curl -L '$(centospkg)/$(libevent)' > home/$(libevent)
home/$(bintmux): home/$(libevent)
	curl -L '$(rpmforge)/$(bintmux)' > home/$(bintmux)
home/$(pename).tar.gz:
	curl -L '$(peurl)' > home/$(pename).tar.gz

etc/modules/postgresql/.git:
	git clone $(githubuser)/puppetlabs-postgresql.git etc/modules/postgresql
	cd etc/modules/postgresql; git checkout pgsql/refactor

etc/modules/pe_postgresql/.git:
	git clone $(githubuser)/puppetlabs-pe_postgresql.git etc/modules/pe_postgresql
	cd etc/modules/pe_postgresql; git checkout pgsql/refactor

moduleupdate:
	cd etc/modules/pe_postgresql; git stash; git pull --rebase origin pgsql/refactor
	cd etc/modules/postgresql; git stash; git pull --rebase pgsql/refactor

mymodules: | etc/modules/postgresql/.git etc/modules/pe_postgresql/.git

link:
	$(sshp) -c 'sudo ln -s /etc/puppetlabs/puppet/manifests/site.pp /home/vagrant/site.pp'

init: home/$(pename).tar.gz mymodules home/$(bintmux)
	echo > progress
	rm -f $(myscript) $(myscript).*
	$(vagrant) up
	$(MAKE) link

clobber:
	$(vagrant) destroy -f
	rm -rf home/* .vagrant

destroyvms:
	@for i in $$(VBoxManage list runningvms | sed -e 's#"##g' | awk -F\  '/pgsql-/{print $$1;}'); do echo VBoxManage controlvm $$i poweroff; done
	@for i in $$(VBoxManage list vms | sed -e 's#"##g'| awk -F\  '/pgsql-/{print $$1;}'); do echo VBoxManage unregistervm $$i --delete; done

clean:
	$(vagrant) destroy -f
	rm -rf home/modules

lint=puppet-lint --with-context --with-filename  --no-autoloader_layout-check --fail-on-warnings
validate=puppet parser validate

modulereinit: $(key)
	$(lint) etc/modules/pe_postgresql/manifests/*.pp
	$(validate) etc/modules/pe_postgresql/manifests/*.pp
	vagrant ssh vm-puppetmaster -c 'sudo rm -rf /opt/puppet/share/puppet/modules /opt/puppet/share/puppet/Puppetfile.*'
	vagrant ssh vm-puppetmaster -c 'cd /opt/puppet/share/puppet; sudo /opt/puppet/bin/librarian-puppet install'
	$(sshp) -c 'sudo /sbin/service pe-postgresql restart; sudo /sbin/service pe-puppet restart'

$(key): | mymodules
	rm -rf etc/modules/pe_postgresql/files/.ssh/
	mkdir -p etc/modules/pe_postgresql/files/.ssh/
	ssh-keygen -f etc/modules/pe_postgresql/files/.ssh/id_rsa -t rsa  -N ''
	chmod 0755 etc/modules/pe_postgresql/files/.ssh
	chmod 555  etc/modules/pe_postgresql/files/.ssh/*

sshp=vagrant ssh vm-puppetmaster
sshm=vagrant ssh vm-pgmaster
sshs=vagrant ssh vm-pgslave
puppetdirs=/opt/puppet /etc/puppetlabs /var/opt/lib/pe-puppet

saveinst:
	$(sshm) -c 'sudo /sbin/service pe-postgresql stop; sudo /sbin/service pe-puppet stop'
	$(sshs) -c 'sudo /sbin/service pe-postgresql stop; sudo /sbin/service pe-puppet stop'
	#$(sshp) -c 'sudo /sbin/service pe-postgresql stop; sudo /sbin/service pe-puppet stop'
	$(sshm) -c 'sudo tar -cpf /vagrant/home/pgmaster.tar /usr/local/bin /etc/rc.d/init.d/pe-* $(puppetdirs)'
	$(sshs) -c 'sudo tar -cpf /vagrant/home/pgslave.tar /usr/local/bin /etc/rc.d/init.d/pe-* $(puppetdirs)'
	#$(sshp) -c 'sudo tar -cpf /vagrant/home/puppetmaster.tar /usr/local/bin /etc/rc.d/init.d/pe-* $(puppetdirs) /var/opt/lib/pe-puppetmaster'

restoreinst:
	$(sshm) -c 'sudo /sbin/service pe-postgresql stop; sudo /sbin/service pe-puppet stop'
	$(sshs) -c 'sudo /sbin/service pe-postgresql stop; sudo /sbin/service pe-puppet stop'
	#$(sshp) -c 'sudo /sbin/service pe-postgresql stop; sudo /sbin/service pe-puppet stop'
	$(sshm) -c 'cd /; sudo rm -rf $(puppetdirs) ; sudo tar -xpf /vagrant/home/pgmaster.tar'
	$(sshs) -c 'cd /; sudo rm -rf $(puppetdirs) ; sudo tar -xpf /vagrant/home/pgslave.tar'
	#$(sshp) -c 'cd /; sudo rm -rf $(puppetdirs) /var/opt/lib/pe-puppetmaster ; sudo tar -xpf /vagrant/home/puppetmaster.tar'

