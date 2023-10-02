
CREDENTIALS_TFVARS="gcve-pc1.credentials.auto.tfvars"
VM_CREATE_SCRIPT="create_vms_pc1.sh"

mv $CREDENTIALS_TFVARS /workspace/$CREDENTIALS_TFVARS
mv $VM_CREATE_SCRIPT /workspace/$VM_CREATE_SCRIPT

terraform init

terraform plan