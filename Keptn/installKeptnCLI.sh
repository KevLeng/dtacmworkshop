#!/bin/bash

KEPTN_VERSION=0.6.2

wget -q -O keptn.tar "https://github.com/keptn/keptn/releases/download/${KEPTN_VERSION}/${KEPTN_VERSION}_keptn-linux.tar"
tar -xvf keptn.tar
chmod +x keptn
mv keptn /usr/local/bin/keptn

rm keptn.tar