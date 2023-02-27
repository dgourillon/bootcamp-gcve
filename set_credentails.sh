#!/bin/bash

PRIVATE_CLOUD="pc-1"
ZONE="us-central1-a"
PROJECT="gcve-dgo"

GCVE_CREDS=$(gcloud vmware private-clouds vcenter credentials describe --private-cloud=$PRIVATE_CLOUD --location=$ZONE --project $PROJECT)


VCENTER_IP=$(gcloud vmware private-clouds list --location=$ZONE --format="value(vcenter.internalIp)" --filter="name=projects/$PROJECT/locations/$ZONE/privateClouds/$PRIVATE_CLOUD" --project $PROJECT ) 
VCENTER_URL=$(gcloud vmware private-clouds list --location=$ZONE --format="value(vcenter.fqdn)" --filter="name=projects/$PROJECT/locations/$ZONE/privateClouds/$PRIVATE_CLOUD" --project $PROJECT ) 
NSX_IP=$(gcloud vmware private-clouds list --location=$ZONE --format="value(nsx.internalIp)" --filter="name=projects/$PROJECT/locations/$ZONE/privateClouds/$PRIVATE_CLOUD" --project $PROJECT )
VCENTER_USER=$(gcloud vmware private-clouds vcenter credentials describe --private-cloud=$PRIVATE_CLOUD --location=$ZONE --project $PROJECT --format="value(username)")
VCENTER_PWD=$(gcloud vmware private-clouds vcenter credentials describe --private-cloud=$PRIVATE_CLOUD --location=$ZONE --project $PROJECT --format="value(password)")


echo $VCENTER_USER $VCENTER_PWD $VCENTER_URL

sed -i  "s/secret_vsphere_server.*/secret_vsphere_server   = \"$VCENTER_URL\"/g" terraform.tfvars 
sed -i "s/secret_vsphere_user.*/secret_vsphere_user     = \"$VCENTER_USER\"/g" terraform.tfvars
sed -i "s/secret_vsphere_password.*/secret_vsphere_password = \"$VCENTER_PWD\"/g" terraform.tfvars
sed -i "s/vcenter_ip_address.*/vcenter_ip_address     = \"$VCENTER_IP\"/g" terraform.tfvars
sed -i "s/nsx_manager_ip_address.*/nsx_manager_ip_address = \"$NSX_IP\"/g" terraform.tfvars
