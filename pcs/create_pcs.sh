PROJECT=$1
PC1_NAME=$2
PC1_LOCATION=$3
PC1_ADMIN_RANGE=$4
PC2_NAME=$5
PC2_LOCATION=$6
PC2_ADMIN_RANGE=$7
BUILD_PC_2=true

if gcloud vmware private-clouds list --location $PC1_LOCATION-a --project=$PROJECT | grep $PC1_NAME
then
   echo "$PC1_NAME found, skip the build" 

else
    echo "$PC1_NAME not found, trigger a build"
    gcloud vmware private-clouds create $PC1_NAME \
    --location=$PC1_LOCATION-a \
    --project=$PROJECT \
    --type=TIME_LIMITED \
    --cluster=my-management-cluster \
    --node-type-config=type=standard-72,count=1 \
    --management-range=$PC1_ADMIN_RANGE \
    --vmware-engine-network=$PC1_LOCATION-default
    gsutil rm gs://tfstate-gcve-bootcamp/pc1/*
fi

if gcloud vmware private-clouds list --location $PC2_LOCATION-a --project=$PROJECT | grep $PC2_NAME
then
   echo "$PC2_NAME found, skip the build" 

else
    if $BUILD_PC_2
    then
        gcloud vmware private-clouds create $PC2_NAME \
        --location=$PC2_LOCATION-a \
        --project=$PROJECT \
        --type=TIME_LIMITED \
        --cluster=my-management-cluster \
        --node-type-config=type=standard-72,count=1 \
        --management-range=10.170.16.0/20 \
        --vmware-engine-network=$PC2_LOCATION-default
        gsutil rm gs://tfstate-gcve-bootcamp/pc2/*
    fi
fi

until gcloud vmware private-clouds list --location $PC1_LOCATION-a --format="value(vcenter.state)" --filter="name:$PC1_NAME" --project=$PROJECT | grep -i "active" 
do 
    echo "waiting for the PC pc1 to finish building"
    sleep 300
done

until gcloud vmware private-clouds list --location $PC2_LOCATION-a --format="value(vcenter.state)" --filter="name:$PC2_NAME" --project=$PROJECT | grep -i "active" 
do 
    echo "waiting for the PC pc2 to finish building"
    sleep 300
done