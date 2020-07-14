#!/bin/bash

FUNCTIONS_FILE_REPO="https://raw.githubusercontent.com/KevLeng/keptn-in-a-box/no-keptn-install/functions.sh"
FUNCTIONS_FILE='functions.sh'
FILE='creds_dt.json'
DOMAIN=

curl -o functions.sh $FUNCTIONS_FILE_REPO

# --- Loading the functions in the current shell
source $FUNCTIONS_FILE

printInfoSection "Read Dynatrace credentials"
if [ -f "/home/ubuntu/keptn-in-a-box/resources/dynatrace/{$FILE}" ]; then
    CREDS=$(cat /home/ubuntu/keptn-in-a-box/resources/dynatrace/$FILE)
    DT_TENANT=$(echo $CREDS | jq -r '.dynatraceTenant')
    DT_API_TOKEN=$(echo $CREDS | jq -r '.dynatraceApiToken')
	DT_PAAS_TOKEN=$(echo $CREDS | jq -r '.dynatracePaaSToken')
fi

keptn_install=true
keptn_install_qualitygates=false
dynatrace_configure_monitoring=true

setupMagicDomainPublicIp
keptnInstall
dynatraceConfigureMonitoring

KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -ojsonpath={.data.keptn-api-token} | base64 --decode)
KEPTN_ENDPOINT="https://api.keptn.$DOMAIN"
KEPTN_BRIDGE="http://bridge.keptn.$DOMAIN"

printInfo "KEPTN_BRIDGE: ${KEPTN_BRIDGE}"
printInfo "KEPTN_ENDPOINT: ${KEPTN_ENDPOINT}"
printInfo "KEPTN_API_TOKEN: ${KEPTN_API_TOKEN}"

rm $FUNCTIONS_FILE