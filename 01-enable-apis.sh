

# base setup API 

./00-variables.sh

gcloud services enable artifactregistry.googleapis.com \
    autoscaling.googleapis.com \
    backupdr.googleapis.com \
    bigquery.googleapis.com \
    bigquerymigration.googleapis.com \
    bigquerystorage.googleapis.com \
    certificatemanager.googleapis.com\
    cloudaicompanion.googleapis.com \
    cloudapis.googleapis.com \
    cloudasset.googleapis.com \
    cloudbuild.googleapis.com \
    cloudkms.googleapis.com \
    cloudresourcemanager.googleapis.com \
    cloudscheduler.googleapis.com \
    cloudtrace.googleapis.com \
    compute.googleapis.com \
    container.googleapis.com \
    containerfilesystem.googleapis.com \
    containerregistry.googleapis.com \
    dns.googleapis.com 


gcloud services enable fcm.googleapis.com \
    file.googleapis.com \
    iam.googleapis.com \
    iamcredentials.googleapis.com \
    iap.googleapis.com \
    logging.googleapis.com \
    migrationcenter.googleapis.com \
    monitoring.googleapis.com \
    networkconnectivity.googleapis.com \
    oslogin.googleapis.com \
    pubsub.googleapis.com \
    rapidmigrationassessment.googleapis.com \
    runtimeconfig.googleapis.com \
    secretmanager.googleapis.com \
    securetoken.googleapis.com \
    servicecontrol.googleapis.com \
    servicemanagement.googleapis.com \
    servicenetworking.googleapis.com \
    serviceusage.googleapis.com \
    storage-api.googleapis.com 
    

gcloud services enable   vmmigration.googleapis.com \
    storage.googleapis.com \
    vmwareengine.googleapis.com \
    workflowexecutions.googleapis.com \
    workflows.googleapis.com


PROJECT_ID=$(gcloud config get-value project)

PN=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")
CLOUD_BUILD_SERVICE_AGENT="service-${PN}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${CLOUD_BUILD_SERVICE_AGENT}" \
  --role="roles/secretmanager.admin"

gcloud builds connections create github gcve-github-connection --region=us-central1

