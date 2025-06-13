# Terraform AWS Load Balanced Apache Web Server Setup

This project provisions a highly available, load-balanced Apache web server infrastructure using **Terraform** on **AWS**.

---

## Files Included

| File               | Description                                                                 |
|--------------------|-----------------------------------------------------------------------------|
| `main.tf`          | Defines EC2 instances, Load Balancer, Target Group, Security Groups.       |
| `variables.tf`     | Declares input variables.                                                   |
| `terraform.tfvars` | Provides values for variables.                                              |
| `outputs.tf`       | Outputs instance IPs and Load Balancer DNS.                                |

---

##  Prerequisites

- AWS account with proper IAM permissions
- Terraform installed (`terraform -version`)
- Existing VPC, subnets and AMI (used in `terraform.tfvars`)
- Existing EC2 Key Pair (e.g., `task-key`)

---

## Infrastructure Provisioned

- **VPC**: Existing VPC (`ms-dev-vpc`)
- **Subnets**:
  - `msdev-public-1` (10.0.0.0/26)
  - `msdev-public-2` (10.0.0.64/26)
- **Security Group**: Allows inbound HTTP (port 80) and all outbound traffic
- **EC2 Instances**: 2 x `t3.micro`, each with Apache2 installed and running
- **Application Load Balancer**: Distributes HTTP traffic across instances
- **Target Group**: Registers EC2s with health check on `/`

---

## How to Use

### 1. Clone this repo

`git clone https://github.com/Dinaharan1999/task-1.git
cd task-1`

## Deployment Steps

### 1. Initialize Terraform
`terraform init`

### 2. Apply Configuration
`terraform apply`

### 3. Get Outputs
After applying, Terraform will output:

- Load Balancer DNS
- Public IPs of both EC2 instances

Verify Setup

`curl http://<load_balancer_dns>`

## High Availability Test

- Stop one EC2 instance from AWS Console.
- Load balancer continues routing to the healthy instance.

## Destroy Infrastructure
`terraform destroy`

##  Notes

- Apache installed via `user_data`
- ALB performs health checks and routes only to healthy instances.
