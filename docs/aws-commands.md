### -o PubkeyAuthentication=no -o PreferredAuthentications=password 
### sudo update-alternatives — config editor 

## AWS Lab


### create key pair with cli

aws ec2 create-key-pair --key-name web-test-key --key-type ed25519 --key-format pem --query "KeyMaterial" --output text > web-test-key.pem


### Get ami list


aws ec2 describe-images  --region eu-central-1   --owners amazon  --filters "Name=name,Values=ubuntu*" "Name=virtualization-type,Values=hvm" "Name=root-device-type,Values=ebs" --output table

##### beautufy output

aws ec2 describe-images  --region eu-central-1   --owners amazon  --filters "Name=name,Values=ubuntu*" "Name=virtualization-type,Values=hvm" "Name=root-device-type,Values=ebs"  --query "Images[].{Description:Description, Id:ImageId, Arch:Architecture, OwnerName:ImageOwnerAlias, OwnerId:OwnerId}" --output table

##### still too much. show me only ubuntu 22

aws ec2 describe-images  --region eu-central-1   --owners amazon  --filters "Name=architecture,Values=x86_64" "Name=name,Values=ubuntu*22.04*" "Name=virtualization-type,Values=hvm" "Name=root-device-type,Values=ebs"  --query "Images[].{Description:Description, Id:ImageId, Arch:Architecture, OwnerName:ImageOwnerAlias, OwnerId:OwnerId}" --output table

#### my ami's

aws ec2 describe-images     --owners <my_account_id> --query "Images[].{ImageId:ImageId, Name:Name}" --output table

#### last ami ID with ssm

aws ssm get-parameters --name "/aws/service/canonical/ubuntu/server/20.04/stable/current/amd64/hvm/ebs-gp2/ami-id" --output table

### Get instances list

aws ec2 describe-instances 

aws ec2 describe-instances --query "Reservations[].Instances[].{InstanceId:InstanceId,Name:Tags[?Key=='Name']|[0].Value}" --output table

aws ec2 stop-instances --instance-id i-0ee7d80c6f8eddeea

aws ec2 describe-instance-status


### create EC2 instance with cli

#### get vpc

aws ec2 describe-vpcs | grep VpcId

`sg-0c786ce03686a1594` - my SG

#### 1 - create security group

aws ec2 create-security-group \
    --group-name demo-sg-pro \
    --description "AWS ec2 CLI Demo SG" \
    --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=demo-sg}]' \
    --vpc-id "vpc-0783757ce83fe9384"

#### 2 - add inbound rules

aws ec2 authorize-security-group-ingress \
    --group-id "sg-01___________" \
    --protocol tcp \
    --port 22 \
    --cidr "0.0.0.0/0" 
    [--source-group sg-1a2b3c4d]


#### create SSH key pair (repeat, not neccessary)

aws ec2 create-key-pair --key-name web-key --key-type ed25519 --key-format pem --query "KeyMaterial" --output text > web-key.pem

#### create ec2 instance

(example with user-data)  

aws ec2 run-instances \
    --image-id ami-0d70546e43a941d70 \
    --count 1 \
    --instance-type t2.micro \
    --key-name bibin-server \
    --security-group-ids sg-07570e17ab8331f13 \
    --subnet-id subnet-00b5ede5e160caa59 \
    --block-device-mappings "[{\"DeviceName\":\"/dev/sdf\",\"Ebs\":{\"VolumeSize\":30,\"DeleteOnTermination\":false}}]" \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=demo-server}]' 'ResourceType=volume,Tags=[{Key=Name,Value=demo-server-disk}]' \
    --user-data file://path/to/script.sh

or `--user-data sudo systemctl nginx start`


### get ec2 instance metadata

TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` && \
curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/

## Links

https://devopscube.com/use-aws-cli-create-ec2-instance/
