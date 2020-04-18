.PHONY=qserver

CASCADE=repos/cascade

QUARTUS=vendor/intel/intel-de10/quartus


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

ssh_de10:
	ssh root@192.168.7.1
