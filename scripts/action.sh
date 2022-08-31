#!/bin/bash
echo '-------------------------------------------------------------------------------------'
echo '                  ____  __.    ___.                                                 '
echo '                 |    |/ _|__ _\_ |__   ____ _____    _________.__.                 '
echo '                 |      < |  |  \ __ \_/ __ \\__  \  /  ___<   |  |                 '
echo '                 |    |  \|  |  / \_\ \  ___/ / __ \_\___ \ \___  |                 '
echo '                 |____|__ \____/|___  /\___  >____  /____  >/ ____|                 '
echo '                         \/         \/     \/     \/     \/ \/                      '
echo '-------------------------------------------------------------------------------------'

ARCH=$(uname -m)
if [ ${ARCH} != "aarch64" ] && [ ${ARCH} != "x86_64" ]; then
  echo -e "${ARCH} architecture is not supported!"
  exit 0
fi

echo -e "Project name: \033[32m${PROJECT_NAME}\033[0m\tProject env: \033[32m${PROJECT_ENV}\033[0m"
echo -e "Binary download mode: \t\t\033[32m${DOWNLOAD_WAY}\033[0m"
echo -e "Kubernetes runtime mode: \t\033[32m${KUBE_RUNTIME}\033[0m"
echo -e "Kubernetes version: \t\t\033[32m${KUBE_VERSION}\033[0m"
echo -e "Kubernetes network: \t\t\033[32m${KUBE_NETWORK}\033[0m"
ANSIBLE_ENV="-e PROJECT_NAME=${PROJECT_NAME} -e PROJECT_ENV=${PROJECT_ENV} -e DOWNLOAD_WAY=${DOWNLOAD_WAY} -e KUBE_VERSION=${KUBE_VERSION} -e KUBE_RUNTIME=${KUBE_RUNTIME} -e KUBE_NETWORK=${KUBE_NETWORK}"

if [ ${REGISTRY_URL} ]; then
  echo -e "Private registry: \t\t\033[32m${REGISTRY_URL}\033[0m"
  ANSIBLE_ENV="${ANSIBLE_ENV} -e REGISTRY_URL=${REGISTRY_URL}"
fi

if [ ${PKI_URL} ]; then
  echo -e "PKI Url: \t\t\t\033[32m${PKI_URL}\033[0m"
  ANSIBLE_ENV="${ANSIBLE_ENV} -e PKI_URL=${PKI_URL}"
fi

if [ ${DOWNLOAD_WAY} == "nexus" ]; then
  if [[ ${NEXUS_USERNAME} == "" || ${NEXUS_PASSWORD} == "" || ${NEXUS_DOMAIN_NAME} == "" || ${NEXUS_REPOSITORY} == "" ]]; then
    echo -e "\033[31mNexus parameter error, please set NEXUS_HTTP_USERNAME, NEXUS_HTTP_PASSWORD, NEXUS_DOMAIN_NAME, NEXUS_REPOSITORY! \033[0m "
    exit 1
  else
    echo '-------------------------------------------------------------------------------'
    echo -e "Nexus Url: \t\t\t\033[32m${NEXUS_DOMAIN_NAME}\033[0m"
    echo -e "Nexus repository: \t\t\033[32m${NEXUS_REPOSITORY}\033[0m"
    echo -e "Nexus username: \t\t\033[32m${NEXUS_USERNAME}\033[0m"
    echo -e "Nexus password: \t\t\033[32m******\033[0m"
    echo '-------------------------------------------------------------------------------'
    ANSIBLE_ENV="${ANSIBLE_ENV} -e NEXUS_DOMAIN_NAME=${NEXUS_DOMAIN_NAME} -e NEXUS_REPOSITORY=${NEXUS_REPOSITORY} -e NEXUS_USERNAME=${NEXUS_USERNAME} -e NEXUS_PASSWORD=${NEXUS_PASSWORD}"
  fi
fi
case $1 in
"deploy")
  if [ $(git rev-parse --abbrev-ref HEAD) != 'main' ];then
    if [ "v${KUBE_VERSION:0:4}" != $(git rev-parse --abbrev-ref HEAD) ] && [ "v${KUBE_VERSION}" != $(git tag) ];then
      echo -e "\033[31mMessage: The git branch is incorrect, deployment add-on may be incompatible, please checkout to ${KUBE_VERSION:0:4}\033[0m"
      exit 1
    fi
  else
    echo -e "\033[31mMessage: main branch is develop, Please do not use in production.\033[0m"
  fi
  sleep 3
  start=$(date +%s)
  ansible-playbook -i ./inventory/${PROJECT_NAME}-${PROJECT_ENV}.ini ./deploy.yml -e KUBE_ACTION="deploy" ${ANSIBLE_ENV}
  if [ $? -eq 0 ];then
    end=$(date +%s)
    echo -e "\033[32mDeploy kubernetes success, execute commands is $(( end - start )) seconds, please run 'kubectl get po -A' to check the pod status.\033[0m"
  fi
  ;;
"scale")
  read -p "Enter Host, Multiple hosts are separated by Spaces: " SCALE_HOST_LIST_VER
  for host in ${SCALE_HOST_LIST_VER}; do
    sed -n '/^\[worker/,/^\[kubernetes/p' ./inventory/${PROJECT_NAME}-${PROJECT_ENV}.ini | grep -E "^$host$|^$host" &> /dev/null && { echo -e "\033[31mNode ${host} already existed in ./inventory/${PROJECT_NAME}-${PROJECT_ENV}.ini\033[0m"; exit 2; }
  done
  start=$(date +%s)
  for host in ${SCALE_HOST_LIST_VER}; do
    sed -i "/\[worker\]/a ${host}" ./inventory/${PROJECT_NAME}-${PROJECT_ENV}.ini
  done
  ansible-playbook -i ./inventory/${PROJECT_NAME}-${PROJECT_ENV}.ini ./scale.yml --limit $(echo ${SCALE_HOST_LIST_VER} | sed 's/ /,/g') -e KUBE_ACTION="scale" ${ANSIBLE_ENV}
  if [ $? -eq 0 ];then
    end=$(date +%s)
    echo -e "\033[32mScale kubernetes success, execute commands is $(( end - start )) seconds, please run 'kubectl get no -o wide' to check the node status.\033[0m"
  else
    for host in ${SCALE_HOST_LIST_VER}; do
      sed -i "/^${host}/d" ./inventory/${PROJECT_NAME}-${PROJECT_ENV}.ini
    done
  fi
  ;;
"upgrade")
  start=$(date +%s)
  ansible-playbook -i ./inventory/${PROJECT_NAME}-${PROJECT_ENV}.ini ./upgrade.yml -e KUBE_ACTION="upgrade" ${ANSIBLE_ENV}
  echo -e "\033[32mUpgrade kubernetes success, execute commands is $(( end - start )) seconds, please run 'kubectl get no -o wide' to check the node version status.\033[0m"
  ;;
*) ;;
esac
