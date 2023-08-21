gcloud vmware private-clouds create pc-1 \
--location=us-central1-a \
--project=gcve-dgo \
--type=TIME_LIMITED \
--cluster=my-management-cluster \
--node-type-config=type=standard-72,count=1 \
--management-range=10.168.20.0/24 \
--vmware-engine-network=us-central1-default

gcloud vmware private-clouds create pc-2 \
--location=us-west2-a \
--project=gcve-dgo \
--type=TIME_LIMITED \
--cluster=my-management-cluster \
--node-type-config=type=standard-72,count=1 \
--management-range=10.168.120.0/24 \
--vmware-engine-network=us-west2-default