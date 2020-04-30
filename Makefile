.PHONY: qserver ssh_prep chk_jtagconfig

CASCADE=repos/cascade

QUARTUS=vendor/intel/intel-de10/quartus

HOST_IP=192.168.7.5
DEVI_IP=192.168.7.1

DEVICES=$(shell ifconfig |grep --color=never enp0s20 | cut -f1 -d":")

CA_REPO=https://github.com/vmware/cascade.git


$(CASCADE)/build/tools/cascade:
	git submodule init && git submodule update --recursive
	git submodule foreach git pull origin master
	cd $(CASCADE) && ./setup --silent --no-install

bin/cascade: $(CASCADE)/build/tools/cascade
	mkdir -p bin
	ln -s ../$< ./$@

bin/quartus_server: $(CASCADE)/build/tools/quartus_server
	mkdir -p bin
	ln -s ../$< ./$@

qserver: src/qs-container/Dockerfile
	cd src/qs-container && docker build -t billy .
	docker run -ti -p 9900:9900 -v $(shell pwd)/$(QUARTUS):/quartus billy quartus_server --path /quartus --port 9900

chk_jtagconfig: $(QUARTUS)/bin/jtagconfig
	sudo ./$(QUARTUS)/bin/jtagconfig

/tmp/fpga-cluster/setup_routes:
	echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null
	sudo iptables -P FORWARD ACCEPT
	sudo iptables -A POSTROUTING -t nat -j MASQUERADE -s 192.168.7.0/24
	mkdir -p /tmp/fpga-cluster
	touch $@

ssh_prep: /tmp/fpga-cluster/setup_routes
	sudo ifconfig $(DEVICES) $(HOST_IP) netmask 255.255.255.0

ssh_de10: ssh_prep
	ssh fpga@$(DEVI_IP)

start_microcom: ssh_prep
	sudo microcom -p /dev/ttyUSB0 115,200-8-N-1
