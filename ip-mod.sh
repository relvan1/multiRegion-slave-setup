#!/bin/bash

working_dir=`pwd`

#Get namesapce variable
tenant=`awk '{print $NF}' $working_dir/tenant_export`

#status=true;

rm -rf mapper.csv
rm -rf info.csv

validateFile () {

	if [ -f $1 ];then
		return 0
	else
		echo "file not exists";
		exit 1
	fi
}

files=true;

while $files; do

read -p "Enter jmx file : " jmxFile
validateFile $jmxFile

read -p "You want to pass csv file [y/n] " csvStatus

if [ $csvStatus == 'y' ];then
	read -p "Enter csv file : " csv
	validateFile $csv
elif [ $csvStatus == 'n' ];then
	csv="NoCSV"
else
   echo  "Enter a valid response y or n ";
   files=true;
fi

echo $jmxFile,$csv >>mapper.csv

read -p "Enter another jmx file [y/n] " status

if [ $status ];then

	if [ $status == 'y' ]; then
		files=true;
	elif [ $status == 'n' ]; then
		files=false;
	else
	   echo  "Enter a valid response y or n ";
	   files=true;
	fi
else
   echo  "Enter a valid response y or n ";
   files=true;
fi

done

paste mapper.csv trial-master.csv trial-slave1.csv trial-slave2.csv trial-slave3.csv trial-slave4.csv -d ',' > info.csv
#	paste mapper.csv trial-master.csv trial-slave1.csv trial-slave2.csv  credentials.csv -d ',' > info.csv

jmxList=`cat info.csv`

for i in $jmxList
do
	jmxFileName=`echo $i | awk -F ',' '{ print $1 }'`
	csvFileName=`echo $i | awk -F ',' '{ print $2 }'`
	masterPodName=`echo $i | awk -F ',' '{ print $3 }'`
	slavePodName1=`echo $i | awk -F ',' '{ print $4 }' | cut -d ':' -f1`
	slavePodIP1=`echo $i | awk -F ',' '{ print $4 }' | cut -d ':' -f2`
	slavePodName2=`echo $i | awk -F ',' '{ print $5 }' | cut -d ':' -f1`
	slavePodIP2=`echo $i | awk -F ',' '{ print $5 }' | cut -d ':' -f2`
	slavePodName3=`echo $i | awk -F ',' '{ print $6 }' | cut -d ':' -f1`
	slavePodIP3=`echo $i | awk -F ',' '{ print $6 }' | cut -d ':' -f2`
	slavePodName4=`echo $i | awk -F ',' '{ print $7 }' | cut -d ':' -f1`
	slavePodIP4=`echo $i | awk -F ',' '{ print $7 }' | cut -d ':' -f2`
#	slavePodName5=`echo $i | awk -F ',' '{ print $8 }' | cut -d ':' -f1`
#	slavePodIP5=`echo $i | awk -F ',' '{ print $8 }' | cut -d ':' -f2`
#	clusterName=`echo $i | awk -F ',' '{ print $6 }'`
#	zoneName=`echo $i | awk -F ',' '{ print $7 }'`
	kubectl cp $jmxFileName -n $tenant $masterPodName:/$jmxFileName
	kubectl exec -it -n $tenant $masterPodName -- bash -c "echo 35.227.203.198 www.etsy.com etsy.com openapi.etsy.com api.etsy.com >> /etc/hosts"
	if [ $csvFileName != 'NoCSV' ];then
#		bash slave.sh trial-slave1 us-east1-b $tenant $slavePodName1 $csvFileName   
#		bash slave.sh trial-slave2 us-west1-a $tenant $slavePodName2 $csvFileName 
#		bash slave.sh trial-slave3 us-east4-b $tenant $slavePodName3 $csvFileName 
#		bash slave.sh trial-slave4 us-west2-a $tenant $slavePodName4 $csvFileName 
#		bash slave.sh trial-slave5 us-central1-c $tenant $slavePodName5 $csvFileName 

		clusterName=trial-slave1
                zoneName=us-east1-b
		gcloud container clusters get-credentials $clusterName --zone $zoneName --project etsyperftesting-208619
		kubectl exec -ti -n $tenant $slavePodName1 -- mkdir -p /jmeter/apache-jmeter-4.0/bin/csv/
		kubectl cp $csvFileName -n $tenant $slavePodName1:/jmeter/apache-jmeter-4.0/bin/csv/$csvFileName
                kubectl exec -it -n $tenant $slavePodName1 -- bash -c "echo 35.227.203.198 www.etsy.com etsy.com openapi.etsy.com api.etsy.com >> /etc/hosts"
		clusterName=trial-slave2
                zoneName=us-west1-a
		gcloud container clusters get-credentials $clusterName --zone $zoneName --project etsyperftesting-208619
		kubectl exec -ti -n $tenant $slavePodName2 -- mkdir -p /jmeter/apache-jmeter-4.0/bin/csv/
		kubectl cp $csvFileName -n $tenant $slavePodName2:/jmeter/apache-jmeter-4.0/bin/csv/$csvFileName
                kubectl exec -it -n $tenant $slavePodName2 -- bash -c "echo 35.227.203.198 www.etsy.com etsy.com openapi.etsy.com api.etsy.com >> /etc/hosts"
        	clusterName=trial-slave3
                zoneName=us-east4-b
		gcloud container clusters get-credentials $clusterName --zone $zoneName --project etsyperftesting-208619
		kubectl exec -ti -n $tenant $slavePodName3 -- mkdir -p /jmeter/apache-jmeter-4.0/bin/csv/
		kubectl cp $csvFileName -n $tenant $slavePodName3:/jmeter/apache-jmeter-4.0/bin/csv/$csvFileName
                kubectl exec -it -n $tenant $slavePodName3 -- bash -c "echo 35.227.203.198 www.etsy.com etsy.com openapi.etsy.com api.etsy.com >> /etc/hosts"
		clusterName=trial-slave4
                zoneName=us-west2-a
          	gcloud container clusters get-credentials $clusterName --zone $zoneName --project etsyperftesting-208619
		kubectl exec -ti -n $tenant $slavePodName4 -- mkdir -p /jmeter/apache-jmeter-4.0/bin/csv/
		kubectl cp $csvFileName -n $tenant $slavePodName4:/jmeter/apache-jmeter-4.0/bin/csv/$csvFileName
                kubectl exec -it -n $tenant $slavePodName4 -- bash -c "echo 35.227.203.198 www.etsy.com etsy.com openapi.etsy.com api.etsy.com >> /etc/hosts"
		fi

		clusterName=trial-master
		zoneName=us-central1-a
		gcloud container clusters get-credentials $clusterName --zone $zoneName --project etsyperftesting-208619
		kubectl exec -it -n $tenant $masterPodName -- /jmeter/load_test $jmxFileName $slavePodIP1 $slavePodIP2 $slavePodIP3 $slavePodIP4 &
#		kubectl exec -it -n $tenant $masterPodName -- /jmeter/load_test $jmxFileName $slavePodIP1 $slavePodIP2 &

	done



