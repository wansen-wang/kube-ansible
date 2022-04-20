#!/bin/bash
command -v yum &>/dev/null && export PKG=yum
command -v apt &>/dev/null && export PKG=apt
command -v apk &>/dev/null && export PKG=apk
case ${PKG} in
'yum')
    yum install -y epel-release
    yum install python3 python3-pip sshpass curl rsync wget -y
    export ANSIBLE_VERSION=4.10.0
    ;;
'apt')
    apt-get update
    apt-get install python3 python3-pip sshpass curl rsync wget -y
    export ANSIBLE_VERSION=5.6.0
    ;;
'*')
    echo "unknow OS version."
    exit 1
    ;;
esac
pip3 install --upgrade -i https://pypi.tuna.tsinghua.edu.cn/simple pip
pip3 install --upgrade -i https://pypi.tuna.tsinghua.edu.cn/simple --ignore-installed "ansible==${ANSIBLE_VERSION}" IPy requests kubernetes openshift

[ -f /usr/local/bin/yq ] || wget https://github.com/mikefarah/yq/releases/download/v4.13.4/yq_linux_amd64 -O /usr/local/bin/yq
chmod +x /usr/local/bin/yq