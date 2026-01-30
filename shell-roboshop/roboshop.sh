#!/bin/bash

set -e  # exit if any command fails

############################
# VARIABLES
############################

SG_ID="sg-0740995f10ea6bcf0"
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z0848480352BVL54Y1D1I"
DOMAIN_NAME="amaravathi.today"
ROLE_ARN="arn:aws:iam::256364432032:role/Route53-CrossAccount-Role"

############################
# VALIDATION
############################

if [ $# -eq 0 ]; then
    echo "❌ Please provide instance names"
    echo "Example: sh roboshop.sh frontend mongodb catalogue"
    exit 1
fi

echo "Using EC2 Account:"
aws sts get-caller-identity
echo "----------------------------------"

############################
# FUNCTION → Assume Route53 Role
############################

assume_route53_role() {

    echo "🔐 Assuming Route53 cross-account role..."

    CREDS=$(aws sts assume-role \
        --role-arn $ROLE_ARN \
        --role-session-name route53-session)

    export R53_ACCESS_KEY=$(echo $CREDS | jq -r '.Credentials.AccessKeyId')
    export R53_SECRET_KEY=$(echo $CREDS | jq -r '.Credentials.SecretAccessKey')
    export R53_SESSION_TOKEN=$(echo $CREDS | jq -r '.Credentials.SessionToken')

    echo "✅ Role assumed successfully"
    echo "----------------------------------"
}

############################
# ASSUME ROLE ONLY ONCE
############################

assume_route53_role

############################
# LOOP THROUGH INSTANCES
############################

for instance in "$@"
do
    echo "🚀 Creating instance: $instance"

    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type "t3.micro" \
        --security-group-ids $SG_ID \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text)

    echo "Instance ID: $INSTANCE_ID"

    echo "⏳ Waiting for instance to enter running state..."
    aws ec2 wait instance-running --instance-ids $INSTANCE_ID

    if [ "$instance" == "frontend" ]; then

        echo "⏳ Waiting for status checks..."
        aws ec2 wait instance-status-ok --instance-ids $INSTANCE_ID

        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text)

        RECORD_NAME="$DOMAIN_NAME"

    else

        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text)

        RECORD_NAME="$instance.$DOMAIN_NAME"

    fi

    echo "✅ IP Address: $IP"
    echo "🌐 Updating DNS: $RECORD_NAME → $IP"

    ############################
    # ROUTE53 USING TEMP CREDS
    ############################

    AWS_ACCESS_KEY_ID=$R53_ACCESS_KEY \
    AWS_SECRET_ACCESS_KEY=$R53_SECRET_KEY \
    AWS_SESSION_TOKEN=$R53_SESSION_TOKEN \
    aws route53 change-resource-record-sets \
        --hosted-zone-id $ZONE_ID \
        --change-batch "{
            \"Comment\": \"Updating record\",
            \"Changes\": [{
                \"Action\": \"UPSERT\",
                \"ResourceRecordSet\": {
                    \"Name\": \"$RECORD_NAME\",
                    \"Type\": \"A\",
                    \"TTL\": 60,
                    \"ResourceRecords\": [{
                        \"Value\": \"$IP\"
                    }]
                }
            }]
        }"

    echo "✅ DNS updated for $instance"
    echo "----------------------------------"

done

echo "🎉 ALL INSTANCES CREATED & DNS CONFIGURED SUCCESSFULLY!"