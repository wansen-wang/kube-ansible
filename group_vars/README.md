# About group vars

## `template/all.yml` file

include configuration

* proxy_env (download file)
* timezone
* modprobe
* ipvs
* sysctl
* limits


## `template/kubernetes.yml` file

include configuration

* docker
* containerd
* etcd
* ha
* loadBalancing
* networking(K8S)
* cloudProvider
* apiServer
* controllerManager
* scheduler
* kubelet
* proxy
* apps
