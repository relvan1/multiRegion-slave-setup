#!/usr/bin/env bash
#Create multiple Jmeter namespaces on an existing kuberntes cluster
#Started On January 23, 2018

working_dir=`pwd`

echo "Checking if kubectl is present"

if ! hash kubectl 2>/dev/null
then
    echo "'kubectl' was not found in PATH"
    echo "Kindly ensure that you can acces an existing kubernetes cluster via kubectl"
    exit
fi

kubectl version --short

echo "Current list of namespaces on the kubernetes cluster:"

echo

kubectl get namespaces | grep -v NAME | awk '{print $1}'

echo

echo "Enter the name of the new tenant unique name, this will be used to create the namespace"
read tenant
echo

#Check If namespace exists

kubectl get namespace $tenant > /dev/null 2>&1

if [ $? -eq 0 ]
then
  echo "Namespace $tenant already exists, please select a unique name"
  echo "Current list of namespaces on the kubernetes cluster"
  sleep 2

 kubectl get namespaces | grep -v NAME | awk '{print $1}'
  exit 1
fi

echo
echo "Creating Namespace: $tenant"

kubectl create namespace $tenant

echo "Namspace $tenant has been created"

echo


nodes=`kubectl get no | wc -l`

echo

echo "Number of nodes on this cluster is " $nodes

echo "Creating Influxdb and the service"

kubectl create -n $tenant -f $working_dir/jmeter_influxdb_configmap.yaml

kubectl create -n $tenant -f $working_dir/jmeter_influxdb_deploy.yaml

kubectl create -n $tenant -f $working_dir/jmeter_influxdb_svc.yaml

echo "Creating Grafana Deployment"

kubectl create -n $tenant -f $working_dir/jmeter_grafana_deploy.yaml

kubectl create -n $tenant -f $working_dir/jmeter_grafana_svc.yaml

echo namespace = $tenant > $working_dir/tenant_export

sleep 15

## Create jmeter database automatically in Influxdb

echo "Creating Influxdb jmeter Database"

##Wait until Influxdb Deployment is up and running
##influxdb_status=`kubectl get po -n $tenant | grep influxdb-jmeter | awk '{print $2}' | grep Running

influxdb_pod=`kubectl get po -n $tenant | grep influxdb-jmeter | awk '{print $1}'`
kubectl exec -ti -n $tenant $influxdb_pod -- influx -execute 'CREATE DATABASE jmeter'

## Create the influxdb datasource in Grafana

echo "Creating the Influxdb data source"
grafana_pod=`kubectl get po -n $tenant | grep jmeter-grafana | awk '{print $1}'`

## Make load test script in Jmeter master pod executable

#Get Master pod details

##kubectl cp $working_dir/influxdb-jmeter-datasource.json -n $tenant $grafana_pod:/influxdb-jmeter-datasource.json

kubectl exec -ti -n $tenant $grafana_pod -- curl 'http://admin:admin@127.0.0.1:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"jmeterdb","type":"influxdb","url":"http://jmeter-influxdb:8086","access":"proxy","isDefault":true,"database":"jmeter","user":"admin","password":"admin"}'
