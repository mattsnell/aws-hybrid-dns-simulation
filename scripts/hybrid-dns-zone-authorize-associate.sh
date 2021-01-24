#!/bin/sh
# create a vpc association authorization, associate, and clean up
#  Outcome: authorize a vpc in another aws account to associate a route 53 private hosted zone
#  https://aws.amazon.com/premiumsupport/knowledge-center/private-hosted-zone-different-account/

SOURCE_ACCOUNT_PROFILE=
DESTINATION_ACCOUNT_PROFILE=

HOSTED_ZONE_ID=
VPC_REGION=
VPC_ID=

while [ -z ${HOSTED_ZONE_ID} ]; do
    printf "\nEnter the hosted zone ID:  "
    read HOSTED_ZONE_ID
done

while [ -z ${VPC_ID} ]; do
    printf "\nEnter the VPC's ID:  "
    read VPC_ID
done

while [ -z ${VPC_REGION} ]; do
    printf "\nEnter the VPC's region:  "
    read VPC_REGION
done

# create authorization in source/hub account
aws route53 create-vpc-association-authorization \
--profile ${SOURCE_ACCOUNT_PROFILE} \
--hosted-zone-id ${HOSTED_ZONE_ID} \
--vpc VPCRegion=${VPC_REGION},VPCId=${VPC_ID}

# associate hosted zone with vpc in destination/spoke account
aws route53 associate-vpc-with-hosted-zone \
--profile ${DESTINATION_ACCOUNT_PROFILE} \
--hosted-zone-id ${HOSTED_ZONE_ID} \
--vpc VPCRegion=${VPC_REGION},VPCId=${VPC_ID}

# remove the authorization in the source/hub account
aws route53 delete-vpc-association-authorization \
--profile ${SOURCE_ACCOUNT_PROFILE} \
--hosted-zone-id ${HOSTED_ZONE_ID} \
--vpc VPCRegion=${VPC_REGION},VPCId=${VPC_ID}