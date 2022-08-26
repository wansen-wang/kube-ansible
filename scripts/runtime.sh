#!/bin/bash
command -v yum &>/dev/null && export PKG=yum
command -v apt &>/dev/null && export PKG=apt
command -v apk &>/dev/null && export PKG=apk
case ${PKG} in
'yum')
    yum install -y epel-release
    yum install python3 python3-pip sshpass curl rsync wget -y
    ;;
'apt')
    apt-get update
    apt-get install python3 python3-pip sshpass curl rsync wget -y
    ;;
'apk')
    apk add --no-cache sshpass curl rsync wget
    ;;
'*')
    echo "unknow OS version."
    exit 1
    ;;
esac
pip3 install --no-cache-dir --upgrade -i https://pypi.tuna.tsinghua.edu.cn/simple pip
pip3 install --no-cache-dir --upgrade -i https://pypi.tuna.tsinghua.edu.cn/simple --ignore-installed "ansible>=4.10.0" IPy requests kubernetes openshift jmespath netaddr packaging