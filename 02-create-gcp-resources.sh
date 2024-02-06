

. ./00-variables.sh

if gcloud builds connections list --region us-central1 --filter="name: $GITHUB_CONNECTION_NAME" | grep 'INSTALLATION_STATE: COMPLETE'
then
    echo "github connection to gcve bootcamp detected"
else
    echo "github connection not detected or not finalized , exiting"
   # exit 1
fi

## Create of the network resources 

gcloud compute networks create $GCVE_NETWORK_NAME \
    --subnet-mode=custom 


gcloud compute networks subnets create usc1-subnet \
    --network=$GCVE_NETWORK_NAME \
    --range="10.128.5.0/25" \
    --region=us-central1

gcloud compute networks subnets create usw2-subnet \
    --network=$GCVE_NETWORK_NAME \
    --range="10.128.5.128/25" \
    --region=us-west2

gcloud compute addresses create google-managed-services-$GCVE_NETWORK_NAME \
    --global \
    --purpose=VPC_PEERING \
    --addresses=192.168.0.0 \
    --prefix-length=16 \
    --description="PSA for $GCVE_NETWORK_NAME" \
    --network=$GCVE_NETWORK_NAME

gcloud services vpc-peerings connect \
    --service=servicenetworking.googleapis.com \
    --ranges=google-managed-services-$GCVE_NETWORK_NAME \
    --network=$GCVE_NETWORK_NAME \
    --project=$(gcloud config get-value project)

gcloud compute firewall-rules create $GCVE_NETWORK_NAME-allow-ingress-from-iap \
  --network=$GCVE_NETWORK_NAME \
  --direction=INGRESS \
  --action=allow \
  --rules=tcp:22,tcp:3389 \
  --source-ranges=35.235.240.0/20

gcloud compute firewall-rules create $GCVE_NETWORK_NAME-allow-internal \
--action=allow \
--network=$GCVE_NETWORK_NAME \
--description="Allow internal traffic" \
--rules=all \
--source-ranges="10.0.0.0/8" \
--direction=INGRESS

gcloud compute firewall-rules create $GCVE_NETWORK_NAME-allow-egress \
--action=allow \
--rules=all \
--destination-ranges=0.0.0.0/0 \
--network=$GCVE_NETWORK_NAME \
--description="Allow egress" \
--direction=EGRESS

gcloud compute routers create $GCVE_NETWORK_NAME-router \
    --network=$GCVE_NETWORK_NAME \
    --region=us-central1 

gcloud compute routers nats create $GCVE_NETWORK_NAME-nat \
    --router=$GCVE_NETWORK_NAME-router \
    --nat-all-subnet-ip-ranges \
    --region=us-central1 \
    --auto-allocate-nat-external-ips

## Create of the cloud build related resources 


   gcloud builds repositories create bootcamp-gcve \
     --remote-uri=https://github.com/dgourillon/bootcamp-gcve.git \
     --connection=$GITHUB_CONNECTION_NAME --region=us-central1 

cat > ./private_pool_config.yaml <<EOF
privatePoolV1Config:
  networkConfig:
    peeredNetwork: 'projects/$PROJECT_ID/global/networks/$GCVE_NETWORK_NAME'
  workerConfig:
    diskSizeGb: '100'
    machineType: 'e2-medium'
EOF

gcloud builds worker-pools create gcve-pool \
--config-from-file private_pool_config.yaml \
--region us-central1

rm private_pool_config.yaml

## Create of the IAM and service account resources

gcloud iam service-accounts create gcve-bootcamp-sa \
    --description="gcve bootcamp build SA " \
    --display-name="gcve-bootcamp-sa"

gcloud iam service-accounts add-iam-policy-binding gcve-bootcamp-sa@$PROJECT_ID.iam.gserviceaccount.com \
--member="serviceAccount:$CLOUD_BUILD_SA" \
--role='roles/iam.serviceAccountUser'

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:gcve-bootcamp-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/viewer"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:gcve-bootcamp-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/vmwareengine.vmwareengineAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:gcve-bootcamp-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.objectUser"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:gcve-bootcamp-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/logging.logWriter"

# Create of the vmware engine components

gcloud vmware networks create global-ven --type STANDARD --project=$PROJECT_ID --location=global


 gcloud vmware private-clouds create $PC1_NAME \
    --location=$PC1_LOCATION-a \
    --project=$PROJECT_ID \
    --type=TIME_LIMITED \
    --cluster=my-management-cluster \
    --node-type-config=type=standard-72,count=1 \
    --management-range=$PC1_ADMIN_RANGE \
    --vmware-engine-network=$VEN_NAME

 gcloud vmware private-clouds create $PC2_NAME \
    --location=$PC2_LOCATION-a \
    --project=$PROJECT_ID \
    --type=TIME_LIMITED \
    --cluster=my-management-cluster \
    --node-type-config=type=standard-72,count=1 \
    --management-range=$PC2_ADMIN_RANGE \
    --vmware-engine-network=$VEN_NAME

# Create of the cloud build triggers for the VSphere and NSXT steps




gcloud beta builds triggers create github --name="build-vsphere-and-nsx-resources" \
--region=us-central1 \
--service-account="projects/$PROJECT_ID/serviceAccounts/gcve-bootcamp-sa@$PROJECT_ID.iam.gserviceaccount.com" \
--repository="projects/$PROJECT_ID/locations/us-central1/connections/gcve-github-connection/repositories/bootcamp-gcve" \
--branch-pattern="^build_branch.*" \
--build-config="cloudbuild-pc1-apply.yaml" \
--substitutions="_PC1_NAME=$PC1_NAME,_PC1_LOCATION=$PC1_LOCATION,_PC2_NAME=$PC2_NAME,_PC2_LOCATION=$PC2_LOCATION"


gcloud beta builds triggers create github --name="build-vms" \
--region=us-central1 \
--service-account="projects/$PROJECT_ID/serviceAccounts/gcve-bootcamp-sa@$PROJECT_ID.iam.gserviceaccount.com" \
--repository="projects/$PROJECT_ID/locations/us-central1/connections/gcve-github-connection/repositories/bootcamp-gcve" \
--branch-pattern="^build_branch.*" \
--build-config="cloudbuild-pc1-vms.yaml" \
--substitutions="_PC1_NAME=$PC1_NAME,_PC1_LOCATION=$PC1_LOCATION,_PC2_NAME=$PC2_NAME,_PC2_LOCATION=$PC2_LOCATION"



# Create of the storage bucket for the tfstates

gsutil mb gs://$PROJECT_NUMBER-gcve-bootcamp

# Create bastions

for i in $(seq 1 $BASTION_COUNT); do

    gcloud compute instances create bastion-${i} \
    --zone=us-central1-a \
    --machine-type=e2-medium \
    --image-family=windows-2022 \
    --image-project=windows-cloud \
    --boot-disk-size=50GB \
    --boot-disk-type=pd-standard \
    --provisioning-model=SPOT \
    --instance-termination-action=STOP \
    --maintenance-policy=TERMINATE \
    --boot-disk-device-name=bastion-${i} \
    --metadata=enable-oslogin=TRUE \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --reservation-affinity=any \
    --network-interface=stack-type=IPV4_ONLY,subnet=usc1-subnet,no-address \
    
done

