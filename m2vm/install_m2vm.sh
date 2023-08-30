
install_m2vm () {
   echo "This is the first function speaking..."
   PRIVATE_CLOUD=$1
   ZONE=$2
   PROJECT=$3
   VCENTER_IP=$(gcloud vmware private-clouds list --location=$ZONE --format="value(vcenter.internalIp)" --filter="name=projects/$PROJECT/locations/$ZONE/privateClouds/$PRIVATE_CLOUD" --project $PROJECT ) 
   VCENTER_URL=$(gcloud vmware private-clouds list --location=$ZONE --format="value(vcenter.fqdn)" --filter="name=projects/$PROJECT/locations/$ZONE/privateClouds/$PRIVATE_CLOUD" --project $PROJECT ) 
   VCENTER_USER=$(gcloud vmware private-clouds vcenter credentials describe --private-cloud=$PRIVATE_CLOUD --location=$ZONE --project $PROJECT --format="value(username)")
   VCENTER_PWD=$(gcloud vmware private-clouds vcenter credentials describe --private-cloud=$PRIVATE_CLOUD --location=$ZONE --project $PROJECT --format="value(password)")
   export GOVC_URL=https://$VCENTER_IP/sdk
   export GOVC_USERNAME='CloudOwner@gve.local'
   export GOVC_PASSWORD=$VCENTER_PWD
   export GOVC_INSECURE=true


## Download and create the M4C connector

# Download the connector
OVA_URL=$(curl https://cloud.google.com/migrate/virtual-machines/docs/5.0/how-to/migrate-connector | grep -Eo 'https://storage.googleapis.com/vmmigration-public-artifacts/[^ >]+' | grep ova | tr -d "\"")
wget $OVA_URL
OVA_NAME=$(ls migrate-connector-* | awk -F '.' '{print $1}')
# Fetch the public key value you generated

 PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub  | awk  '{print $1 " " $2}')

# generate JSON spec file to import the OVA
# In this case, we will use DHCP for the network configuration
# and the SSH key generated earlier to be able to connect to 
# the VM

cat >> $OVA_NAME.json <<EOF
{
    "DiskProvisioning": "thin",
    "IPAllocationPolicy": "dhcpPolicy",
    "IPProtocol": "IPv4",
    "InjectOvfEnv": false,
    "MarkAsTemplate": false,
    "Name": "$OVA_NAME",
    "NetworkMapping": [
        {
            "Name": "VM Network",
            "Network": "team0-frontend-segment"
        }
    ],
    "PowerOn": true,
    "PropertyMapping": [
        {
            "Key": "public-keys",
            "Value": "$PUBLIC_KEY"
        },
        {
            "Key": "hostname",
            "Value": "migrate-appliance"
        },
        {
            "Key": "ip0",
            "Value": "0.0.0.0"
        },
        {
            "Key": "netmask0",
            "Value": "0.0.0.0"
        },
        {
            "Key": "gateway",
            "Value": "0.0.0.0"
        },
        {
            "Key": "DNS",
            "Value": ""
        },
        {
            "Key": "proxy",
            "Value": ""
        },
        {
            "Key": "route0",
            "Value": ""
        }
    ],
    "WaitForIP": false
}


EOF


govc import.ova -ds /Datacenter/datastore/vsanDatastore -pool  --options=$OVA_NAME.json $OVA_NAME.ova

}


PRIVATE_CLOUD="pc-1"
ZONE="us-central1-a"
PROJECT="gcve-dgo"


install_m2vm "pc-1" "us-central1-a" "gcve-dgo"
install_m2vm "pc-2" "us-central1-a" "gcve-dgo"