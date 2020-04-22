.PHONY: qserver ssh_prep chk_jtagconfig

CASCADE=repos/cascade

QUARTUS=vendor/intel/intel-de10/quartus

HOST_IP=192.168.7.5
DEVI_IP=192.168.7.1

DEVICES=$(shell ifconfig |grep --color=never enp0s20 | cut -f1 -d":")

CA_REPO=https://github.com/vmware/cascade.git


$(CASCADE)/build/tools/cascade:
	git submodule foreach git pull origin master
	cd $(CASCADE) && ./setup --silent --no-install

bin/cascade: $(CASCADE)/build/tools/cascade
	ln -s ../$< ./$@

bin/quartus_server: $(CASCADE)/build/tools/quartus_server bin/cascade
	ln -s ../$< ./$@

qserver: bin/quartus_server
	./bin/quartus_server --path $(shell pwd)/$(QUARTUS) --port 9900

chk_jtagconfig: $(QUARTUS)/bin/jtagconfig
	sudo ./$(QUARTUS)/bin/jtagconfig

/tmp/fpga-cluster/setup_routes:
	make chk_jtagconfig
	echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null
	sudo iptables -P FORWARD ACCEPT
	sudo iptables -A POSTROUTING -t nat -j MASQUERADE -s 192.168.7.0/24
	mkdir -p /tmp/fpga-cluster
	touch $@

setup_routes: /tmp/fpga-cluster/setup_routes

ssh_prep: setup_routes chk_jtagconfig
	-ssh root@${DEVI_IP} ifconfig usb0 ${DEVI_IP} netmask 255.255.255.0
	-ssh root@${DEVI_IP} route add default gw ${HOST_IP}
	ssh root@${DEVI_IP} route
	sudo ifconfig $(DEVICES) $(HOST_IP) netmask 255.255.255.0
	ssh root@${DEVI_IP} 'if [ -z "$(shell ssh root@${DEVI_IP} cat /etc/resolv.conf |grep 8.8.8.8)" ]; then echo "nameserver 8.8.8.8" >> /etc/resolv.conf; fi'
	#ssh root@${DEVI_IP} git clone ${CA_REPO}
	#ssh root@${DEVI_IP} cd cascade && ./setup --silent --no-install

ssh_de10: ssh_prep
	ssh root@$(DEVI_IP)
