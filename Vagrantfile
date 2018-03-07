# -*- mode: ruby -*-
# vi: set ft=ruby :
MASTER_NODE_IP_START="192.168.40.1"
SLAVE_NODE_IP_START="192.168.40.2"

JOIN_TOKEN="abcdef.1234567890123456"
WORKER_COUNT=1
Vagrant.configure("2") do |config|
 (0..0).each do |i|
    config.vm.define "master" do |node|
      node.vm.box = "bento/ubuntu-16.04"
      #node.vm.box_version = "0"
      #node.vm.network "forwarded_port", guest: 7077, host: 21001, host_ip: "127.0.0.1"
      
      node.vm.network "private_network", ip: "#{MASTER_NODE_IP_START}#{i}"
      
      node.vm.synced_folder "data", "/data"
      
      node.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
		vb.cpus = 1
	  end

	 node.vm.provision "shell", path: "data/master/install.sh"
    end
  end
  
  (1..WORKER_COUNT).each do |i|
    config.vm.define "slave#{i}" do |node|
	  node.vm.box = "bento/ubuntu-16.04"
	  node.vm.hostname = "slave#{i}"
      node.vm.network "private_network", ip: "#{SLAVE_NODE_IP_START}#{i}"
	  node.vm.synced_folder "data", "/data"
	
	  node.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
		vb.cpus = 1
	  end
	  node.vm.provision "shell", path: "data/slave/install.sh"
	end
  end
end


