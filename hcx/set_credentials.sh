
PRIVATE_CLOUD="pc-1"
ZONE="us-central1-a"
PROJECT="gcve-dgo"

CREDENTIALS_TFVARS="gcve.credentials.auto.tfvars"
VM_CREATE_SCRIPT="create_vms.sh"

VCENTER_IP=$(gcloud vmware private-clouds list --location=$ZONE --format="value(vcenter.internalIp)" --filter="name=projects/$PROJECT/locations/$ZONE/privateClouds/$PRIVATE_CLOUD" --project $PROJECT ) 
VCENTER_URL=$(gcloud vmware private-clouds list --location=$ZONE --format="value(vcenter.fqdn)" --filter="name=projects/$PROJECT/locations/$ZONE/privateClouds/$PRIVATE_CLOUD" --project $PROJECT ) 
VCENTER_USER=$(gcloud vmware private-clouds vcenter credentials describe --private-cloud=$PRIVATE_CLOUD --location=$ZONE --project $PROJECT --format="value(username)")
VCENTER_PWD=$(gcloud vmware private-clouds vcenter credentials describe --private-cloud=$PRIVATE_CLOUD --location=$ZONE --project $PROJECT --format="value(password)")

HCX_URL=$(gcloud vmware private-clouds list --location=$ZONE --format="value(hcx.fqdn)" --filter="name=projects/$PROJECT/locations/$ZONE/privateClouds/$PRIVATE_CLOUD" --project $PROJECT )

sed -i  "s/VCENTER_URL/$VCENTER_URL/g" hcx.ps1
sed -i  "s/VCENTER_PWD/$VCENTER_PWD/g" hcx.ps1