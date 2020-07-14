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

KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -ojsonpath={.data.keptn-api-token} | base64 --decode)
KEPTN_ENDPOINT="https://api.keptn.$DOMAIN"
KEPTN_BRIDGE="http://bridge.keptn.$DOMAIN"

printInfo "KEPTN_BRIDGE: ${KEPTN_BRIDGE}"
printInfo "KEPTN_ENDPOINT: ${KEPTN_ENDPOINT}"
printInfo "KEPTN_API_TOKEN: ${KEPTN_API_TOKEN}"

rm $FUNCTIONS_FILE