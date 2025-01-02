# AWS Infrastructure Setup with Terraform

This project demonstrates how to set up an AWS infrastructure using Terraform. The goal is to create a secure and scalable environment for hosting a web server with Apache2. The infrastructure includes VPC creation, subnet setup, routing, security groups, network interfaces, an Elastic IP, and a web server running Ubuntu with Apache2.

## Features

- **VPC Setup**: A Virtual Private Cloud (VPC) is created with a custom CIDR block to isolate the infrastructure.
- **Internet Gateway**: An Internet Gateway is provisioned to enable public internet access.
- **Route Table**: A custom route table is created to ensure traffic is directed through the Internet Gateway.
- **Subnet Creation**: A subnet is created in an availability zone with a dedicated IP range.
- **Security Groups**: Security group configurations are implemented to allow inbound HTTP, HTTPS, and SSH traffic, while allowing all outbound traffic.
- **Network Interface**: A custom network interface is set up and associated with the web server instance.
- **Elastic IP**: An Elastic IP is assigned to the network interface for external access to the web server.
- **EC2 Instance**: An Ubuntu-based EC2 instance is created, and Apache2 is installed and configured using a simple user-data script. The instance is automatically configured to serve a custom HTML page.

## Steps Covered

1. **VPC Creation**: Define a CIDR block and tags for the VPC.
2. **Internet Gateway**: Enable the VPC to access the internet.
3. **Route Table**: Create a route to send all outbound traffic to the Internet Gateway.
4. **Subnet and Network Interface**: Provision a subnet and network interface for the instance.
5. **Security Group**: Define rules to allow HTTP, HTTPS, and SSH traffic.
6. **Elastic IP**: Allocate an Elastic IP for the web server.
7. **EC2 Instance Setup**: Provision an EC2 instance, install Apache2, and serve a basic HTML page.

This setup is ideal for developers looking to automate the provisioning of a secure web server environment on AWS using Terraform.

## Requirements

- **Terraform**: You need to have Terraform installed and configured to use this script.
- **AWS Account**: Access to an AWS account and appropriate IAM credentials.

## How to Run

1. Set up your AWS credentials in the provider block (make sure to replace `access_key` and `secret_key`).
2. Run `terraform init` to initialize Terraform.
3. Execute `terraform apply` to create the resources.

## Architecture Overview

![Server Output](op.png)

## Notes

- Ensure your AWS credentials are properly set up to allow Terraform to interact with your AWS account.
- After running `terraform apply`, Terraform will provision the infrastructure and output any relevant information, including the public IP of the EC2 instance running the web server.
