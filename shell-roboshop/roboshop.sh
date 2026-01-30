#!/bin/bash

SG_ID="sg-0740995f10ea6bcf0" # replace with your ID
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z0848480352BVL54Y1D1I" # replace with your hosted zone ID
DOMAIN_NAME="amaravathi.today"
: "${ROLE_ARN:?Need to set ROLE_ARN}"


echo "Assuming cross-account role..."

CREDS=$(aws sts assume-role \
    --role-arn $ROLE_ARN \
    --role-session-name route53-session)

export AWS_ACCESS_KEY_ID=$(echo $CREDS | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $CREDS | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $CREDS | jq -r '.Credentials.SessionToken')

echo "Role assumed successfully"
echo "----------------------------------"

for instance in $@
do
    echo "Creating instance: $instance"

    INSTANCE_ID=$( aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text )

    aws ec2 wait instance-running --instance-ids $INSTANCE_ID

    if [ $instance == "frontend" ]; then

        aws ec2 wait instance-status-ok --instance-ids $INSTANCE_ID

        IP=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text
        )
        RECORD_NAME="$DOMAIN_NAME" # amaravathi.today
    else
        IP=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text
        )
        RECORD_NAME="$instance.$DOMAIN_NAME" # mongodb.amaravathi.today
    fi

    echo "IP Address: $IP"

    echo "Updating DNS for $RECORD_NAME -> $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Updating record",
        "Changes": [
            {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [
                {
                    "Value": "'$IP'"
                }
                ]
            }
            }
        ]
    }
    '

    echo "✅ DNS updated for $instance"
    echo "----------------------------------"

done