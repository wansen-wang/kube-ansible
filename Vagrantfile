# -*- mode: ruby -*-
# vi: set ft=ruby :
# https://app.vagrantup.com/ubuntu/boxes/focal64

VAGRANTFILE_API_VERSION = "2"

cluster = {
  "master" => { :ip => "192.168.56.10", :cpus => 4, :mem => 4096 },
  "worker" => { :ip => "192.168.56.11", :cpus => 2, :mem => 2048 }
}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  cluster.each_with_index do |(hostname, info), index|
    config.vm.define hostname do |cfg|
      cfg.vm.provider :virtualbox do |vb, override|
        config.vm.box = "ubuntu/focal64"
        config.vm.box_version = "20220715.0.0"
        override.vm.network :private_network, ip: "#{info[:ip]}"
        override.vm.hostname = hostname
        vb.name = hostname
        vb.customize ["modifyvm", :id, "--memory", info[:mem], "--cpus", info[:cpus], "--hwvirtex", "on"]
      end # end provider
      cfg.vm.provision "shell", inline: <<-SHELL
        sudo mkdir -p /root/.ssh
        sudo cp /vagrant/.ssh/id_rsa /root/.ssh/id_rsa
	      sudo cp /vagrant/.ssh/id_rsa.pub /root/.ssh/id_rsa.pub
	      sudo cp /vagrant/.ssh/id_rsa.pub /root/.ssh/authorized_keys
        sudo chown -R root:root /root/.ssh
        sudo apt-get update
        sudo apt-get install python3 python3-pip sshpass curl rsync wget vim -y
        sudo pip3 install --upgrade -i https://pypi.tuna.tsinghua.edu.cn/simple pip
      SHELL
    end
  end
end