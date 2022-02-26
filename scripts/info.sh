#!/bin/bash
echo '-------------------------------------------------------------------------------'
echo ' __        ___.                                         ._____.   .__          '
echo '|  | ____ _\_ |__   ____           _____    ____   _____|__\_ |__ |  |   ____  '
echo '|  |/ /  |  \ __ \_/ __ \   ______ \__  \  /    \ /  ___/  || __ \|  | _/ __ \ '
echo '|    <|  |  / \_\ \  ___/  /_____/  / __ \|   |  \\___ \|  || \_\ \  |_\  ___/ '
echo '|__|_ \____/|___  /\___  >         (____  /___|  /____  >__||___  /____/\___  >'
echo '     \/         \/     \/               \/     \/     \/        \/          \/ '
echo '-------------------------------------------------------------------------------'
ARCH=$(uname -m)
if [ ${ARCH} != "aarch64" ] && [ ${ARCH} != "x86_64" ]; then
  echo -e "${ARCH} architecture is not supported!"
  exit 0
fi
ANSIBLE_ARG=""
if [ ${DOWNLOAD_WAY} == "nexus" ]; then
  if [[ ${NEXUS_USERNAME} == "" || ${NEXUS_PASSWORD} == "" || ${NEXUS_DOMAIN_NAME} == "" || ${NEXUS_REPOSITORY} == "" ]]; then
    echo -e "\033[31mNexus parameter error, please set NEXUS_HTTP_USERNAME, NEXUS_HTTP_PASSWORD, NEXUS_DOMAIN_NAME, NEXUS_REPOSITORY! \033[0m "
    exit 1
  else
    ANSIBLE_ARG="${ANSIBLE_ARG} -e NEXUS_DOMAIN_NAME=${NEXUS_DOMAIN_NAME} -e NEXUS_REPOSITORY=${NEXUS_REPOSITORY} -e NEXUS_USERNAME=${NEXUS_USERNAME} -e NEXUS_PASSWORD=${NEXUS_PASSWORD}"
  fi
fi

echo -e "Project name: \033[32m${PROJECT_NAME}\033[0m\tProject env: \033[32m${PROJECT_ENV}\033[0m"
echo -e "Binary download mode: \t\t\033[32m${DOWNLOAD_WAY}\033[0m"
echo -e "Kubernetes runtime mode: \t\033[32m${RUNTIME}\033[0m"
echo -e "Kubernetes version: \t\t\033[32m${KUBE_VERSION}\033[0m"
echo -e "Kubernetes IP stack: \t\t\033[32m${IP_STACK}\033[0m"
echo -e "Etcd version: \t\t\t\033[32m${ETCD_VERSION}\033[0m"

if [ ${RUNTIME} == 'docker' ]; then
  echo -e "Docker version: \t\t\033[32m${DOCKER_VERSION}\033[0m"
  ANSIBLE_ARG="${ANSIBLE_ARG} -e DOCKER_VERSION=${DOCKER_VERSION}"
else
  echo -e "Containerd version: \t\t\033[32m${CONTAINERD_VERSION}\033[0m"
  echo -e "Crictl version: \t\t\033[32m${CRICTL_VERSION}\033[0m"
  echo -e "Runc version: \t\t\t\033[32m${RUNC_VERSION}\033[0m"
  ANSIBLE_ARG="${ANSIBLE_ARG} -e DOCKER_VERSION=${DOCKER_VERSION} -e CONTAINERD_VERSION=${CONTAINERD_VERSION} -e RUNC_VERSION=${RUNC_VERSION} -e CRICTL_VERSION=${CRICTL_VERSION}"
fi

echo -e "CNI version: \t\t\t\033[32m${CNI_VERSION}\033[0m"

if [ ${PKI_URL} ]; then
  echo -e "PKI Url: \t\t\t\033[32m${PKI_URL}\033[0m"
  ANSIBLE_ARG="${ANSIBLE_ARG} -e PKI_URL=${PKI_URL}"
fi

sleep 3

case $1 in
"deploy")
  ansible-playbook -i ./inventory/hosts ./deploy.yml \
    -e PROJECT_NAME=${PROJECT_NAME} -e PROJECT_ENV=${PROJECT_ENV} \
    -e DOWNLOAD_WAY=${DOWNLOAD_WAY} \
    -e RUNTIME=${RUNTIME} \
    -e KUBE_VERSION=${KUBE_VERSION} \
    -e ETCD_VERSION=${ETCD_VERSION} \
    -e CNI_VERSION=${CNI_VERSION} \
    -e IP_STACK=${IP_STACK} ${ANSIBLE_ARG}
  ;;
"scale")
  read -p "Enter Host, Multiple hosts are separated by Spaces: " SCALE_HOST_LIST_VER
  for host in ${SCALE_HOST_LIST_VER}; do
    sed -i "/\[worker\]/a ${host}" ./inventory/hosts
  done
  ansible-playbook -i ./inventory/hosts ./scale.yml --limit $(echo ${SCALE_HOST_LIST_VER} | sed 's/ /,/g') \
    -e PROJECT_NAME=${PROJECT_NAME} -e PROJECT_ENV=${PROJECT_ENV} \
    -e DOWNLOAD_WAY=${DOWNLOAD_WAY} \
    -e RUNTIME=${RUNTIME} \
    -e KUBE_VERSION=${KUBE_VERSION} \
    -e ETCD_VERSION=${ETCD_VERSION} \
    -e CNI_VERSION=${CNI_VERSION} \
    -e IP_STACK=${IP_STACK} ${ANSIBLE_ARG}
  ;;
"upgrade")
  ansible-playbook -i ./inventory/hosts ./upgrade.yml \
    -e PROJECT_NAME=${PROJECT_NAME} -e PROJECT_ENV=${PROJECT_ENV} \
    -e DOWNLOAD_WAY=${DOWNLOAD_WAY} \
    -e RUNTIME=${RUNTIME} \
    -e KUBE_VERSION=${KUBE_VERSION} \
    -e ETCD_VERSION=${ETCD_VERSION} \
    -e CNI_VERSION=${CNI_VERSION} \
    -e IP_STACK=${IP_STACK} ${ANSIBLE_ARG}
  ;;
*) ;;
esac
