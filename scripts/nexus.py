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
            filepath = "./src/%s" % path
            with open(filepath, 'wb') as file:
                for data in response.iter_content(chunk_size=chunk_size):
                    file.write(data)
                    size += len(data)
                    print('\r' + '%s %.2f%%' % (
                        '*' * int(size * 50 / content_size), float(size / content_size * 100)), end=' ')
            print()
        else:
            raise Exception(response.status_code)
    except Exception as e:
        print("Exception occurs in Downloading: %s..." % e)


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


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Download package and upload to nexus.')
    action = parser.add_mutually_exclusive_group(required=True)
    parser.add_argument('--kubernetes', metavar='kubernetes', required=True, help='kubernetes version')
    parser.add_argument('--url', metavar='url', help='nexus url', required=True, type=str)
    parser.add_argument('--repository', metavar='repository', help='nexus repository name', required=True, type=str)
    parser.add_argument('--username', default=None, metavar='username', help='nexus username')
    parser.add_argument('--password', default=None, metavar='password', help='nexus password')
    action.add_argument('--download', metavar='download', type=bool, help='download or upload file',
                        action=argparse.BooleanOptionalAction)
    # action.add_argument('--upload', metavar='upload', type=bool, help='only upload file to nexus',
    #                     action=argparse.BooleanOptionalAction)
    options = parser.parse_args()

    if options.url == "" or options.repository == "" or options.kubernetes == "":
        parser.print_help()
        sys.exit(1)

    if not os.path.exists("src"):
        os.makedirs("src")

    if not options.download:
        nexus = Nexus(options.url, options.repository, options.username, options.password)
        if not nexus.Auth():
            print("Username or Password is error!")
            sys.exit(2)
        print("Upload package to nexus...")
        with open("./src/upload.json", "r") as f:
            for item in json.load(f):
                nexus.Upload(src=item.get('src'), directory=item.get('dest'))
        sys.exit(0)

    upload = []
    kubeVersion = options.kubernetes[:4]

    version = version_map.get(kubeVersion).get('runtime').get('docker')
    url = "https://download.docker.com/linux/static/stable/x86_64/docker-%s.tgz" % version
    Download(url, "docker-%s.tgz" % version)
    upload.append(
        {
            'src': "./src/docker-%s.tgz" % version,
            'dest': "/linux/static/stable/x86_64"
        }
    )

    version = version_map.get(kubeVersion).get('etcd')
    url = "https://github.com/coreos/etcd/releases/download/v%s/etcd-v%s-linux-amd64.tar.gz" % (version, version)
    Download(url, "etcd-v%s-linux-amd64.tar.gz" % version)
    upload.append(
        {
            'src': "./src/etcd-v%s-linux-amd64.tar.gz" % version,
            'dest': "/coreos/etcd/releases/download/v%s" % version
        }
    )

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
        url = "https://storage.googleapis.com/kubernetes-release/release/v%s/bin/linux/amd64/%s" % (
            options.kubernetes, f)
        Download(url, f)
        upload.append(
            {
                'src': "./src/%s" % f,
                'dest': "/kubernetes-release/release/v%s/bin/linux/amd64" % options.kubernetes
            }
        )

    version = version_map.get(kubeVersion).get('cni')
    url = "https://github.com/containernetworking/plugins/releases/download/v%s/cni-plugins-linux-amd64-v%s.tgz" % (
        version, version)
    Download(url, "cni-plugins-linux-amd64-v%s.tgz" % version)
    upload.append(
        {
            'src': "./src/cni-plugins-linux-amd64-v%s.tgz" % version,
            'dest': "/containernetworking/plugins/releases/download/v%s" % version
        }
    )

    with open("./src/upload.json", "w") as f:
        json.dump(upload, f)

    print("files is save on src directory")

    # if options.containerd != "" and options.containerd is not None:
    #     if options.download:
    #         print("Download containerd package...")
    #         Download(
    #             "https://github.com/containerd/containerd/releases/download/v%s/containerd-%s.linux-amd64.tar.gz" % (
    #                 options.containerd, options.containerd), "containerd-%s.linux-amd64.tar.gz" % options.containerd)
    #     if options.upload:
    #         print("Upload containerd package...")
    #         nexus.Upload(src="./src/containerd-%s.linux-amd64.tar.gz" % options.containerd,
    #                      directory="/containerd/containerd/releases/download/v%s" % options.containerd)
    #
    # if options.runc != "" and options.runc is not None:
    #     if options.download:
    #         print("Download runc package...")
    #         Download("https://github.com/opencontainers/runc/releases/download/v%s/runc.amd64" %
    #                  (options.runc), "runc.amd64")
    #     if options.upload:
    #         print("Upload runc package...")
    #         nexus.Upload(src="./src/runc.amd64",
    #                      directory="/opencontainers/runc/releases/download/v%s" % options.runc)
    #
    # if options.crictl != "" and options.crictl is not None:
    #     if options.download:
    #         print("Download crictl package...")
    #         Download(
    #             "https://github.com/kubernetes-sigs/cri-tools/releases/download/v%s/crictl-v%s-linux-amd64.tar.gz" % (
    #                 options.crictl, options.crictl), "crictl-v%s-linux-amd64.tar.gz" % options.crictl)
    #
    #     if options.upload:
    #         print("Upload crictl package...")
    #         nexus.Upload(src="./src/crictl-v%s-linux-amd64.tar.gz" % options.crictl,
    #                      directory="/kubernetes-sigs/cri-tools/releases/download/v%s" % options.crictl)
    #
    # print("files is save on .tmp directory")
