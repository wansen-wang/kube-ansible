#!/bin/bash
ProgramName=$0
TEMP=`getopt -o ab:c:: --long a-long,b-long:,c-long:: -n 'example.bash' -- "$@"`
function usage() {
    echo "usage: $ProgramName [-abch] [-f infile] [-o outfile]"
    echo "  --mirror                download binary qiniu, official, nexus"
    echo "  --kube-version          turn on feature b"
    echo "  -c          turn on feature c"
    echo "  -h          display help"
    echo "  -f infile   specify input file infile"
    echo "  -o outfile  specify output file outfile"
    exit 1
}

function msg() {
    echo '-------------------------------------------------------------------------------'
    echo ' __        ___.                                         ._____.   .__          '
    echo '|  | ____ _\_ |__   ____           _____    ____   _____|__\_ |__ |  |   ____  '
    echo '|  |/ /  |  \ __ \_/ __ \   ______ \__  \  /    \ /  ___/  || __ \|  | _/ __ \ '
    echo '|    <|  |  / \_\ \  ___/  /_____/  / __ \|   |  \\___ \|  || \_\ \  |_\  ___/ '
    echo '|__|_ \____/|___  /\___  >         (____  /___|  /____  >__||___  /____/\___  >'
    echo '     \/         \/     \/               \/     \/     \/        \/          \/ '
    echo '-------------------------------------------------------------------------------'
    echo -e 'Container runtime:\t docker'
    echo -e 'Kubernetes version:\t 1.22.1'
    echo -e 'Docker version:\t\t docker'
    echo -e 'Docker version:\t\t docker'
}


if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi


echo '-------------------------------------------------------------------------------'
echo ' __        ___.                                         ._____.   .__          '
echo '|  | ____ _\_ |__   ____           _____    ____   _____|__\_ |__ |  |   ____  '
echo '|  |/ /  |  \ __ \_/ __ \   ______ \__  \  /    \ /  ___/  || __ \|  | _/ __ \ '
echo '|    <|  |  / \_\ \  ___/  /_____/  / __ \|   |  \\___ \|  || \_\ \  |_\  ___/ '
echo '|__|_ \____/|___  /\___  >         (____  /___|  /____  >__||___  /____/\___  >'
echo '     \/         \/     \/               \/     \/     \/        \/          \/ '
echo '-------------------------------------------------------------------------------'
echo '    kube-ansible is an easy tool for deploying kubernetes, you can run the'
echo 'following commands to deploy or manage the cluster.'
echo ''
echo 'make runtime, will install the ansible runtime environment'
echo 'make install, will install kubernetes components'
echo 'make scale, will expansion worker node'
echo 'make upgrade, will upgrade kubernetes version'