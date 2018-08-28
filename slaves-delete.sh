#!/bin/bash

working_dir=`pwd`

tenant=`awk '{print $NF}' $working_dir/tenant_export`
#tenant=`awk '{print $NF}' tenant_export`

credentials=`cat credentials.csv`

for i in $credentials
do
        clusterName=`echo $i | cut -d ',' -f1`
        zoneName=`echo $i | cut -d ',' -f2`
        gcloud container clusters get-credentials $clusterName --zone $zoneName --project etsyperftesting-208619
        kubectl delete ns $tenant
done
 
clusterName=`gcloud container clusters list | grep master | awk '{ print $1 }'`
zoneName=`gcloud container clusters list | grep master | awk '{ print $2 }'`
gcloud container clusters get-credentials $clusterName --zone $zoneName --project etsyperftesting-208619
kubectl get po -n $tenant -o wide |  grep "jmeter-master" | awk '{ print $1 }'>$clusterName.csv
