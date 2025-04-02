# High Availability Web Application Infrastructure

This CloudFormation template deploys a highly available web application infrastructure with the following components:

## Architecture Components

1. **VPC with Multi-AZ Setup**
   - 2 Public Subnets (across different AZs)
   - 2 Private Subnets (across different AZs)
   - Internet Gateway for public access
   - NAT Gateways for private subnet internet access

2. **Amazon RDS**
   - Multi-AZ deployment for high availability
   - MySQL database engine
   - Deployed in private subnets
   - Automated backups and maintenance

3. **Amazon EFS**
   - Shared file system across AZs
   - Mounted on all web servers
   - Highly available and fully managed
   - Encrypted at rest

4. **Auto Scaling Group**
   - Minimum 2 instances across AZs
   - Scales based on demand (up to 4 instances)
   - Uses Launch Template
   - Automated health checks

5. **Application Load Balancer**
   - Distributes traffic across AZs
   - Health checks for instances
   - Public-facing in public subnets

## Deployment Instructions

1. Prerequisites:
   - AWS CLI installed and configured
   - Appropriate AWS permissions

2. Deploy the stack:
```bash
aws cloudformation create-stack \
  --stack-name webapp-infrastructure \
  --template-body file://ha-webapp-infrastructure.yaml \
  --parameters \
    ParameterKey=DBUsername,ParameterValue=admin \
    ParameterKey=DBPassword,ParameterValue=<your-secure-password> \
  --capabilities CAPABILITY_IAM
```

3. Monitor the stack creation:
```bash
aws cloudformation describe-stacks --stack-name webapp-infrastructure
```

## Parameters

- `EnvironmentName`: Name prefix for resources (default: Production)
- `VpcCIDR`: CIDR block for VPC (default: 10.0.0.0/16)
- `InstanceType`: EC2 instance type (default: t3.micro)
- `DBInstanceClass`: RDS instance class (default: db.t3.small)
- `DBName`: Database name
- `DBUsername`: Database admin username
- `DBPassword`: Database admin password

## Outputs

- VPC ID
- Public and Private Subnet IDs
- Load Balancer DNS name
- RDS Endpoint
- EFS File System ID

## Security Considerations

- All sensitive resources are in private subnets
- RDS and EFS are only accessible from web servers
- Web servers are behind a load balancer
- All data is encrypted at rest
- Database credentials are stored securely

## Maintenance

- RDS maintenance window is automatically scheduled
- EC2 instances are automatically replaced if unhealthy
- EFS requires no maintenance
- Auto Scaling handles capacity management
