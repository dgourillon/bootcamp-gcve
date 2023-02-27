#!/bin/bash


for CREDENTIALS_TFVARS in $(ls ./pc*/gcve.credentials.auto.tfvars)
do
pwd
echo sed -i  "s/secret_vsphere_server.*/secret_vsphere_server   = \"VCENTER_URL\"/g" $CREDENTIALS_TFVARS 
sed -i "s/secret_vsphere_user.*/secret_vsphere_user     = \"VCENTER_USER\"/g" $CREDENTIALS_TFVARS
sed -i "s/secret_vsphere_password.*/secret_vsphere_password = \"VCENTER_PWD\"/g" $CREDENTIALS_TFVARS
sed -i "s/vcenter_ip_address.*/vcenter_ip_address     = \"VCENTER_IP\"/g" $CREDENTIALS_TFVARS
sed -i "s/nsx_manager_ip_address.*/nsx_manager_ip_address = \"NSX_IP\"/g" $CREDENTIALS_TFVARS


sed -i "s/nsxt_password.*/nsxt_password = \"NSX_PWD\"/g" $CREDENTIALS_TFVARS
sed -i "s/nsxt_url.*/nsxt_url = \"NSX_URL\"/g" $CREDENTIALS_TFVARS


sed -i  "s/GOVC_URL.*/GOVC_URL=https:\/\/VCENTER_URL\/sdk/g" $VM_CREATE_SCRIPT 
sed -i  "s/GOVC_USERNAME.*/GOVC_USERNAME=VCENTER_USER/g" $VM_CREATE_SCRIPT
sed -i "s/GOVC_PASSWORD.*/GOVC_PASSWORD=VCENTER_PWD/g" $VM_CREATE_SCRIPT
done
