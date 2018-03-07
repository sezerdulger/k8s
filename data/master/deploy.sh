#!/bin/bash
. config.sh

function initDeploy {
  for i in "$@"
  do
    case $i in
      -p=*|--path=*)
      YAML_PATH="${p#*=}"
      ;;
      --default)
      DEFAULT=YES
      ;;
      *)
      ;;
    esac
  done
}

initDeploy $@

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