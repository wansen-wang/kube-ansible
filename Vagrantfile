# -*- mode: ruby -*-
# vi: set ft=ruby :

hosts = {
  "ansible" => "192.168.22.10",
	"node01" => "192.168.22.11",
  "node02" => "192.168.22.12",
  "node03" => "192.168.22.13",
  "node04" => "192.168.22.14"
}

Vagrant.configure("2") do |config|
  hosts.each do |name, ip|
    config.vm.define name do |machine|
      machine.vm.box = "ubuntu/focal64"
      machine.vm.box_check_update = false
      machine.ssh.insert_key = false
      machine.vm.hostname = name
      machine.vm.synced_folder "./.ssh", "/root/.ssh"
      machine.vm.network :private_network, ip: ip
      machine.vm.provider "virtualbox" do |v|
          v.name = name
          v.memory = 1024
          v.cpus = 1
      end
      machine.vm.provision "shell", inline: <<-SHELL
        sudo apt-get update
        sudo apt-get upgrade -y
        sudo apt-get dist-upgrade -y
        sudo cp /vagrant/.ssh/id_rsa /home/vagrant/.ssh/id_rsa
	      sudo cp /vagrant/.ssh/id_rsa.pub /home/vagrant/.ssh/id_rsa.pub
	      sudo cat /vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
        sudo wget https://github.com/mikefarah/yq/releases/download/v4.13.2/yq_linux_amd64 -O /usr/local/bin/yq
        sudo chmod +x /usr/local/bin/yq
      SHELL
    end
  end
end