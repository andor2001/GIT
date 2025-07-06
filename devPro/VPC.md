> VARIABLES
    VPC_ID
    PUB_SUB_ID
    PRIV_SUB_ID
    AMI_ID
    SG_ID

########################################################################
# create vpc
aws ec2 create-vpc \
    --region eu-west-1 \
    --cidr-block 192.168.0.0/22 \
    --tag-specification 'ResourceType=vpc,Tags=[{Key=Name,Value=DemoVpc}]'

# get id vpc
aws ec2 describe-vpc
>     "VpcId": "vpc-066b28f4533fc0bb7"

# set var vpc_id
export VPC_ID=vpc-066b28f4533fc0bb7

# create subnet public
aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 192.168.0.0/24 \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=demo-subn-public}]'

# create subnet private
aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 192.168.1.0/24 \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=demo-subn-private}]'

# get id public_subnet (Tags: "Value": "public-sub")
aws ec2 describe-subnets
>     "SubnetId": "subnet-0f02420413d01d18c"

# get id private_subnet (Tags: "Value": "private-sub")
aws ec2 describe-subnets
>     "SubnetId": "subnet-05baac0b607a5586d"

# set var public-sub & private-sub
export PUB_SUB_ID=subnet-0f02420413d01d18c
export PRIV_SUB_ID=subnet-05baac0b607a5586d

# get last ec2 ami
aws ssm get-parameters --name "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id" --output table
>     ami-0d0fa503c811361ab

# set var  ami_id
export AMI_ID=ami-0d0fa503c811361ab

# create security-groups
aws ec2 create-security-group \
    --group-name demo-sg \
    --description "AWS ec2 CLI Demo SG" \
    --tag-specification 'ResourceType=security-group,Tags=[{Key=Name,Value=demo-sg}]' \
    --vpc-id $VPC_ID

# get id security group demo-sg
aws ec2 describe-security-groups
>     "GroupId": "sg-0c12ee58dd8e01d4d"

# set var sec-group
export SG_ID=sg-0c12ee58dd8e01d4d

# create sg demo-web
aws ec2 create-security-group \
    --group-name demo-web-sg \
    --description "AWS ec2 CLI Demo web SG" \
    --tag-specification 'ResourceType=security-group,Tags=[{Key=Name,Value=demo-web-sg}, {Key=Project,Value=demo}]' \
    --vpc-id "$VPC_ID"
>     "GroupId": "sg-0f933e3cb99afcc24"

# set var demo-web-sg
export SG_WEB_ID=sg-0f933e3cb99afcc24

# create sg demo-db
aws ec2 create-security-group \
    --group-name demo-db-sg \
    --description "AWS ec2 CLI Demo db SG" \
    --tag-specification 'ResourceType=security-group,Tags=[{Key=Name,Value=demo-db-sg}, {Key=Project,Value=demo}]' \
    --vpc-id "$VPC_ID"
>     "GroupId": "sg-0dbe07e89bce7df2a"

# set var demo-db-sg
export SG_DB_ID=sg-0dbe07e89bce7df2a

# add inbound rules
aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --protocol tcp \
    --port 22 \
    --cidr "0.0.0.0/0"
>     "GroupId": "sg-0c12ee58dd8e01d4d"

aws ec2 authorize-security-group-ingress \
    --group-id "$SG_WEB_ID" \
    --protocol tcp \
    --port 80 \
    --cidr "0.0.0.0/0"
>     "GroupId": "sg-0f933e3cb99afcc24"

aws ec2 authorize-security-group-ingress \
    --group-id "$SG_DB_ID" \
    --protocol -1 \
    --port -1 \
    --source-group $SG_DB_ID
>     "GroupId": "sg-0dbe07e89bce7df2a"


# create ec2 instance

## public
aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type t2.micro \
    --key-name aws_mykey \
    --security-group-ids $SG_WEB_ID $SG_DB_ID \
    --subnet-id $PUB_SUB_ID \
    --block-device-mappings "[{\"DeviceName\":\"/dev/sdf\",\"Ebs\":{\"VolumeSize\":30,\"DeleteOnTermination\":false}}]" \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=demo-web-server}, {Key=Project,Value=demo}]' \
    --user-data file://~/HILL/andrii_moskovec/HomeWorks/hw-2/web.sh

>
    cat ~/HILL/andrii_moskovec/HomeWorks/hw-2/web.sh
     #!/bin/bash
     apt update
     apt install -y git python3-pip awscli mariadb-client >


>      "InstanceId": "i-041e8d41808c5d49a"

## private
aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type t2.micro \
    --key-name aws_mykey \
    --security-group-ids $SG_DB_ID \
    --subnet-id $PRIV_SUB_ID \
    --block-device-mappings "[{\"DeviceName\":\"/dev/sdf\",\"Ebs\":{\"VolumeSize\":30,\"DeleteOnTermination\":false}}]" \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=demo-db-server}, {Key=Project,Value=demo}]'

>     "InstanceId": "i-0059958ddbb2d15ee"


#    END
