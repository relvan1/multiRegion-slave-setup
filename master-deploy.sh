#!/bin/bash

working_dir=`pwd`

tenant=`awk '{print $NF}' $working_dir/tenant_export`
#tenant=`awk '{print $NF}' tenant_export`

echo "Creating Jmeter Master"

kubectl apply -n $tenant -f $working_dir/jmeter_master_configmap.yaml

kubectl apply -n $tenant -f $working_dir/jmeter_master_deploy.yaml

sleep 15

kubectl get po -n $tenant -o wide | grep jmeter-master

master_pod=`kubectl get po -n $tenant | grep jmeter-master | awk '{print $1}'`

for i in $master_pod
do

kubectl exec -ti -n $tenant $i -- cp  /load_test  /jmeter/load_test

kubectl exec -ti -n $tenant $i -- chmod 755 /jmeter/load_test

done

