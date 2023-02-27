## Set GOVC credentials
export GOVC_URL=https://vcsa-172030.ea3366ef.us-west2.gve.goog/sdk
export GOVC_USERNAME=CloudOwner@gve.local
export GOVC_PASSWORD=BD+cpJFxvo2UMOzk
export GOVC_INSECURE=true

OVF_bucket=psolab-ovas-dgo

## gsutil requires a project_id to be set (skip if you already have done it)
project_id_default=$(gcloud projects list | grep migrate | tail -1 | awk '{print $1}')
gcloud config set project $project_id_default 

for current_ovf in $(gsutil ls gs://$OVF_bucket/  | awk -F '/' '{print $4}' | grep ovf |  awk -F '.' '{print $1}')
do
    echo "creating $current_ovf VM"
    gsutil cp gs://$OVF_bucket/ gs://$OVF_bucket/$current_ovf* .
    govc import.ovf --options=$current_ovf.json $current_ovf.ovf
    rm $current_ovf*
done

