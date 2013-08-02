vagrant=/usr/bin/vagrant
myscript=./home/.myscript.sh

init:
	rm -f $(myscript)
	$(vagrant) up

update:
	echo true > $(myscript)
	chmod +x $(myscript)
	$(vagrant) provision

reinstall:
