#!/bin/bash

  while true; do
    readynodes=$(kubectl get node --no-headers  | awk '{print $2}' | grep -w Ready | wc -l)
	echo "readynodes: $readynodes"
    if [[ $readynodes -eq 2 ]]; then
      nonreadypods=$(kubectl get pods --no-headers --all-namespaces | awk '{print $4}' | grep -wv Running | wc -l)
	  echo "nonreadypods: $nonreadypods"
      if [[ $nonreadypods -eq 0 ]]; then
        break
      fi
    fi
	sleep 5
  done
  
  echo "Starting fission deployment..."
  kubectl create ns fission
  curl -LO https://storage.googleapis.com/kubernetes-helm/helm-v2.7.0-linux-amd64.tar.gz
  tar xzf helm-v2.7.0-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin
  kubectl create clusterrolebinding helm --clusterrole=cluster-admin --user=system:serviceaccount:kube-system:default
  sleep 5
  helm init
  while true; do
    helmready=$(helm ls)
	echo "helmready: $helmready"
    if [ -z "$helmready" ]; then
	  break
	fi
	sleep 5
  done
  sleep 30
  helm install --namespace fission --timeout 90 --set serviceType=NodePort https://github.com/fission/fission/releases/download/0.6.1/fission-all-0.6.1.tgz
  sleep 10
  curl -Lo fission https://github.com/fission/fission/releases/download/0.6.1/fission-cli-linux && chmod +x fission && sudo mv fission /usr/local/bin/
  kubectl get pods --namespace=fission
  
  while true; do
      nonreadypods=$(kubectl get pods --no-headers --namespace=fission | awk '{print $3}' | grep -w Pending | wc -l)
	  readypods=$(kubectl get pods --no-headers --namespace=fission | awk '{print $3}' | grep -w Running | wc -l)
	  echo "nonreadypods in fission: $nonreadypods"
      if [[ $nonreadypods -eq 1 ]] && [[ $readypods -eq 11 ]]; then
        break
      fi
	sleep 5
  done
  
  kubectl delete pvc fission-storage-pvc --namespace=fission
  kubectl create -f /data/fission-storage.yaml --namespace=fission
  
  fission env create --name nodejs --image fission/node-env
  curl https://raw.githubusercontent.com/fission/fission/master/examples/nodejs/hello.js > hello.js
  fission function create --name hello --env nodejs --code hello.js
  fission route create --method GET --url /hello --function hello
  fission function test --name hello
