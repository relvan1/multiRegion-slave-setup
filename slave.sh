#!/bin/bash
gcloud container clusters get-credentials $1 --zone $2 --project etsyperftesting-208619
kubectl exec -ti -n $3 $4 -- mkdir -p /jmeter/apache-jmeter-4.0/bin/csv/
kubectl cp $5 -n $3 $4:/jmeter/apache-jmeter-4.0/bin/csv/$5
kubectl exec -it -n $3 $4 -- bash -c "echo 35.227.203.198 www.etsy.com etsy.com openapi.etsy.com api.etsy.com >> /etc/hosts"
