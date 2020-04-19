.PHONY=qserver

CASCADE=repos/cascade

QUARTUS=vendor/intel/intel-de10/quartus

HOST_IP=192.168.7.5
DEVI_IP=192.168.7.1

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
	-ssh root@${DEVI_IP} ifconfig usb0 ${DEVI_IP} netmask 255.255.255.0
	-ssh root@${DEVI_IP} route add default gw ${HOST_IP}
	ssh root@${DEVI_IP} route
	sudo ifconfig enp0s20f0u3 $(HOST_IP) netmask 255.255.255.0
	mkdir -p /tmp/fpga-cluster
	touch $@

setup_routes: /tmp/fpga-cluster/setup_routes

ssh_de10: setup_routes
	ssh root@$(DEVI_IP)
