#!/bin/bash
. config.sh

function initInstall {
  for i in "$@"
  do
    case $i in
      -i=*|--install=*)
      INSTALL="${i#*=}"
      ;;
      --default)
      DEFAULT=YES
      ;;
      *)
      ;;
    esac
  done
}

initInstall $@

function install {
  echo "Installing docker-ce..."
  apt-get update
  apt-get install apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  apt-get update
  apt-get install -y docker-ce
  
  echo "Installing kubernetes..."
  apt-get update && apt-get install -y apt-transport-https
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
  apt-get update
  apt-get install -y kubelet=1.8.7-00 kubeadm=1.8.7-00 kubectl=1.8.7-00 kubernetes-cni=0.5.1-00
}