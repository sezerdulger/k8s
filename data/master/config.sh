#!/bin/bash
source <(grep -v '^ *#' ./install.properties | grep '[^ ] *=' | awk '{split($0,a,"="); print gensub(/\./, "_", "g", a[1]) "=" a[2]}')
