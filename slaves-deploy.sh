#!/bin/bash

working_dir=`pwd`

tenant=`awk '{print $NF}' $working_dir/tenant_export`
#tenant=`awk '{print $NF}' tenant_export`

rm -rf credentials.csv
rm -rf trial-*.csv

status=true

echo " Available cluster under this Project "

echo 
gcloud container clusters list

while $status; do

read -p "Enter the ClusterName : " clusterName
read -p "Enter the ZoneName : " zoneName
echo $clusterName,$zoneName>>credentials.csv

read -p "Do you want to enter another Cluster Details [y/n] : " clusterDetails
if [ $clusterDetails ];then
        if [ $clusterDetails == 'y' ]; then
           status=true;
        elif [ $clusterDetails == 'n' ]; then
           status=false;
        else
           echo  "Enter a valid response y or n ";
           status=true;
        fi
else
   echo  "Enter a valid response y or n ";
   status=true;
fi

done

credentials=`cat credentials.csv`

for i in $credentials
do
        clusterName=`echo $i | cut -d ',' -f1`
        zoneName=`echo $i | cut -d ',' -f2`
        gcloud container clusters get-credentials $clusterName --zone $zoneName --project etsyperftesting-208619
        kubectl create ns $tenant
        kubectl create -n $tenant -f jmeter_slaves_deploy.yaml
	sleep 15
	kubectl get po -n $tenant -o wide
        kubectl get po -n $tenant -o wide |  grep "slaves" | awk '{ print $1":"$6 }'> $clusterName.csv
done

clusterName=`gcloud container clusters list | grep master | awk '{ print $1 }'`
zoneName=`gcloud container clusters list | grep master | awk '{ print $2 }'`
gcloud container clusters get-credentials $clusterName --zone $zoneName --project etsyperftesting-208619
kubectl get po -n $tenant -o wide |  grep "jmeter-master" | awk '{ print $1 }'>$clusterName.csv


