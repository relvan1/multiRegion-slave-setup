#!/usr/bin/env bash
#Script created to launch Jmeter tests directly from the current terminal without accessing the jmeter master pod.
#It requires that you supply the path to the jmx file
#After execution, test script jmx file may be deleted from the pod itself but not locally.

working_dir=`pwd`

rm -rf mapper.csv

touch mapper.csv

#Get namesapce variable
tenant=`awk '{print $NF}' $working_dir/tenant_export`

validateFile () {

	if [ -f $1 ];then
		return 0
	else
		echo "file not exists";
		exit 1
	fi
}

read -p 'Enter path to the jmx file ' jmx
validateFile $jmx

read -p "Enter another jmx file " jmx1
validateFile $jmx1

echo $jmx >>mapper.csv
echo $jmx1 >>mapper.csv

jmxFileMapping=`paste masters.csv mapper.csv ipList.csv -d *`


for i in $jmxFileMapping

do

fileName=`echo $i | cut -d '*' -f2`

ip=`echo $i | cut -d '*' -f3`

master_pod=`echo $i | cut -d '*' -f1`

#master_pod=`kubectl get po -n $tenant | grep jmeter-master | awk '{print $1}'`

#Get Master pod details

kubectl cp $fileName -n $tenant $master_pod:/$fileName

kubectl exec -ti -n $tenant $master_pod -- /jmeter/load_test $fileName $ip &

done

## Echo Starting Jmeter load test

#kubectl exec -ti -n $tenant $master_pod -- bash /jmeter/load_test $jmx &
