vagrant=/usr/bin/vagrant
myscript=./home/.myscript.sh

update:
	echo > progress
	echo true > $(myscript)
	chmod +x $(myscript)
	$(vagrant) provision

init:
	echo > progress
	rm -f $(myscript) $(myscript).*
	$(vagrant) up

clobber:
	$(vagrant) destroy -f

sign:
	echo "/opt/puppet/bin/puppet agent -t -w 60" |tee $(myscript).vm-pgmaster > $(myscript).vm-pgslave
	echo "while true; do sleep 10; /opt/puppet/bin/puppet cert sign vm-pgmaster vm-pgslave; done" > $(myscript).vm-puppetmaster
