### Get ami id (eu-central-2 ubuntu 22.04 stable)
```
aws ssm get-parameters --name /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id --output table
```

