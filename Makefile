.PHONY=qserver

repos/cascade/build/tools/cascade:
	git submodule foreach git pull origin master
	cd ./repos/cascade && ./setup --silent --no-install

bin/cascade: repos/cascade/build/tools/cascade
	ln -s ../$< ./$@

bin/quartus_server: repos/cascade/build/tools/quartus_server bin/cascade
	ln -s ../$< ./$@

qserver: bin/quartus_server
	./bin/quartus_server --path $(shell pwd)/repos/intelFPGA_lite/19.1/quartus/ --port 9900

chk_jtagconfig: vendor/intel/intel-de10/quartus/bin/jtagconfig
	sudo ./vendor/intel/intel-de10/quartus/bin/jtagconfig

ssh_de10:
	ssh root@192.168.7.1
