# EKS Terraform Module for AWS

This repository contains Terraform modules to create an Amazon Elastic Kubernetes Service (EKS) cluster with worker nodes in AWS.



## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.


## Prerequisites

-    **'Terraform'** >= 0.14.x
-    **'AWS CLI'**
-    **'kubectl'** >= 1.15.0
-    **'aws-iam-authenticator'** >= 0.5.0

## It provisions the following resources:

-    Amazon Elastic Compute Cloud (EC2) instance, key pair, subnet, and security group
-    Amazon VPC, internet gateway, and route table
-    Amazon EKS IAM roles and policies
-    EKS control plane, node group, and worker node security groups


## Modules

This repository contains the following Terraform modules:

-    Sg_EKS: creates security groups for the EKS cluster.
-    EKS: creates the EKS cluster and worker nodes.