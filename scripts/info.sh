echo '-------------------------------------------------------------------------------'
echo ' __        ___.                                         ._____.   .__          '
echo '|  | ____ _\_ |__   ____           _____    ____   _____|__\_ |__ |  |   ____  '
echo '|  |/ /  |  \ __ \_/ __ \   ______ \__  \  /    \ /  ___/  || __ \|  | _/ __ \ '
echo '|    <|  |  / \_\ \  ___/  /_____/  / __ \|   |  \\___ \|  || \_\ \  |_\  ___/ '
echo '|__|_ \____/|___  /\___  >         (____  /___|  /____  >__||___  /____/\___  >'
echo '     \/         \/     \/               \/     \/     \/        \/          \/ '
echo '-------------------------------------------------------------------------------'
ARCH=$(uname -m)
if [ ${ARCH} != "aarch64" ] || [ ${ARCH} != "x86_64" ]
    echo -e "${ARCH} architecture is not supported!"
    exit 0
fi

echo -e "Binary download mode: \t\t${DOWNLOAD_WAY}"
echo -e "Kubernetes runtime mode: \t${RUNTIME}"
echo -e "Kubernetes version: \t\t${KUBE_VERSION}"
echo -e "Etcd version: \t\t\t${ETCD_VERSION}"
if [ ${RUNTIME} == 'docker' ]; then
echo -e "Docker version: \t\t${DOCKER_VERSION}"
else
echo -e "Containerd version: \t\t${CONTAINERD_VERSION}"
echo -e "Crictl version: \t\t${CRICTL_VERSION}"
echo -e "Runc version: \t\t\t${RUNC_VERSION}"
fi
echo -e "CNI version: \t\t\t${CNI_VERSION}"
sleep 5
# read -n1 -p "Do you want to continue [Y/N]?" answer
# case $answer in
#     Y | y)
#         echo "fine ,continue"
#         ;;
#     N | n)
#         echo "ok,good bye"
#         ;;
#     *)
#         echo "error choice"
#         ;;
# esac
# exit 0