


. ./00-variables.sh

echo gcloud vmware private-clouds delete $PC2_NAME --project=$PROJECT_ID --location=global
gcloud vmware private-clouds delete $PC1_NAME --project=$PROJECT_ID --location=global
gcloud vmware network-peerings delete peering-psa --project=$PROJECT_ID --location=global
gcloud vmware network-peerings delete peering-vpc --project=$PROJECT_ID --location=global
gcloud vmware networks delete $GCVE_NETWORK_NAME --project=$PROJECT_ID --location=global
