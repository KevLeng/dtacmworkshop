#!/bin/bash

FUNCTIONS_FILE_REPO="https://raw.githubusercontent.com/KevLeng/keptn-in-a-box/no-keptn-install/functions.sh"
FUNCTIONS_FILE='functions.sh'
DOMAIN=


curl -o functions.sh $FUNCTIONS_FILE_REPO

# --- Loading the functions in the current shell
source $FUNCTIONS_FILE

keptn_install=true
keptn_install_qualitygates=false

setupMagicDomainPublicIp
keptnInstall

rm $FUNCTIONS_FILE