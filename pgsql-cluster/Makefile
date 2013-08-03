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

