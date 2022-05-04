# -*- mode: ruby -*-
# vi: set ft=ruby :

hosts = {
  "master01" => "192.168.22.11",
  "worker01" => "192.168.22.12",
  "worker02" => "192.168.22.13"
}

Vagrant.configure("2") do |config|
  hosts.each do |name, ip|
    config.vm.define name do |machine|
      machine.vm.box = "centos/7"
      machine.vm.box_version = "2004.01"
      machine.vm.box_check_update = false
      machine.ssh.insert_key = false
      machine.vm.hostname = name
      machine.vm.network :private_network, ip: ip
      machine.vm.provider "virtualbox" do |v|
          v.name = name
          v.memory = 1024
          v.cpus = 1
      end
Vagrant.configure("2") do |config|
  config.vm.network "private_network", ip: "192.168.50.4",
    nic_type: "virtio"
end
      machine.vm.provision "shell", inline: <<-SHELL
        sudo apt-get update
        sudo apt-get upgrade -y
        sudo apt-get install git make -y
        sudo apt-get dist-upgrade -y
        sudo cp /vagrant/.ssh/id_rsa /home/vagrant/.ssh/id_rsa
	      sudo cp /vagrant/.ssh/id_rsa.pub /home/vagrant/.ssh/id_rsa.pub
	      sudo cat /vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
      SHELL
    end
  end
end