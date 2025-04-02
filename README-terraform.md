# High Availability Web Application Infrastructure - Terraform Implementation

This Terraform configuration deploys a highly available web application infrastructure on AWS with the following components:

## Architecture Diagram

[Architecture diagram will be added here]

## Architecture Components

1. **VPC with Multi-AZ Setup** (modules/vpc)
   - 2 Public Subnets (across different AZs)
   - 2 Private Subnets (across different AZs)
   - Internet Gateway for public access
   - NAT Gateways for private subnet internet access

2. **Amazon RDS** (modules/rds)
   - Multi-AZ MySQL deployment
   - Deployed in private subnets
   - Automated backups and maintenance
   - Secure access from web servers only

3. **Amazon EFS** (modules/efs)
   - Shared file system across AZs
   - Mount targets in each private subnet
   - Encrypted at rest
   - Automatic lifecycle management

4. **Web Tier** (modules/web)
   - Auto Scaling Group (2-4 instances)
   - Application Load Balancer
   - Launch Template with Amazon Linux 2023
   - Automated EFS mounting

## Prerequisites

1. Terraform installed (version >= 1.0)
2. AWS CLI configured with appropriate credentials
3. AWS account with sufficient permissions

## Usage

1. Initialize Terraform:
```bash
terraform init
```

2. Create a `terraform.tfvars` file with your variables:
```hcl
environment_name = "production"
aws_region      = "us-east-1"
db_username     = "admin"
db_password     = "your-secure-password"
```

3. Review the execution plan:
```bash
terraform plan
```

4. Apply the configuration:
```bash
terraform apply
```

## Variables

Key variables that you can customize:
- `environment_name`: Prefix for resource names
- `aws_region`: AWS region to deploy in
- `vpc_cidr`: CIDR block for VPC
- `instance_type`: EC2 instance type
- `db_instance_class`: RDS instance class
- `db_name`: Database name
- `db_username`: Database admin username
- `db_password`: Database admin password

## Outputs

After successful deployment, you'll get:
- VPC ID
- Load Balancer DNS name
- RDS endpoint
- EFS DNS name

## Maintenance

- RDS is configured with automated backups
- EFS has lifecycle management enabled
- Auto Scaling handles capacity management
- Security groups restrict access appropriately

## Clean Up

To destroy the infrastructure:
```bash
terraform destroy
```

## Security Considerations

- All sensitive resources are in private subnets
- Security groups implement least-privilege access
- RDS and EFS are only accessible from web servers
- All data is encrypted at rest
- Sensitive variables are marked as sensitive in Terraform
