#!/bin/bash
source <(grep -v '^ *#' /data/master/install.properties | grep '[^ ] *=' | awk '{split($0,a,"="); print gensub(/\./, "_", "g", a[1]) "=" a[2]}')

function init {
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

init $@

function install {
  echo "Installing docker-ce..."
  apt-get update
  apt-get install -y apt-transport-https ca-certificates curl software-properties-common
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
  apt-get install bash-completion
}

function deploy {
  echo "Available services : "
  for i in ${common_base_services[*]}; do
    #kubectl create -f $i -R
    echo $i
  done
  
  #sleep $common_delay_after_base_services
  
  for i in ${common_services[*]}; do
    #kubectl create -f $i -R
    echo $i
  done
}

function master {
  swapoff -a
  kubeadm init --apiserver-advertise-address=$MASTER_IP --token $JOIN_TOKEN
  echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bashrc
  export KUBECONFIG=/etc/kubernetes/admin.conf
  source <(kubectl completion bash)
  echo "source <(kubectl completion bash)" >> ~/.bashrc
  sysctl net.bridge.bridge-nf-call-iptables=1
  export kubever=$(kubectl version | base64 | tr -d '\n')
  kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"

}

function slave {
  swapoff -a
  kubeadm join $MASTER_IP:6443 --token $JOIN_TOKEN
  route add 10.96.0.1 gw $MASTER_IP
}

$@