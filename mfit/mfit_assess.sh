#!/bin/bash

PRIVATE_CLOUD="pc-1"
ZONE="us-central1-a"
PROJECT="gcve-dgo"

curl -O "https://mcdc-release.storage.googleapis.com/$(curl -s https://mcdc-release.storage.googleapis.com/latest)/mcdc"
chmod +x mcdc
curl -O "https://mcdc-release.storage.googleapis.com/$(curl -s https://mcdc-release.storage.googleapis.com/latest)/mcdc-linux-collect.sh"
chmod +x mcdc-linux-collect.sh

echo "purge db" | ./mcdc discover purge-db
TEAM_COUNT=5

sudo setcap cap_net_raw+ep ./mcdc

export GOVC_URL=$(gcloud vmware private-clouds list --location=$ZONE --format="value(vcenter.fqdn)" --filter="name=projects/$PROJECT/locations/$ZONE/privateClouds/$PRIVATE_CLOUD" --project $PROJECT ) 
export GOVC_USERNAME=$(gcloud vmware private-clouds vcenter credentials describe --private-cloud=$PRIVATE_CLOUD --location=$ZONE --project $PROJECT --format="value(username)")
export GOVC_PASSWORD=$(gcloud vmware private-clouds vcenter credentials describe --private-cloud=$PRIVATE_CLOUD --location=$ZONE --project $PROJECT --format="value(password)")
IP_FILE="ipscan.csv"
echo "ipAddress" > $IP_FILE
for VM in $(govc ls /Datacenter/vm/team* | grep centos) 
do 
    govc vm.ip $VM >> $IP_FILE
done

echo '[{"username":"root","password":"ps0lab!"}]' > credentials.json
cat credentials.json | ./mcdc discover ips --file $IP_FILE --accept-terms

./mcdc report --format html --file mcdc_result.html

./mcdc report --format html --full --file mcdc_result_full.html