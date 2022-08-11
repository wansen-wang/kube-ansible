#!/usr/bin/env python3
import argparse
import os
import sys
import requests
import json
from version import version_map


def Download(url, path):
    response = requests.get(url, stream=True)
    size = 0
    chunk_size = 1024
    content_size = int(response.headers['content-length'])
    try:
        if response.status_code == 200:
            print('=> start download {name} {size:.2f} MB'.format(
                name=os.path.basename(path), size=content_size / chunk_size / 1024)
            )
            with open(path, 'wb') as file:
                for data in response.iter_content(chunk_size=chunk_size):
                    file.write(data)
                    size += len(data)
                    print('\r' + '%s %.2f%%' % (
                        '*' * int(size * 50 / content_size), float(size / content_size * 100)), end=' ')
            print()
            return True
        else:
            raise Exception(response.status_code)
    except Exception as e:
        print("Exception occurs in Downloading, status code: %s..." % e)
        return False


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
                "%s/%s/%s" % (url, directory, src.replace("./src/", "")), data=content, auth=auth)
        else:
            resp = requests.put(
                "%s/%s/%s" % (url, directory, src.replace("./src/", "")), data=content)
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


def downloadToLocal(arg):
    kubeVersion = arg.kubernetes[:4]

    basePath = os.path.split(os.path.realpath(__file__))[0]
    basePath = basePath + "/src/" + arg.kubernetes
    if not os.path.exists(basePath):
        os.makedirs(basePath)

    jsonFile = []
    version = version_map.get(kubeVersion).get('runtime').get('docker')
    if version is not None:
        url = "https://download.docker.com/linux/static/stable/x86_64/docker-%s.tgz" % version
        if Download(url, "%s/docker-%s.tgz" % (basePath, version)):
            jsonFile.append(
                {
                    'src': "./src/%s/docker-%s.tgz" % (arg.kubernetes, version),
                    'dest': "/linux/static/stable/x86_64"
                }
            )

    version = version_map.get(kubeVersion).get('runtime').get('crio')
    if version is not None:
        url = "https://github.com/cri-o/cri-o/releases/download/v%s/cri-o.amd64.v%s.tar.gz" % (version, version)
        if Download(url, "%s/cri-o.amd64.v%s.tar.gz" % (basePath, version)):
            jsonFile.append(
                {
                    'src': "./src/%s/cri-o.amd64.v%s.tar.gz" % (arg.kubernetes, version),
                    'dest': "/cri-o/cri-o/releases/download/v%s" % version
                }
            )

    version = version_map.get(kubeVersion).get('runtime').get('containerd')
    if version is not None:
        url = "https://github.com/containerd/containerd/releases/download/v%s/containerd-%s-linux-amd64.tar.gz" % (
            version, version)
        if Download(url, "%s/containerd-%s-linux-amd64.tar.gz" % (basePath, version)):
            jsonFile.append(
                {
                    'src': "./src/%s/containerd-%s-linux-amd64.tar.gz" % (arg.kubernetes, version),
                    'dest': "/containerd/containerd/releases/download/v%s" % version
                }
            )

    version = version_map.get(kubeVersion).get('runtime').get('runc')
    if version is not None:
        url = "https://github.com/opencontainers/runc/releases/download/v%s/runc.amd64" % (version)
        if Download(url, "%s/runc.amd64" % basePath):
            jsonFile.append(
                {
                    'src': "./src/%s/runc.amd64" % arg.kubernetes,
                    'dest': "/opencontainers/runc/releases/download/v%s" % version
                }
            )

    version = version_map.get(kubeVersion).get('runtime').get('crictl')
    if version is not None:
        url = "https://github.com/kubernetes-sigs/cri-tools/releases/download/v%s/crictl-v%s-linux-amd64.tar.gz" % (
            version, version)
        if Download(url, "%s/crictl-v%s-linux-amd64.tar.gz" % (basePath, version)):
            jsonFile.append(
                {
                    'src': "./src/%s/crictl-v%s-linux-amd64.tar.gz" % (arg.kubernetes, version),
                    'dest': "/kubernetes-sigs/cri-tools/releases/download/v%s" % version
                }
            )

    version = version_map.get(kubeVersion).get('etcd')
    if version is not None:
        url = "https://github.com/coreos/etcd/releases/download/v%s/etcd-v%s-linux-amd64.tar.gz" % (version, version)
        if Download(url, "%s/etcd-v%s-linux-amd64.tar.gz" % (basePath, version)):
            jsonFile.append(
                {
                    'src': "./src/%s/etcd-v%s-linux-amd64.tar.gz" % (arg.kubernetes, version),
                    'dest': "/coreos/etcd/releases/download/v%s" % version
                }
            )

    file_list = [
        "kube-apiserver",
        "kube-controller-manager",
        "kube-scheduler",
        "kubectl",
        "kube-proxy",
        "kubelet",
    ]
    for f in file_list:
        url = "https://storage.googleapis.com/kubernetes-release/release/v%s/bin/linux/amd64/%s" % (
            arg.kubernetes, f)
        if Download(url, "%s/%s" % (basePath, f)):
            jsonFile.append(
                {
                    'src': "./src/%s/%s" % (arg.kubernetes, f),
                    'dest': "/kubernetes-release/release/v%s/bin/linux/amd64" % arg.kubernetes
                }
            )

    version = version_map.get(kubeVersion).get('cni')
    if version is not None:
        url = "https://github.com/containernetworking/plugins/releases/download/v%s/cni-plugins-linux-amd64-v%s.tgz" % (
            version, version)
        if Download(url, "%s/cni-plugins-linux-amd64-v%s.tgz" % (basePath, version)):
            jsonFile.append(
                {
                    'src': "./src/%s/cni-plugins-linux-amd64-v%s.tgz" % (arg.kubernetes, version),
                    'dest': "/containernetworking/plugins/releases/download/v%s" % version
                }
            )

    with open("./src/%s.json" % arg.kubernetes, "w") as f:
        json.dump(jsonFile, f)

    print("files is save on src directory")


def uploadToNexus(arg):
    nexus = Nexus(arg.url, arg.repository, arg.username, arg.password)
    if not nexus.Auth():
        print("Username or Password is error!")
        sys.exit(2)
    print("Upload package to nexus...")
    with open("./src/%s.json" % arg.kubernetes, "r") as f:
        for item in json.load(f):
            nexus.Upload(src=item.get('src'), directory=item.get('dest'))
    sys.exit(0)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Download package and upload to nexus.')
    subparsers = parser.add_subparsers(
        title='commands',
        description='download or upload',
        help='download or upload'
    )
    download = subparsers.add_parser('download')
    download.add_argument('--kubernetes', metavar='kubernetes', required=True, help='kubernetes version')
    download.set_defaults(func=downloadToLocal)

    upload = subparsers.add_parser('upload')
    upload.add_argument('--kubernetes', metavar='kubernetes', required=True, help='kubernetes version')
    upload.add_argument('--url', metavar='url', help='nexus url', required=True)
    upload.add_argument('--repository', metavar='repository', help='nexus repository name', required=True)
    upload.add_argument('--username', default=None, metavar='username', help='nexus username', required=True)
    upload.add_argument('--password', default=None, metavar='password', help='nexus password', required=True)
    upload.set_defaults(func=uploadToNexus)

    args = parser.parse_args()
    args.func(args)
