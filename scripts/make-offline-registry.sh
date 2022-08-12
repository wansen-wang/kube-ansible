#!/bin/bash
SHELL_FOLDER=$(dirname $(readlink -f "$0"))
command -v docker &> /dev/null || curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
mkdir -p /etc/docker
cat > /etc/docker/daemon.json << EOF
{
    "builder": {
        "gc": {
            "defaultKeepStorage": "20GB",
            "enabled": true
        }
    },
    "data-root": "/var/lib/docker",
    "debug": false,
    "default-ulimits": {
        "core": {
            "Hard": -1,
            "Name": "core",
            "Soft": -1
        },
        "nofile": {
            "Hard": 65535,
            "Name": "nofile",
            "Soft": 65535
        },
        "nproc": {
            "Hard": 65535,
            "Name": "nproc",
            "Soft": 65535
        }
    },
    "exec-opts": [
        "native.cgroupdriver=systemd"
    ],
    "experimental": false,
    "features": {
        "buildkit": false
    },
    "icc": false,
    "insecure-registries": [
        "0.0.0.0/0"
    ],
    "log-driver": "json-file",
    "log-opts": {
        "max-file": "5",
        "max-size": "100m"
    },
    "max-concurrent-downloads": 20,
    "max-concurrent-uploads": 10,
    "registry-mirrors": [
        "https://i3jtbyvy.mirror.aliyuncs.com"
    ],
    "storage-driver": "overlay2",
    "storage-opts": [
        "overlay2.override_kernel_check=true"
    ],
    "userland-proxy": false
}
EOF
systemctl restart docker.service
sleep 5

docker rm -f registry
docker run -d --name registry \
-p 5000:5000 --restart always \
-v ${SHELL_FOLDER}/src/registry:/var/lib/registry \
registry:2.8.1

REGISTRY_URL="127.0.0.1:5000/infra"

docker pull calico/cni:v3.12.3
docker tag calico/cni:v3.12.3 ${REGISTRY_URL}/calico/cni:v3.12.3
docker push ${REGISTRY_URL}/calico/cni:v3.12.3

docker pull calico/pod2daemon-flexvol:v3.12.3
docker tag calico/pod2daemon-flexvol:v3.12.3 ${REGISTRY_URL}/calico/pod2daemon-flexvol:v3.12.3
docker push ${REGISTRY_URL}/calico/pod2daemon-flexvol:v3.12.3

docker pull calico/node:v3.12.3
docker tag calico/node:v3.12.3 ${REGISTRY_URL}/calico/node:v3.12.3
docker push ${REGISTRY_URL}/calico/node:v3.12.3

docker pull quay.io/coreos/flannel:v0.11.0
docker tag quay.io/coreos/flannel:v0.11.0 ${REGISTRY_URL}/coreos/flannel:v0.11.0
docker push ${REGISTRY_URL}/coreos/flannel:v0.11.0

docker pull calico/kube-controllers:v3.12.3
docker tag calico/kube-controllers:v3.12.3 ${REGISTRY_URL}/calico/kube-controllers:v3.12.3
docker push ${REGISTRY_URL}/calico/kube-controllers:v3.12.3

docker pull coredns/coredns:1.6.7
docker tag coredns/coredns:1.6.7 ${REGISTRY_URL}/coredns/coredns:1.6.7
docker push ${REGISTRY_URL}/coredns/coredns:1.6.7


docker pull rancher/mirrored-flannelcni-flannel-cni-plugin:v1.1.0
docker tag rancher/mirrored-flannelcni-flannel-cni-plugin:v1.1.0 ${REGISTRY_URL}/rancher/mirrored-flannelcni-flannel-cni-plugin:v1.1.0
docker push ${REGISTRY_URL}/rancher/mirrored-flannelcni-flannel-cni-plugin:v1.1.0


docker pull rancher/mirrored-flannelcni-flannel:v0.19.0
docker tag rancher/mirrored-flannelcni-flannel:v0.19.0 ${REGISTRY_URL}/rancher/mirrored-flannelcni-flannel:v0.19.0
docker push ${REGISTRY_URL}/rancher/mirrored-flannelcni-flannel:v0.19.0

docker pull k8s.gcr.io/metrics-server/metrics-server:v0.5.2
docker tag k8s.gcr.io/metrics-server/metrics-server:v0.5.2 ${REGISTRY_URL}/metrics-server/metrics-server:v0.5.2