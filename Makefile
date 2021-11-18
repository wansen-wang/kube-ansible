SHELL := /bin/bash

ANSIBLE_OPT:=
# binary file download way, official nexus qiniu
DOWNLOAD_WAY:=official

# binary version
KUBE_VERSION:=1.22.4
ETCD_VERSION:=3.5.1
CNI_VERSION:=1.0.1

# container runtime. containerd or docker
RUNTIME:=docker
DOCKER_VERSION:=20.10.10

CONTAINERD_VERSION:=1.5.7
CRICTL_VERSION:=1.22.0
RUNC_VERSION:=1.0.2

# nexus information
NEXUS_DOMAIN_NAME:=
NEXUS_REPOSITORY:=kube-ansible
NEXUS_HTTP_USERNAME:=
NEXUS_HTTP_PASSWORD:=

runtime:
	@echo -e "\033[32mDeploy ansible...\033[0m"
	@scripts/runtime.sh

install:
	@[ -f group_vars/all.yml ] || ( echo -e "\033[31mPlease Create group vars...\033[0m" && exit 1 )
	@[ -f ./inventory/hosts ] || ( echo -e "\033[31mPlease Create asset information...\033[0m" && exit 1 )
	@DOWNLOAD_WAY=$(DOWNLOAD_WAY) \
		RUNTIME=$(RUNTIME) \
		KUBE_VERSION=$(KUBE_VERSION) \
		ETCD_VERSION=$(ETCD_VERSION) \
		CONTAINERD_VERSION=$(CONTAINERD_VERSION) \
		RUNC_VERSION=$(RUNC_VERSION) \
		CRICTL_VERSION=$(CRICTL_VERSION) \
		DOCKER_VERSION=$(DOCKER_VERSION) \
		CNI_VERSION=$(CNI_VERSION) ./scripts/info.sh
	@ansible-playbook -i ./inventory/hosts install.yml \
		-e DOWNLOAD_WAY=$(DOWNLOAD_WAY) \
		-e RUNTIME=$(RUNTIME) \
		-e KUBE_VERSION=$(KUBE_VERSION) \
		-e ETCD_VERSION=$(ETCD_VERSION) \
		-e CONTAINERD_VERSION=$(CONTAINERD_VERSION) \
		-e RUNC_VERSION=$(RUNC_VERSION) \
		-e CRICTL_VERSION=$(CRICTL_VERSION) \
		-e DOCKER_VERSION=$(DOCKER_VERSION) \
		-e CNI_VERSION=$(CNI_VERSION) \
		-e NEXUS_HTTP_USERNAME=$(NEXUS_HTTP_USERNAME) \
		-e NEXUS_HTTP_PASSWORD=$(NEXUS_HTTP_PASSWORD) \
		-e NEXUS_DOMAIN_NAME=$(NEXUS_DOMAIN_NAME) \
		-e NEXUS_REPOSITORY=$(NEXUS_REPOSITORY) $(ANSIBLE_OPT)
	@echo -e "\033[32mDeploy kubernetes done, please check the pod status.\033[0m"

scale: 
	@echo -e "\033[32mScale kubernetes node...\033[0m"
	@ansible-playbook -i ./inventory/hosts scale.yml \
		-e DOWNLOAD_WAY=$(DOWNLOAD_WAY) \
		-e RUNTIME=$(RUNTIME) \
		-e KUBE_VERSION=$(KUBE_VERSION) \
		-e ETCD_VERSION=$(ETCD_VERSION) \
		-e CONTAINERD_VERSION=$(CONTAINERD_VERSION) \
		-e RUNC_VERSION=$(RUNC_VERSION) \
		-e CRICTL_VERSION=$(CRICTL_VERSION) \
		-e DOCKER_VERSION=$(DOCKER_VERSION) \
		-e CNI_VERSION=$(CNI_VERSION) \
		-e NEXUS_HTTP_USERNAME=$(NEXUS_HTTP_USERNAME) \
		-e NEXUS_HTTP_PASSWORD=$(NEXUS_HTTP_PASSWORD) \
		-e NEXUS_DOMAIN_NAME=$(NEXUS_DOMAIN_NAME) \
		-e NEXUS_REPOSITORY=$(NEXUS_REPOSITORY) $(ANSIBLE_OPT)

upgrade: 
	@echo -e "\033[32mUpgrade kubernetes...\033[0m"
	@ansible-playbook -i ./inventory/hosts upgrade.yml \
		-e DOWNLOAD_WAY=$(DOWNLOAD_WAY) \
		-e RUNTIME=$(RUNTIME) \
		-e KUBE_VERSION=$(KUBE_VERSION) \
		-e ETCD_VERSION=$(ETCD_VERSION) \
		-e CONTAINERD_VERSION=$(CONTAINERD_VERSION) \
		-e RUNC_VERSION=$(RUNC_VERSION) \
		-e CRICTL_VERSION=$(CRICTL_VERSION) \
		-e DOCKER_VERSION=$(DOCKER_VERSION) \
		-e CNI_VERSION=$(CNI_VERSION) \
		-e NEXUS_HTTP_USERNAME=$(NEXUS_HTTP_USERNAME) \
		-e NEXUS_HTTP_PASSWORD=$(NEXUS_HTTP_PASSWORD) \
		-e NEXUS_DOMAIN_NAME=$(NEXUS_DOMAIN_NAME) \
		-e NEXUS_REPOSITORY=$(NEXUS_REPOSITORY) $(ANSIBLE_OPT)

