#!/bin/bash

FUNCTIONS_FILE_REPO="https://raw.githubusercontent.com/KevLeng/keptn-in-a-box/no-keptn-install/functions.sh"
FUNCTIONS_FILE="functions.sh"

DOMAIN=

curl -o functions.sh $FUNCTIONS_FILE_REPO

# --- Loading the functions in the current shell
source $FUNCTIONS_FILE

printInfoSection "Read Dynatrace credentials"

CREDS=$(cat /home/ubuntu/keptn-in-a-box/resources/dynatrace/creds_dt.json)
DT_TENANT=$(echo $CREDS | jq -r '.dynatraceTenant')
DT_API_TOKEN=$(echo $CREDS | jq -r '.dynatraceApiToken')
DT_PAAS_TOKEN=$(echo $CREDS | jq -r '.dynatracePaaSToken')

keptn_install=true
keptn_install_qualitygates=false

setupMagicDomainPublicIp
keptnInstall

bashas "kubectl -n keptn create secret generic dynatrace --from-literal=\"DT_TENANT=$DT_TENANT\" --from-literal=\"DT_API_TOKEN=$DT_API_TOKEN\"  --from-literal=\"DT_PAAS_TOKEN=$DT_PAAS_TOKEN\""
# TODO Split concerns when this is solved https://github.com/keptn/enhancement-proposals/issues/20
bashas "kubectl apply -f https://raw.githubusercontent.com/keptn-contrib/dynatrace-service/$KEPTN_DT_SERVICE_VERSION/deploy/manifests/dynatrace-service/dynatrace-service.yaml"
bashas "kubectl apply -f https://raw.githubusercontent.com/keptn-contrib/dynatrace-sli-service/$KEPTN_DT_SLI_SERVICE_VERSION/deploy/service.yaml"
printInfo "Wait for the Service to be created"
waitForAllPods
bashas "keptn configure monitoring dynatrace"
waitForAllPods

KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -ojsonpath={.data.keptn-api-token} | base64 --decode)
KEPTN_ENDPOINT="https://api.keptn.$DOMAIN"
KEPTN_BRIDGE="http://bridge.keptn.$DOMAIN"

printInfo "KEPTN_BRIDGE: ${KEPTN_BRIDGE}"
printInfo "KEPTN_ENDPOINT: ${KEPTN_ENDPOINT}"
printInfo "KEPTN_API_TOKEN: ${KEPTN_API_TOKEN}"
echo "KEPTN_API_TOKEN:${KEPTN_API_TOKEN}"

rm $FUNCTIONS_FILE