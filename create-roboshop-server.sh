#!/bin/bash

#### change these values ###
ZONE_ID="Z0571214106NI8MA27DT9"
SG_NAME="allow all"
#ENV="dev"
#############################

env=dev

create_ec2() {
  PRIVATE_IP=$(aws ec2 run-instances \
     --image-id ${AMI_ID} \
     --instance-type t3.micro \
     --tag-specifications "ResourceType=Instance, Tags=[{key=Name, Value=${COMPONENT}}]" "ResourceType=spot-instances-request,Tags=[{key=name,Value=${component}}]" \
     --instance-market-options "MarketType=spot,SpotOptions={SpotInstanceType=persistent,InstanceInterruptionBehaviour=stop}"\
     --security-group-ids ${SGID} \
     | jq '.Instances[].privateIpAddress' | sed -e 's/"//g')
exit
  sed -e "s/IPADDRESS/${PRIVATE_IP}/" -e "s/COMPONENT/${COMPONENT}/" route53.json >/tmp/record.json
  aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file:///tmp/record.json | jq
}


## Main Program
AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=Centos-8-DevOPs-practice" | jq '.Images[].ImageId' | sed -e 's/"//g')
if [ -z "${AMI_ID}" ]; then
  echo "AMI_ID not found"
  exit 1
fi

SGID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=${SG_NAME} | jq '.SecurityGroups[].GroupId' | sed -e 's/"//g')
if [ -z "${SGID}" ]; then
  echo "Given Security Group does not exit"
  exit 1
fi


for component in catalogue cart user shipping payment frontend mongodb mysql rabbitmq redis dispatch; do
  COMPONENT="${env}-${component}"
  create_ec2
done