uninstall:
	@echo -e "\033[32mUninstall kubernetes...\033[0m"
	@ansible-playbook -i ./inventory/hosts uninstall.yml

fix:
	@ansible-playbook -i ./inventory/hosts fix-python3.yml

local:
	@command -v yq &>/dev/null || (echo "Please install yq." && exit 1) && exit 0
	@rm -rf .ssh && mkdir -p .ssh
	@cp -f ./inventory/template/virtualbox.template ./inventory/hosts
	@ssh-keygen -t rsa -P "" -f ./.ssh/id_rsa
	@vagrant up
	@yq e -i '.ha.type="slb"' ./group_vars/kubernetes.yml
	# @vagrant ssh ansible -c 'sudo cp /vagrant/.ssh/id_rsa /home/vagrant/.ssh/id_rsa'
	# @vagrant ssh ansible -c 'sudo cp /vagrant/.ssh/id_rsa.pub /home/vagrant/.ssh/id_rsa.pub'
	# @vagrant ssh ansible -c 'sudo cat /vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys'
	# @vagrant ssh ansible -c 'sudo apt install git make -y'
	# @vagrant ssh ansible -c 'cd /vagrant && sudo make runtime'
	# @vagrant ssh ansible -c 'cd /vagrant/group_vars && sudo make'
	# @vagrant ssh ansible -c ''
	# @vagrant ssh ansible -c 'yq e -i \'.ha.vip="192.168.22.9"\' /vagrant/group_vars/kubernetes.yml'
	# @vagrant ssh ansible -c 'yq e -i \'.ha.mask="24"\' /vagrant/group_vars/kubernetes.yml'
	# @vagrant ssh ansible -c 'cd /vagrant && sudo make install'

version: 
	@command -v jq > /dev/null 2>&1 || ( echo -e "\033[32mPlease install jq\033[0m" &&  exit 1)
	@echo "etcd" > .etcd
	@curl -s `curl -s https://api.github.com/repos/coreos/etcd/releases | jq -r .url` | jq -r '.[].tag_name' | grep -Ev 'rc|beta|alpha' | sed 's/v//g' | head -n 15 | sort -r -V >> .etcd
	@echo "docker" > .docker
	@curl -s https://api.github.com/repos/moby/moby/releases | jq -r '.[].tag_name' | grep -Ev 'rc|beta|alpha|-ce' | sed 's/v//g' | head -n 15 | sort -r -V >> .docker
	@echo "kubernetes" > .kubernetes
	@curl -s https://api.github.com/repos/kubernetes/kubernetes/releases | jq -r '.[].tag_name' | grep -Ev 'rc|beta|alpha' | sed 's/v//g' | head -n 15 | sort -r -V >> .kubernetes
	@echo "containerd" > .containerd
	@curl -s https://api.github.com/repos/containerd/containerd/releases | jq -r '.[].tag_name' | grep -Ev 'rc|beta|alpha' | sed 's/v//g' | head -n 15 | sort -r -V >> .containerd
	@echo "crictl" > .crictl
	@curl -s https://api.github.com/repos/kubernetes-sigs/cri-tools/releases | jq -r '.[].tag_name' | grep -Ev 'rc|beta|alpha' | sed 's/v//g'| head -n 15 | sort -r -V >> .crictl
	@echo "runc" > .runc
	@curl -s https://api.github.com/repos/opencontainers/runc/releases | jq -r '.[].tag_name' | grep -Ev 'rc|beta|alpha' | sed 's/v//g'| head -n 15 | sort -r -V >> .runc
	@echo "cni" > .cni
	@curl -s https://api.github.com/repos/containernetworking/plugins/releases | jq -r '.[].tag_name' | grep -Ev 'rc|beta|alpha' | sed 's/v//g'| head -n 15 | sort -r -V >> .cni
	@paste -d '|' .etcd .docker .kubernetes .containerd .crictl .runc .cni | column -t -s '|'
	@rm -rf .etcd .docker .kubernetes .containerd .crictl .runc .cni

nexus:
	@./scripts/upload-nexus.py --url=$(NEXUS_DOMAIN_NAME) \
		--repository=$(NEXUS_REPOSITORY) \
		--username=$(NEXUS_HTTP_USERNAME) \
		--password=$(NEXUS_HTTP_PASSWORD) \
		--docker=$(DOCKER_VERSION) \
		--etcd=$(ETCD_VERSION) \
		--kubernetes=$(KUBE_VERSION) \
		--cni=$(CNI_VERSION) \
		--containerd=$(CONTAINERD_VERSION) \
		--runc=$(RUNC_VERSION) \
		--crictl=$(CRICTL_VERSION)

help:
	@./scripts/help.sh