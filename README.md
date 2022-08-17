# kube-ansible

This project will used ansible to deployment kubernetes.

Read the documentation to see how the project is used

* [group_vars/README.md](https://github.com/buxiaomo/kube-ansible/blob/master/group_vars/README.md)
* [inventory/README.md](https://github.com/buxiaomo/kube-ansible/blob/master/inventory/README.md)

## Cloud Support

* [x] Raspberry Pi
* [x] Azure
* [ ] Aliyun (no test)
* [x] Aws (APIServer HA use the CLB)
* [x] GCP (APIServer HA use the TCP Load balancing)

## Architecture Support

* [x] aarch64 (only download from official)
* [x] x86_64

## OS Support

All node please install python3.

* [x] CentOS 7.*
* [x] CentOS 8.*
* [x] Ubuntu 16.*
* [x] Ubuntu 18.*
* [x] Ubuntu 20.*
* [x] Debian 10.*
* [x] Debian 11.*

## Version of the relationship

| Kubernetes | Etcd | Docker | CNI | CoreDNS | Calico | cri-tools | metrics-server | 
|---|---|---|---|---|---|---|---|
| [1.14.x](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.14.md) | v3.3.10 | 18.09.9 | v0.7.5 | v1.3.1 | v3.3.1 | v1.12.0 |  v0.3.1 |
| [1.15.x](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.15.md) | v3.3.10 | 18.09.9 | v0.7.5 | v1.3.1 | v3.3.1 | v1.14.0 |  v0.3.3 |
| [1.16.x](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.16.md) | v3.3.15 | 18.09.9 | v0.7.5 | v1.6.2 | v3.3.1 | v1.14.0 |  v0.3.4 |
| [1.17.x](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.17.md) | v3.4.3 | 19.03.9 | v0.7.5 | v1.6.2 | v3.3.1 | v1.14.0 |  v0.3.4 |
| [1.18.x](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.18.md) | v3.4.3 | 19.03.9 | v0.8.5 | v1.6.7 | v3.8.4 | v1.17.0 |  v0.3.4 |
| [1.19.x](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.19.md) | v3.4.9 | 19.03.9 | v0.8.6 | v1.6.7 | v3.8.4 | v1.17.0 |  v0.3.4 |
| [1.20.x](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.20.md) | v3.4.13 | 19.03.9 | v0.8.7 | v1.6.7 | v3.8.4 | v1.19.0 |  v0.3.4 |
| [1.21.x](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.21.md) | v3.4.13 | 20.10.16 | v0.8.7 | v1.6.7 | v3.8.4 | v1.20.0 |  v0.3.4 |
| [1.22.x](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.22.md) | v3.5.0 | 20.10.16 | v0.9.1 | v1.3.1 | v3.19.1 | v1.21.0 |  v0.4.4 |
| [1.23.x](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.23.md) | v3.5.0 | 20.10.16 | v0.9.1 | v1.3.1 | v3.19.1 | v1.22.0 |  v0.4.4 |
| [1.24.x](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.24.md) | v3.5.3 | 20.10.16 | v0.9.1 | v1.3.1 | v3.19.1 | v1.22.0 |  v0.4.4 |

## How to use

The playbook depends on python3, all nodes need to install python3.

### Preparation work

#### Clone code

Gitee: https://gitee.com/buxiaomo/kube-ansible.git

Gitlab: https://gitlab.com/buxiaomo/kube-ansible.git

Github: https://github.com/buxiaomo/kube-ansible.git

JiHulab: https://jihulab.com/buxiaomo/kube-ansible.git
```
# ubuntu
apt-get update
apt-get install git make -y

# centos
yum install git make vim -y

# clone code
git clone -b 1.14 https://github.com/buxiaomo/kube-ansible.git /usr/local/src/kube-ansible
cd /usr/local/src/kube-ansible
```

#### Install ansible

```
make runtime
```

#### Configuration parameters

```
cd group_vars
make
```

* [group_vars/README.md](https://github.com/buxiaomo/kube-ansible/blob/master/group_vars/README.md)

#### Configuration inventory

for example:

```
# cd /usr/local/src/kube-ansible
# cat inventory/hosts
[master]
192.168.56.10

[worker]
192.168.56.11

[kubernetes:children]
master
worker

[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_port=22
ansible_ssh_user=root
# ansible_ssh_pass=root
# ansible_sudo_user=root
# ansible_sudo_pass=root

```

For more instructions reference [inventory/README.md](https://github.com/buxiaomo/kube-ansible/blob/master/inventory/README.md)


#### <span id = "download">Download the way</span>

* nexus

	You can run `./scripts/nexus.py` script on internet virtual machine to download pachage and then upload to nexus.

```
# download
cd /usr/local/src/kube-ansible
pip3 install requests
./scripts/nexus.py download --kubernetes 1.14.10

# upload
cd /usr/local/src/kube-ansible
pip3 install requests
./scripts/nexus.py upload \
--kubernetes 1.14.10 \
--url http://nexus.example.com \
--repository kube-ansible \
--username admin --password admin
```

* official

  It will be download from Github or Google


about Makefile parameter

| Parameter  | describe  |  Default | option |
|---|---|---|---|
| PKI_URL | PKI Server, about pki server, you can reference [here](https://github.com/buxiaomo/pki-server) | N/A | pki server url |
| PROJECT_NAME | Project Name  | kube-ansible  | used by pki server |
| PROJECT_ENV | Project Env  | dev  | used by pki server|
| DOWNLOAD_WAY | Binary download mode  | official  | official or nexus |
| KUBE_VERSION | Kubernetes binary version  | latest | N/A |
| KUBE_RUNTIME | Kubernetes container runtime  | docker | docker or containerd |
| KUBE_NETWORK | Kubernetes network plugin  | calico | calico, canal, flannel |
| REGISTRY_URL | Private registry url | N/A | N/A |
| NEXUS_DOMAIN_NAME | Nexus domain name  | N/A | N/A |
| NEXUS_REPOSITORY | Nexus repository name | kube-ansible | N/A |
| NEXUS_USERNAME | Nexus username  | N/A  | N/A |
| NEXUS_PASSWORD | Nexus password  | N/A  | N/A |


### Kubernetes management

#### Deploy

```
cd /usr/local/src/kube-ansible

# download from official
make deploy DOWNLOAD_WAY=official KUBE_VERSION=1.14.10 KUBE_NETWORK=calico

# download from nexus 
make deploy DOWNLOAD_WAY=nexus KUBE_VERSION=1.14.10 KUBE_NETWORK=calico \
NEXUS_DOMAIN_NAME=http://nexus.example.com \
NEXUS_REPOSITORY=kube-ansible \
NEXUS_USERNAME=admin \
NEXUS_PASSWORD=admin
```

[![asciicast](https://asciinema.org/a/514169.svg)](https://asciinema.org/a/514169)

#### Scale

```
cd /usr/local/src/kube-ansible

make scale
```

[![asciicast](https://asciinema.org/a/NfYKR4PEimGQSKIjR0eKkSeOo.svg)](https://asciinema.org/a/NfYKR4PEimGQSKIjR0eKkSeOo)

#### Upgrade

Download new kubernetes binaries, Reference [here](#download).

```
cd /usr/local/src/kube-ansible

make upgrade KUBE_VERSION=1.14.10
```

## Known Issues 

* error: Following Cgroup subsystem not mounted: [memory], see [here](https://github.com/buxiaomo/kube-ansible/issues/2)


## knowledge

* [download kubernetes](https://www.downloadkubernetes.com)
* [kubernetes](https://github.com/kubernetes/kubernetes)
* [kubernetes changelog](https://github.com/kubernetes/kubernetes/tree/master/CHANGELOG)
* [kubernetes command line tools reference](https://kubernetes.io/zh/docs/reference/command-line-tools-reference/feature-gates/)
* [calico](https://docs.projectcalico.org/getting-started/kubernetes/quickstart)
* [canal](https://docs.projectcalico.org/getting-started/kubernetes/flannel/flannel) 
* [flannel](https://github.com/coreos/flannel#flannel)
* [cilium](https://docs.cilium.io/en/stable/gettingstarted/#gs-guide)
* [hubble](https://github.com/cilium/hubble)
* [metrics-server](https://github.com/kubernetes-sigs/metrics-server)
* [coredns on k8s](https://github.com/coredns/deployment/blob/master/kubernetes/CoreDNS-k8s_version.md)
* [certificates](https://kubernetes.io/zh/docs/setup/best-practices/certificates/)
* [k8s_the_hard_way](https://github.com/pythops/k8s_the_hard_way)
* [IPv4/IPv6 dual-stack](https://kubernetes.io/zh/docs/concepts/services-networking/dual-stack/)
* [validate IPv4/IPv6 dual-stack](https://kubernetes.io/zh/docs/tasks/network/validate-dual-stack/)
* [CoreDNS k8s version](https://github.com/coredns/deployment/blob/master/kubernetes/CoreDNS-k8s_version.md)


<!-- 
kubectl get node -A -o=jsonpath='{range .items[*]}{.status.addresses[1].address}{":\t"}{.status.allocatable.memory}{":\t"}{.status.capacity.memory}{"\n"}{end}'

cat <<EOF | kubectl apply --kubeconfig admin.kubeconfig -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"
EOF

cat <<EOF | kubectl apply --kubeconfig admin.kubeconfig -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kubernetes
EOF

# Ubuntu 20.04
"ansible_distribution": "Ubuntu",
"ansible_distribution_file_parsed": true,
"ansible_distribution_file_path": "/etc/os-release",
"ansible_distribution_file_variety": "Debian",
"ansible_distribution_major_version": "20",
"ansible_distribution_release": "focal",
"ansible_distribution_version": "20.04",

# CentOS 7.9
"ansible_distribution": "CentOS",
"ansible_distribution_file_parsed": true,
"ansible_distribution_file_path": "/etc/redhat-release",
"ansible_distribution_file_variety": "RedHat",
"ansible_distribution_major_version": "7",
"ansible_distribution_release": "Core",
"ansible_distribution_version": "7.9",

# CentOS 8
"ansible_distribution": "CentOS",
"ansible_distribution_file_parsed": true,
"ansible_distribution_file_path": "/etc/centos-release",
"ansible_distribution_file_variety": "CentOS",
"ansible_distribution_major_version": "8",
"ansible_distribution_release": "Stream",
"ansible_distribution_version": "8",

# Debian 11
"ansible_distribution": "Debian",
"ansible_distribution_file_parsed": true,
"ansible_distribution_file_path": "/etc/os-release",
"ansible_distribution_file_variety": "Debian",
"ansible_distribution_major_version": "11",
"ansible_distribution_release": "bullseye",
"ansible_distribution_version": "11",

# master
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --permanent --add-port=8472/udp

# worker
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --permanent --add-port=8472/udp
firewall-cmd --permanent --add-port=30000-32767/tcp

## Size of master and master components

### GCP

* 1-5 nodes: n1-standard-1
* 6-10 nodes: n1-standard-2
* 11-100 nodes: n1-standard-4
* 101-250 nodes: n1-standard-8
* 251-500 nodes: n1-standard-16
* more than 500 nodes: n1-standard-32

### AWS

* 1-5 nodes: m3.medium
* 6-10 nodes: m3.large
* 11-100 nodes: m3.xlarge
* 101-250 nodes: m3.2xlarge
* 251-500 nodes: c4.4xlarge
* more than 500 nodes: c4.8xlarge
-->