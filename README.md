# terraform-aws

Test project that demostrates using Terraform to manage AWS services.

---

The original idea of the project belongs to [Aleks Volochnev](https://github.com/HadesArchitect).

This project shows the use cases for a number of AWS services: 

* EC2 (Elastic Compute Cloud, virtual private servers);
* Lambda (serverless functions);
* API Gateway;
* S3 (Simple Storage Service);
* VPC (Virtual Private Cloud);
* SNS (Simple Notification Service);
* SQS (Simple Queue Service);
* DynamoDB (key-value database);
* IAM (Identity and Access Management).

It contains 2 stacks:

* voting stack: S3 <-> API Gateway <-> Lambda <-> SNS -> SQS -> EC2 Instance -> DynamoDB. A serverless application hosted on an S3 bucket calls a lambda function through the API Gateway. The lambda function publishes a message to the notification service SNS, which sends the message to the queue service SQS. A python application running on an EC2 Instance periodically pulls messages from the queue and updates the data in DynamoDB.
* result stack: S3 <-> API Gateway <-> Lambda <-> DynamoDB. A serverless application hosted on an S3 bucket periodically calls a lambda function through the API Gateway. The lambda function queries DynamoDB and sends the current voting results back.

## Usage

* Initialize Terraform

```
> terraform init
```

* Deploy the services on the AWS cloud using Terraform:

```
> terraform apply
```

or if you specify variables' values in `variables.tfvars` file

```
> terraform apply -var-file="variables.tfvars"
```

* Remove the deployed services from AWS cloud.

```
> terraform destroy
```
