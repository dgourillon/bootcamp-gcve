
BUILD_PC_2=false

if gcloud vmware private-clouds list --location us-central1-a | grep pc-1
then
   echo "pc-1 found, skip the build" 

else
    echo "pc-1 not found, trigger a build"
    gcloud vmware private-clouds create pc-1 \
    --location=us-central1-a \
    --project=gcve-dgo \
    --type=TIME_LIMITED \
    --cluster=nprd-ll01 \
    --node-type-config=type=standard-72,count=1 \
    --management-range=10.170.0.0/20 \
    --vmware-engine-network=us-central1-default
    gsutil rm gs://tfstate-gcve-bootcamp/pc1/*
fi

if gcloud vmware private-clouds list --location us-west2-a | grep pc-2
then
   echo "pc-2 found, skip the build" 

else
    if $BUILD_PC_2
    then
        gcloud vmware private-clouds create pc-2 \
        --location=us-west2-a \
        --project=gcve-dgo \
        --type=TIME_LIMITED \
        --cluster=my-management-cluster \
        --node-type-config=type=standard-72,count=1 \
        --management-range=10.170.16.0/20 \
        --vmware-engine-network=us-west2-default
        gsutil rm gs://tfstate-gcve-bootcamp/pc2/*
    fi
fi

until gcloud vmware private-clouds list --location us-central1-a --format="value(vcenter.state)" --filter="name:pc-1" | grep -i "active" 
do 
    echo "waiting for the PC pc1 to finish building"
    sleep 300
done

until gcloud vmware private-clouds list --location us-west2-a --format="value(vcenter.state)" --filter="name:pc-2" | grep -i "active" 
do 
    echo "waiting for the PC pc2 to finish building"
    sleep 300
done