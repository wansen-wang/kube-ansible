# About group vars

Executing the `make` command will copy the files in the template folder to create all.yml and kubernetes.yml

## about `all.yml` file

include configuration

* proxy_env (download file)
* timezone
* modprobe
* ipvs
* sysctl
* limits


## about `kubernetes.yml` file

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
