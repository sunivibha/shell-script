#!/bin/bash

#### change these values ###
ZONE_ID="Z0571214106NI8MA27DT9"
SG_NAME="allow all"
#ENV="dev"
##############################

env=dev

create_ec2() {
  PRIVATE_IP=$(aws ec2 run-instances \
     --image-id ${AMI ID} \
     --instance-type t3.micro \
     --tag-specifications "ResourceType=Instance, Tags=[{key=Name, Value=${COMPONENT}}]" "ResourceType=spot-instances-request,Tags=[{key=name,Value=${component}}]" \
     --instance-market-options "MarketType=spot,SpotOptions={SpotInstanceType=persistent,InstanceInterruptionBehaviour=stop}"\
     --security-group-ids ${SGID} \
     | jq '.Instances[].privateIpAddress' | sed -e 's/"//g')
exit
  sed -e "s/IPADDRESS/${PRIVATE_IP}/" -e "s/COMPONENT/${COMPONENT}/" route53.json >/tmp/record.json
  aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file:///tmp/record.json | jq
}
