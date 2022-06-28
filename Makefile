SHELL := /bin/bash

PROJECT_NAME:=kube-ansible
PROJECT_ENV:=dev

# binary file download way, official nexus qiniu
DOWNLOAD_WAY:=official

# binary version
KUBE_VERSION:=1.23.8
ETCD_VERSION:=3.5.4
CNI_VERSION:=1.1.1

# container runtime. containerd or docker
RUNTIME:=docker
DOCKER_VERSION:=20.10.17

CONTAINERD_VERSION:=1.6.6
CRICTL_VERSION:=1.24.2
RUNC_VERSION:=1.1.3

# nexus information
NEXUS_DOMAIN_NAME:=
NEXUS_REPOSITORY:=kube-ansible
NEXUS_USERNAME:=
NEXUS_PASSWORD:=

# PKI server
# PKI_URL:=http://127.0.0.1:8080/v1/pki/project
PKI_URL:=

ANSIBLE_OPT:=

runtime:
	@echo -e "\033[32mDeploy ansible...\033[0m"
	@scripts/runtime.sh

deploy: 
	@[ -f group_vars/all.yml ] || ( echo -e "\033[31mPlease Create group vars...\033[0m" && exit 1 )
	@[ -f ./inventory/hosts ] || ( echo -e "\033[31mPlease Create asset information...\033[0m" && exit 1 )
	@PROJECT_NAME=$(PROJECT_NAME) \
		PROJECT_ENV=$(PROJECT_ENV) \
		DOWNLOAD_WAY=$(DOWNLOAD_WAY) \
		RUNTIME=$(RUNTIME) \
		KUBE_VERSION=$(KUBE_VERSION) \
		ETCD_VERSION=$(ETCD_VERSION) \
		CONTAINERD_VERSION=$(CONTAINERD_VERSION) \
		RUNC_VERSION=$(RUNC_VERSION) \
		CRICTL_VERSION=$(CRICTL_VERSION) \
		DOCKER_VERSION=$(DOCKER_VERSION) \
		CNI_VERSION=$(CNI_VERSION) \
		NEXUS_DOMAIN_NAME=$(NEXUS_DOMAIN_NAME) \
		NEXUS_REPOSITORY=$(NEXUS_REPOSITORY) \
		NEXUS_USERNAME=$(NEXUS_USERNAME) \
		NEXUS_PASSWORD=$(NEXUS_PASSWORD) \
		PKI_URL=$(PKI_URL) ./scripts/info.sh deploy
	@echo -e "\033[32mDeploy kubernetes done, please check the pod status.\033[0m"

scale: 
	@echo -e "\033[32mScale kubernetes node...\033[0m"
	@PROJECT_NAME=$(PROJECT_NAME) \
		PROJECT_ENV=$(PROJECT_ENV) \
		DOWNLOAD_WAY=$(DOWNLOAD_WAY) \
		RUNTIME=$(RUNTIME) \
		KUBE_VERSION=$(KUBE_VERSION) \
		ETCD_VERSION=$(ETCD_VERSION) \
		CONTAINERD_VERSION=$(CONTAINERD_VERSION) \
		RUNC_VERSION=$(RUNC_VERSION) \
		CRICTL_VERSION=$(CRICTL_VERSION) \
		DOCKER_VERSION=$(DOCKER_VERSION) \
		CNI_VERSION=$(CNI_VERSION) \
		NEXUS_DOMAIN_NAME=$(NEXUS_DOMAIN_NAME) \
		NEXUS_REPOSITORY=$(NEXUS_REPOSITORY) \
		NEXUS_USERNAME=$(NEXUS_USERNAME) \
		NEXUS_PASSWORD=$(NEXUS_PASSWORD) \
		PKI_URL=$(PKI_URL) ./scripts/info.sh scale

upgrade: 
	@echo -e "\033[32mUpgrade kubernetes...\033[0m"
	@PROJECT_NAME=$(PROJECT_NAME) \
		PROJECT_ENV=$(PROJECT_ENV) \
		DOWNLOAD_WAY=$(DOWNLOAD_WAY) \
		RUNTIME=$(RUNTIME) \
		KUBE_VERSION=$(KUBE_VERSION) \
		ETCD_VERSION=$(ETCD_VERSION) \
		CONTAINERD_VERSION=$(CONTAINERD_VERSION) \
		RUNC_VERSION=$(RUNC_VERSION) \
		CRICTL_VERSION=$(CRICTL_VERSION) \
		DOCKER_VERSION=$(DOCKER_VERSION) \
		CNI_VERSION=$(CNI_VERSION) \
		NEXUS_DOMAIN_NAME=$(NEXUS_DOMAIN_NAME) \
		NEXUS_REPOSITORY=$(NEXUS_REPOSITORY) \
		NEXUS_USERNAME=$(NEXUS_USERNAME) \
		NEXUS_PASSWORD=$(NEXUS_PASSWORD) \
		PKI_URL=$(PKI_URL) ./scripts/info.sh upgrade

uninstall:
	@echo -e "\033[32mUninstall kubernetes...\033[0m"
	@ansible-playbook -i ./inventory/hosts uninstall.yml

fix:
	@ansible-playbook -i ./inventory/hosts fix-python3.yml

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
	@echo "-------------------- Versions are not related! --------------------"
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

local:
	@cd group_vars && make
	@[ -f ./inventory/hosts ] || cp ./inventory/template/single-master.template ./inventory/hosts
	@vagrant up
	@vagrant ssh master -c 'cd /vagrant/ && make runtime'
	@vagrant ssh master -c 'cd /vagrant/ && make deploy'

clean:
	@rm -rf .ssh
	@vagrant destroy -f