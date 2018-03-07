#!/bin/bash
. config.sh
. install.sh
. deploy.sh

function initInstallFromScratch {
  for i in "$@"
  do
    case $i in
      -t=*|--test=*)
      TEST="${p#*=}"
      ;;
      --default)
      DEFAULT=YES
      ;;
      *)
      ;;
    esac
  done
}

initInstallFromScratch $@
install
deploy