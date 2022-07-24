SHELL := /bin/bash

PROJECT_NAME:=kube-ansible
PROJECT_ENV:=dev

# binary file download way, official or nexus
DOWNLOAD_WAY:=official

# binary version
KUBE_VERSION:=1.14.3
KUBE_RUNTIME:=docker
KUBE_NETWORK:=calico

# nexus information
NEXUS_DOMAIN_NAME:=
NEXUS_REPOSITORY:=kube-ansible
NEXUS_USERNAME:=
NEXUS_PASSWORD:=

# PKI server
# PKI_URL:=http://127.0.0.1:8080/v1/pki/project
PKI_URL:=

runtime:
	@echo -e "\033[32mDeploy ansible...\033[0m"
	@scripts/runtime.sh

deploy: 
	@[ -f group_vars/all.yml ] || ( echo -e "\033[31mPlease Create group vars...\033[0m" && exit 1 )
	@[ -f ./inventory/hosts ] || ( echo -e "\033[31mPlease Create asset information...\033[0m" && exit 1 )
	@PROJECT_NAME=$(PROJECT_NAME) \
		PROJECT_ENV=$(PROJECT_ENV) \
		DOWNLOAD_WAY=$(DOWNLOAD_WAY) \
		KUBE_VERSION=$(KUBE_VERSION) \
		KUBE_RUNTIME=$(KUBE_RUNTIME) \
		KUBE_NETWORK=$(KUBE_NETWORK) \
		NEXUS_DOMAIN_NAME=$(NEXUS_DOMAIN_NAME) \
		NEXUS_REPOSITORY=$(NEXUS_REPOSITORY) \
		NEXUS_USERNAME=$(NEXUS_USERNAME) \
		NEXUS_PASSWORD=$(NEXUS_PASSWORD) \
		PKI_URL=$(PKI_URL) ./scripts/action.sh deploy
	@echo -e "\033[32mDeploy kubernetes done, please check the pod status.\033[0m"

scale: 
	@echo -e "\033[32mScale kubernetes node...\033[0m"
	@PROJECT_NAME=$(PROJECT_NAME) \
		PROJECT_ENV=$(PROJECT_ENV) \
		DOWNLOAD_WAY=$(DOWNLOAD_WAY) \
		KUBE_VERSION=$(KUBE_VERSION) \
		KUBE_RUNTIME=$(KUBE_RUNTIME) \
		KUBE_NETWORK=$(KUBE_NETWORK) \
		NEXUS_DOMAIN_NAME=$(NEXUS_DOMAIN_NAME) \
		NEXUS_REPOSITORY=$(NEXUS_REPOSITORY) \
		NEXUS_USERNAME=$(NEXUS_USERNAME) \
		NEXUS_PASSWORD=$(NEXUS_PASSWORD) \
		PKI_URL=$(PKI_URL) ./scripts/action.sh scale

upgrade: 
	@echo -e "\033[32mUpgrade kubernetes...\033[0m"
	@PROJECT_NAME=$(PROJECT_NAME) \
		PROJECT_ENV=$(PROJECT_ENV) \
		DOWNLOAD_WAY=$(DOWNLOAD_WAY) \
		KUBE_VERSION=$(KUBE_VERSION) \
		KUBE_RUNTIME=$(KUBE_RUNTIME) \
		KUBE_NETWORK=$(KUBE_NETWORK) \
		NEXUS_DOMAIN_NAME=$(NEXUS_DOMAIN_NAME) \
		NEXUS_REPOSITORY=$(NEXUS_REPOSITORY) \
		NEXUS_USERNAME=$(NEXUS_USERNAME) \
		NEXUS_PASSWORD=$(NEXUS_PASSWORD) \
		PKI_URL=$(PKI_URL) ./scripts/action.sh upgrade

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

local: clean
	@mkdir -p .ssh
	@ssh-keygen -t RSA -N '' -f .ssh/id_rsa
	@cd group_vars && make
	@[ -f ./inventory/hosts ] || cp ./inventory/template/single-master.template ./inventory/hosts
	@vagrant up
	@vagrant ssh master -c 'cd /vagrant/ && sudo make runtime'
	@vagrant ssh master -c 'cd /vagrant/ && sudo make deploy KUBE_RUNTIME=docker KUBE_NETWORK=canal'
	# @vagrant ssh master

clean:
	@rm -rf .ssh
	@vagrant destroy -f
