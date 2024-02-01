



GCVE_NETWORK_NAME=gcve-network
GITHUB_CONNECTION_NAME=gcve-github-connection
PROJECT_ID=$(gcloud config get-value project)
PROJECT_NUMBER=$(gcloud projects list --filter="$PROJECT_ID" --format="value(PROJECT_NUMBER)")
CLOUD_BUILD_SA="$PROJECT_NUMBER@cloudbuild.gserviceaccount.com"

if gcloud builds connections list --region us-central1 | grep $GITHUB_CONNECTION_NAME
then
    echo "github connection to gcve bootcamp detected"
else
    echo "github connection bot detected, exiting"
    exit 1
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

gcloud compute firewall-rules create allow-iap-ingress --allow=tcp:22,3389 \
--network=$GCVE_NETWORK_NAME \
--description="Allow incoming traffic on TCP 3389 aznd 22 for IAP" \
--source-ranges="130.211.0.0/22,35.191.0.0/16" \
--direction=INGRESS

gcloud compute firewall-rules create allow-internal --allow=tcp \
--network=$GCVE_NETWORK_NAME \
--description="Allow internal traffic" \
--source-ranges="10.0.0.0/8" \
--direction=INGRESS

gcloud compute firewall-rules create allow-egress --allow=tcp \
--network=$GCVE_NETWORK_NAME \
--description="Allow egress" \
--direction=EGRESS


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


gcloud vmware networks create global-ven --type STANDARD --project=$PROJECT_ID --location=global



gcloud beta builds triggers create github --name="build-pcs" \
--region=us-central1 \
--service-account="projects/$PROJECT_ID/serviceAccounts/gcve-bootcamp-sa@$PROJECT_ID.iam.gserviceaccount.com" \
--repository="projects/$PROJECT_ID/locations/us-central1/connections/gcve-github-connection/repositories/bootcamp-gcve" \
--branch-pattern="^build_branch.*" \
--build-config="cloudbuild.yaml"



gcloud beta builds triggers create github --name="build-pcs" \
--region=us-central1 \
--service-account="projects/$PROJECT_ID/serviceAccounts/gcve-bootcamp-sa@$PROJECT_ID.iam.gserviceaccount.com" \
--repository="projects/$PROJECT_ID/locations/us-central1/connections/gcve-github-connection/repositories/bootcamp-gcve" \
--branch-pattern="^build_branch.*" \
--build-config="cloudbuild.yaml"



gcloud beta builds triggers create github --name="build-vsphere-and-nsx-resources" \
--region=us-central1 \
--service-account="projects/$PROJECT_ID/serviceAccounts/gcve-bootcamp-sa@$PROJECT_ID.iam.gserviceaccount.com" \
--repository="projects/$PROJECT_ID/locations/us-central1/connections/gcve-github-connection/repositories/bootcamp-gcve" \
--branch-pattern="^build_branch.*" \
--build-config="cloudbuild-pc1-apply.yaml"


gsutil mb gs://$PROJECT_NUMBER-gcve-bootcamp