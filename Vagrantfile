# -*- mode: ruby -*-
# vi: set ft=ruby :

sdb_fn = "sdb.vdi"

Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.provider "virtualbox" do |vm|
    vm.customize ["modifyvm", :id, "--memory", "1536"]
#    vm.customize ["modifyvm", :id, "--nic2", "bridged"]
#    vm.customize ["modifyvm", :id, "--bridgeadapter2", "en0"]
#    vm.customize ["modifyvm", :id, "--nic3", "intnet"]
#    vm.customize ["modifyvm", :id, "--nic4", "intnet"]
#    vm.customize ["modifyvm", :id, "--nic5", "intnet"]
#    vm.customize ["modifyvm", :id, "--nic6", "intnet"]
#    vm.customize ["modifyvm", :id, "--nic7", "intnet"]
    vm.customize ['createhd', '--filename', sdb_fn, '--size', 500 * 1024]
    vm.customize ['storageattach', :id, '--storagectl', 'SATAController', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', sdb_fn]
  end

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network :forwarded_port, guest: 80, host: 8080

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  config.vm.network "public_network", :bridge => 'en0: Wi-Fi (AirPort)', :auto_config => false
  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network :private_network, ip: "192.168.33.10"

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "site.yml"
    ansible.user = "vagrant"
    ansible.inventory_file = "hosts"
    ansible.limit = "vagrant"
  end
end
