SHELL := /bin/bash

# Cluster information use by pki project
PROJECT_NAME:=kubeasy
PROJECT_ENV:=dev

# Binary file download way, official or nexus
DOWNLOAD_WAY:=official

# kubernetes version
KUBE_VERSION:=1.23.12
# kubernetes container runtime
# docker, containerd
KUBE_RUNTIME:=docker
# kubernetes network plugin,
# flannel, calico, canal
KUBE_NETWORK:=flannel

# Private registry
# eg: 
# https://192.168.119.20:5000/infra
# http://192.168.119.20:5000/infra
# https://192.168.119.20/infra
# http://192.168.119.20/infra
# http://192.168.119.20
# https://192.168.119.20
REGISTRY_URL:=

# Nexus information
# eg: http://192.168.119.20:8081
NEXUS_DOMAIN_NAME:=
NEXUS_REPOSITORY:=kubeasy
NEXUS_USERNAME:=
NEXUS_PASSWORD:=

# PKI server
# PKI_URL:=http://192.168.119.20:8000/v1/pki/project
PKI_URL:=

# e2e test software version
SONOBUOY_VERSION:=0.56.10

# Install ansible on depoy server
runtime:
	@echo -e "\033[32mDeploy ansible...\033[0m"
	@./scripts/runtime.sh

deploy: 
	@[ -f group_vars/all.yml ] || ( echo -e "\033[31mPlease Create group vars...\033[0m" && exit 1 )
	@[ -f ./inventory/${PROJECT_NAME}-${PROJECT_ENV}.ini ] || ( echo -e "\033[31mPlease Create './inventory/${PROJECT_NAME}-${PROJECT_ENV}.ini' file...\033[0m" && exit 1 )
	@PROJECT_NAME=$(PROJECT_NAME) \
		PROJECT_ENV=$(PROJECT_ENV) \
		DOWNLOAD_WAY=$(DOWNLOAD_WAY) \
		KUBE_VERSION=$(KUBE_VERSION) \
		KUBE_RUNTIME=$(KUBE_RUNTIME) \
		KUBE_NETWORK=$(KUBE_NETWORK) \
		REGISTRY_URL=$(REGISTRY_URL) \
		NEXUS_DOMAIN_NAME=$(NEXUS_DOMAIN_NAME) \
		NEXUS_REPOSITORY=$(NEXUS_REPOSITORY) \
		NEXUS_USERNAME=$(NEXUS_USERNAME) \
		NEXUS_PASSWORD=$(NEXUS_PASSWORD) \
		PKI_URL=$(PKI_URL) ./scripts/action.sh deploy

scale: 
	@PROJECT_NAME=$(PROJECT_NAME) \
		PROJECT_ENV=$(PROJECT_ENV) \
		DOWNLOAD_WAY=$(DOWNLOAD_WAY) \
		KUBE_VERSION=$(KUBE_VERSION) \
		KUBE_RUNTIME=$(KUBE_RUNTIME) \
		KUBE_NETWORK=$(KUBE_NETWORK) \
		REGISTRY_URL=$(REGISTRY_URL) \
		NEXUS_DOMAIN_NAME=$(NEXUS_DOMAIN_NAME) \
		NEXUS_REPOSITORY=$(NEXUS_REPOSITORY) \
		NEXUS_USERNAME=$(NEXUS_USERNAME) \
		NEXUS_PASSWORD=$(NEXUS_PASSWORD) \
		PKI_URL=$(PKI_URL) ./scripts/action.sh scale

