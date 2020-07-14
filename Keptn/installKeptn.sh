#!/bin/bash

FUNCTIONS_FILE_REPO="https://raw.githubusercontent.com/KevLeng/keptn-in-a-box/no-keptn-install/functions.sh"
FUNCTIONS_FILE='functions.sh'
curl -o functions.sh $FUNCTIONS_FILE_REPO

# --- Loading the functions in the current shell
source $FUNCTIONS_FILE


keptnInstallClient

rm $FUNCTIONS_FILE