#!/bin/bash

PRIVATE_CLOUD="pc-2"
ZONE="us-west2-a"
PROJECT="gcve-dgo"

CREDENTIALS_TFVARS="gcve.credentials.auto.tfvars"
VM_CREATE_SCRIPT="create_vms.sh"

VCENTER_IP=$(gcloud vmware private-clouds list --location=$ZONE --format="value(vcenter.internalIp)" --filter="name=projects/$PROJECT/locations/$ZONE/privateClouds/$PRIVATE_CLOUD" --project $PROJECT ) 
VCENTER_URL=$(gcloud vmware private-clouds list --location=$ZONE --format="value(vcenter.fqdn)" --filter="name=projects/$PROJECT/locations/$ZONE/privateClouds/$PRIVATE_CLOUD" --project $PROJECT ) 
VCENTER_USER=$(gcloud vmware private-clouds vcenter credentials describe --private-cloud=$PRIVATE_CLOUD --location=$ZONE --project $PROJECT --format="value(username)")
VCENTER_PWD=$(gcloud vmware private-clouds vcenter credentials describe --private-cloud=$PRIVATE_CLOUD --location=$ZONE --project $PROJECT --format="value(password)")

export GOVC_URL=https://172.16.10.2/sdk
export GOVC_USERNAME=administrator@psolab.local
export GOVC_PASSWORD=ps0Lab\!admin


NSX_IP=$(gcloud vmware private-clouds list --location=$ZONE --format="value(nsx.internalIp)" --filter="name=projects/$PROJECT/locations/$ZONE/privateClouds/$PRIVATE_CLOUD" --project $PROJECT )
NSX_URL=$(gcloud vmware private-clouds list --location=$ZONE --format="value(nsx.fqdn)" --filter="name=projects/$PROJECT/locations/$ZONE/privateClouds/$PRIVATE_CLOUD" --project $PROJECT )
NSX_USER=$(gcloud vmware private-clouds nsx credentials describe --private-cloud=$PRIVATE_CLOUD --location=$ZONE --project $PROJECT --format="value(username)")
NSX_PWD=$(gcloud vmware private-clouds nsx credentials describe --private-cloud=$PRIVATE_CLOUD --location=$ZONE --project $PROJECT --format="value(password)")

sed -i  "s/secret_vsphere_server.*/secret_vsphere_server   = \"$VCENTER_URL\"/g" $CREDENTIALS_TFVARS 
sed -i "s/secret_vsphere_user.*/secret_vsphere_user     = \"$VCENTER_USER\"/g" $CREDENTIALS_TFVARS
sed -i "s/secret_vsphere_password.*/secret_vsphere_password = \"$VCENTER_PWD\"/g" $CREDENTIALS_TFVARS
sed -i "s/vcenter_ip_address.*/vcenter_ip_address     = \"$VCENTER_IP\"/g" $CREDENTIALS_TFVARS
sed -i "s/nsx_manager_ip_address.*/nsx_manager_ip_address = \"$NSX_IP\"/g" $CREDENTIALS_TFVARS


sed -i "s/nsxt_password.*/nsxt_password = \"$NSX_PWD\"/g" $CREDENTIALS_TFVARS
sed -i "s/nsxt_url.*/nsxt_url = \"$NSX_URL\"/g" $CREDENTIALS_TFVARS


sed -i  "s/GOVC_URL.*/GOVC_URL=https:\/\/$VCENTER_URL\/sdk/g" $VM_CREATE_SCRIPT 
sed -i  "s/GOVC_USERNAME.*/GOVC_USERNAME=$VCENTER_USER/g" $VM_CREATE_SCRIPT
sed -i "s/GOVC_PASSWORD.*/GOVC_PASSWORD=$VCENTER_PWD/g" $VM_CREATE_SCRIPT

terraform init