upgrade: 
	@PROJECT_NAME=$(PROJECT_NAME) \
		PROJECT_ENV=$(PROJECT_ENV) \
		DOWNLOAD_WAY=$(DOWNLOAD_WAY) \
		KUBE_VERSION=$(KUBE_VERSION) \
		KUBE_RUNTIME=$(KUBE_RUNTIME) \
		KUBE_NETWORK=$(KUBE_NETWORK) \
		REGISTRY_URL=$(REGISTRY_URL) \
		NEXUS_DOMAIN_NAME=$(NEXUS_DOMAIN_NAME) \
		NEXUS_REPOSITORY=$(NEXUS_REPOSITORY) \
		NEXUS_USERNAME=$(NEXUS_USERNAME) \
		NEXUS_PASSWORD=$(NEXUS_PASSWORD) \
		PKI_URL=$(PKI_URL) ./scripts/action.sh upgrade

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

offline:
	@echo -e "\033[32m-> Install docker.\033[0m"
	@find ./scripts/src/ -name '*docker-*.tgz' | xargs tar -zx --strip-components=1 -C /usr/local/bin/ -f
	@cp roles/docker/templates/docker.service.j2 /etc/systemd/system/docker.service
	@systemctl daemon-reload
	@systemctl enable docker.service
	@systemctl restart docker.service
	@sleep 10
	@echo -e "\033[32m-> Install registry.\033[0m"
	@gunzip -c ./scripts/src/images/registry.tar.gz | docker load &> /dev/null
	@docker run -d --name registry -p 5000:5000 --restart always -v `pwd`/scripts/src/registry:/var/lib/registry registry:2.8.1 &> /dev/null
	@echo -e "\033[32m-> Install staticFile server.\033[0m"
	@gunzip -c ./scripts/src/images/staticfile.tar.gz | docker load &> /dev/null
	@docker run -d --name staticfile -p 5001:8081 --restart always -v staticfile:/app/data docker.io/buxiaomo/staticfile:1.0 &> /dev/null
	@echo -e "\033[32mYou can run 'docker ps' and view the container status, \033[0m"
	@echo -e "\033[32mrun ./scripts/nexus.py upload\033[0m"
	@echo -e "\033[32mthen setting REGISTRY_URL=http://<IP>:5000/infra DOWNLOAD_WAY=nexus NEXUS_DOMAIN_NAME=http://<IP>:5001 NEXUS_REPOSITORY=kubeasy on make command\033[0m"

check:
	@./tests/check-cluster.sh

help:
	@./scripts/help.sh

local: clean
	@mkdir -p .ssh
	@ssh-keygen -t RSA -N '' -f .ssh/id_rsa
	@cd group_vars && make
	@[ -f ./inventory/${PROJECT_NAME}-${PROJECT_ENV}.inv ] || cp ./inventory/template/single-master.template ./inventory/${PROJECT_NAME}-${PROJECT_ENV}.inv
	@vagrant up
	@vagrant ssh master -c 'cd /vagrant/ && sudo make runtime'
	@vagrant ssh master -c 'cd /vagrant/ && sudo make deploy KUBE_RUNTIME=docker KUBE_NETWORK=canal'
	# @vagrant ssh master

clean:
	@rm -rf .ssh
	@vagrant destroy -f

e2e:
	@wget https://github.com/vmware-tanzu/sonobuoy/releases/download/v$(SONOBUOY_VERSION)/sonobuoy_$(SONOBUOY_VERSION)_linux_amd64.tar.gz -O /usr/local/src/sonobuoy_$(SONOBUOY_VERSION)_linux_amd64.tar.gz
	@tar -zxf /usr/local/src/sonobuoy_$(SONOBUOY_VERSION)_linux_amd64.tar.gz -C /usr/local/bin --exclude=LICENSE
	@sonobuoy run --image-pull-policy=IfNotPresent --mode=certified-conformance --wait
	@mkdir -p ./tests/k8s-conformance
	@tar -zxf `sonobuoy retrieve /tmp` --strip-components=4 -C ./tests/k8s-conformance plugins/e2e/results/global/e2e.log plugins/e2e/results/global/junit_01.xml
	@kubectl get nodes -o wide
	@sonobuoy results `sonobuoy retrieve /tmp`
	@sonobuoy delete --all