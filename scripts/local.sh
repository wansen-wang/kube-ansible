#!/bin/bash
command -v yq &>/dev/null || (echo "Please install yq." && exit 1) && exit 0
command -v vagrant &>/dev/null || (echo "Please install vagrant." && exit 1) && exit 0
rm -rf .ssh && mkdir -p .ssh
cp -f ./inventory/template/virtualbox.template ./inventory/hosts
ssh-keygen -t rsa -P "" -f ./.ssh/id_rsa
vagrant up
yq e -i '.ha.type="slb"' ./group_vars/kubernetes.yml