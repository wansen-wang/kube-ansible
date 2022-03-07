#!/usr/bin/env python3
import argparse
import os
import sys
import requests


def Download(url, filename):
    r = requests.get(url)
    with open("./.tmp/%s" % filename, "wb") as code:
        code.write(r.content)


class Nexus:
    def __init__(self, url, repository, username, password):
        self.url = url
        self.repository = repository
        self.username = username
        self.password = password

    def Upload(self, src, directory):
        url = '%s/repository/%s' % (self.url, self.repository)
        resp = None
        content = open(src, 'rb').read()
        if self.username is not None and self.password is not None:
            auth = (self.username, self.password)
            resp = requests.put(
                "%s/%s/%s" % (url, directory, src.replace("./.tmp/", "")), data=content, auth=auth)
        else:
            resp = requests.put(
                "%s/%s/%s" % (url, directory, src.replace("./.tmp/", "")), data=content)
        if resp.status_code != 201:
            print("Upload failed, status code: %d" % resp.status_code)
            return False
        else:
            print("Upload success.")
            return True

    def Auth(self):
        url = '%s/service/rest/v1/status/check' % (self.url)
        resp = None
        if self.username is not None and self.password is not None:
            auth = (self.username, self.password)
            resp = requests.get(url, auth=auth)
        else:
            resp = requests.get(url)

        if resp.status_code != 200:
            return False
        else:
            return True


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Download package and upload to nexus.')
    parser.add_argument('--url', metavar='url',
                        help='nexus url', required=True, type=str)
    parser.add_argument('--repository', metavar='repository',
                        help='nexus repository name', required=True, type=str)
    parser.add_argument('--username', default=None,
                        metavar='username', help='nexus username')
    parser.add_argument('--password', default=None,
                        metavar='password', help='nexus password')
    parser.add_argument('--docker', metavar='docker', help='docker version')
    parser.add_argument('--etcd', metavar='etcd', help='etcd version')
    parser.add_argument('--kubernetes', metavar='kubernetes',
                        help='kubernetes version')
    parser.add_argument('--cni', metavar='cni', help='cni plugin version')
    parser.add_argument('--containerd', metavar='containerd',
                        help='containerd version')
    parser.add_argument('--runc', metavar='runc', help='runc version')
    parser.add_argument('--crictl', metavar='crictl', help='crictl version')
    options = parser.parse_args()

    if options.url == "" or options.repository == "":
        parser.print_help()
        sys.exit(1)

    if not os.path.exists(".tmp"):
        os.makedirs(".tmp")

    nexus = Nexus(options.url, options.repository,
                  options.username, options.password)
    if not nexus.Auth():
        print("Username or Password is error!")
        sys.exit(2)

    # nexus.ListComponents()

    if options.docker != "" and options.docker is not None:
        print("Download and Upload docker package...")
        Download("https://download.docker.com/linux/static/stable/x86_64/docker-%s.tgz" % options.docker,
                 "docker-%s.tgz" % options.docker)
        nexus.Upload(src="./.tmp/docker-%s.tgz" % options.docker,
                     directory="/linux/static/stable/x86_64")

    if options.etcd != "" and options.etcd is not None:
        print("Download and Upload etcd package...")
        Download("https://github.com/coreos/etcd/releases/download/v%s/etcd-v%s-linux-amd64.tar.gz" % (
            options.etcd, options.etcd), "etcd-v%s-linux-amd64.tar.gz" % options.etcd)
        nexus.Upload(src="./.tmp/etcd-v%s-linux-amd64.tar.gz" % options.etcd,
                     directory="/coreos/etcd/releases/download/v%s" % options.etcd)

    if options.kubernetes != "" and options.kubernetes is not None:
        print("Download and Upload kubernetes package...")
        file_list = [
            "kube-apiserver",
            "kube-apiserver.sha256",
            "kube-controller-manager",
            "kube-controller-manager.sha256",
            "kube-scheduler",
            "kube-scheduler.sha256",
            "kubectl",
            "kubectl.sha256",
            "kube-proxy",
            "kube-proxy.sha256",
            "kubelet",
            "kubelet.sha256"
        ]
        for f in file_list:
            print("Download and Upload kubernetes package(%s)..." % f)
            Download("https://storage.googleapis.com/kubernetes-release/release/v%s/bin/linux/amd64/%s" %
                     (options.kubernetes, f), f)
            nexus.Upload(
                src="./.tmp/%s" % f, directory="/kubernetes-release/release/v%s/bin/linux/amd64" % options.kubernetes)
    if options.cni != "" and options.cni is not None:
        print("Download and Upload cni package...")
        Download("https://github.com/containernetworking/plugins/releases/download/v%s/cni-plugins-linux-amd64-v%s.tgz" % (
            options.cni, options.cni), "cni-plugins-linux-amd64-v%s.tgz" % options.cni)
        nexus.Upload(src="./.tmp/cni-plugins-linux-amd64-v%s.tgz" % options.cni,
                     directory="/containernetworking/plugins/releases/download/v%s" % options.cni)

    if options.containerd != "" and options.containerd is not None:
        print("Download and Upload containerd package...")
        Download("https://github.com/containerd/containerd/releases/download/v%s/containerd-%s.linux-amd64.tar.gz" % (
            options.containerd, options.containerd), "containerd-%s.linux-amd64.tar.gz" % options.containerd)
        nexus.Upload(src="./.tmp/containerd-%s.linux-amd64.tar.gz" % options.containerd,
                     directory="/containerd/containerd/releases/download/v%s" % options.containerd)

    if options.runc != "" and options.runc is not None:
        print("Download and Upload runc package...")
        Download("https://github.com/opencontainers/runc/releases/download/v%s/runc.amd64" %
                 (options.runc), "runc.amd64")
        nexus.Upload(src="./.tmp/runc.amd64",
                     directory="/opencontainers/runc/releases/download/v%s" % options.runc)

    if options.crictl != "" and options.crictl is not None:
        print("Download and Upload crictl package...")
        Download("https://github.com/kubernetes-sigs/cri-tools/releases/download/v%s/crictl-v%s-linux-amd64.tar.gz" % (
            options.crictl, options.crictl), "crictl-v%s-linux-amd64.tar.gz" % options.crictl)
        nexus.Upload(src="./.tmp/crictl-v%s-linux-amd64.tar.gz" % options.crictl,
                     directory="/kubernetes-sigs/cri-tools/releases/download/v%s" % options.crictl)
