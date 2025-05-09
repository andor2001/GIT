## AWS Lab
### Get AMI list
aws ssm get-parameters --name /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id --output table

#### 1- create security group
aws ec2 create-security-group \
   --group-name demo-web-sg \
   --description "AWS ec2 CLI Demo web SG" \
   --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=demo-web.sg}, {Key=Project,Value=demo}]'
