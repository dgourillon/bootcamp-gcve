
export VEN_NAME=global-ven
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects list --filter="$PROJECT_ID" --format="value(PROJECT_NUMBER)")
export GCVE_NETWORK_NAME=gcve-network
CLOUD_BUILD_SA="$PROJECT_NUMBER@cloudbuild.gserviceaccount.com"

export PC1_NAME=pc-1
export PC1_LOCATION=us-west2
export PC1_ADMIN_RANGE="10.170.0.0/20"
export PC2_NAME=pc-2
export PC2_LOCATION=us-west2
export PC2_ADMIN_RANGE="10.170.16.0/20"


export GITHUB_CONNECTION_NAME=gcve-github-connection


export BASTION_COUNT=2