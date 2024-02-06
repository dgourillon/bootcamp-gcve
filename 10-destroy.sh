


. ./00-variables.sh

PC1_DOMAIN=$(gcloud vmware private-clouds describe $PC1_NAME --location=$PC1_LOCATION-a --format="value(vcenter.fqdn)" | cut -d '.' -f 2-4)
PC2_DOMAIN=$(gcloud vmware private-clouds describe $PC2_NAME --location=$PC2_LOCATION-a --format="value(vcenter.fqdn)" | cut -d '.' -f 2-4)

echo gcloud vmware private-clouds delete $PC2_NAME --project=$PROJECT_ID --location=$PC2_LOCATION-a
gcloud vmware private-clouds delete $PC1_NAME --project=$PROJECT_ID --location=$PC1_LOCATION-a
gcloud vmware network-peerings delete peering-psa --project=$PROJECT_ID 
gcloud vmware network-peerings delete peering-vpc --project=$PROJECT_ID 
gcloud vmware networks delete $GCVE_NETWORK_NAME --project=$PROJECT_ID 



gcloud dns --project=$PROJECT_ID managed-zones delete $(echo $PC1_DOMAIN | tr '.' '-') 
gcloud dns --project=$PROJECT_ID managed-zones delete $(echo $PC2_DOMAIN | tr '.' '-') 

gcloud services peered-dns-domains delete gcve-peering --network=$GCVE_NETWORK_NAME  

## remove gcp resources


for i in $(seq 1 $BASTION_COUNT); do

    gcloud -q compute instances delete bastion-${i} \
    --zone=us-central1-a \
   
done
gsutil -m rm -r gs://$PROJECT_NUMBER-gcve-bootcamp/*
gsutil rb gs://$PROJECT_NUMBER-gcve-bootcamp

gcloud beta builds triggers delete  build-vsphere-and-nsx-resources \
--region=us-central1 
gcloud beta builds triggers delete  build-vms \
--region=us-central1 


gcloud -q compute routers nats delete $GCVE_NETWORK_NAME-nat \
   --region=us-central1 \
   --router=$GCVE_NETWORK_NAME-router

gcloud -q compute routers delete $GCVE_NETWORK_NAME-router \
    --region=us-central1 

gcloud vmware networks delete global-ven --type STANDARD --project=$PROJECT_ID --location=global


gcloud iam service-accounts remove-iam-policy-binding gcve-bootcamp-sa@$PROJECT_ID.iam.gserviceaccount.com \
--member="serviceAccount:$CLOUD_BUILD_SA" \
--role='roles/iam.serviceAccountUser'

gcloud projects remove-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:gcve-bootcamp-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/viewer"

gcloud projects remove-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:gcve-bootcamp-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/vmwareengine.vmwareengineAdmin"

gcloud projects remove-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:gcve-bootcamp-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.objectUser"

gcloud projects remove-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:gcve-bootcamp-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/logging.logWriter"

gcloud -q iam service-accounts delete gcve-bootcamp-sa@$PROJECT_ID.iam.gserviceaccount.com

gcloud builds worker-pools delete gcve-pool \
--region us-central1


gcloud services vpc-peerings delete \
    --service=servicenetworking.googleapis.com \
    --network=$GCVE_NETWORK_NAME \
    --project=$(gcloud config get-value project)

gcloud -q compute addresses delete google-managed-services-$GCVE_NETWORK_NAME \
    --global  
  
gcloud -q compute networks subnets delete usc1-subnet \
    --region=us-central1

gcloud -q compute networks subnets delete usw2-subnet \
    --region=us-west2



gcloud -q compute firewall-rules delete $GCVE_NETWORK_NAME-allow-ingress-from-iap
gcloud -q compute firewall-rules delete $GCVE_NETWORK_NAME-allow-internal
gcloud -q compute firewall-rules delete $GCVE_NETWORK_NAME-allow-egress 
 
gcloud -q compute networks delete $GCVE_NETWORK_NAME





