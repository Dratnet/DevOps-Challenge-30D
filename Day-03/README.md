# Datalake for NBA data on AWS
## Overview:
This goal of this project is to pull a large amount of data related to the NBA from the Sports IO API; then store the data in an S3 bucket to be indexed into an AWS glue database and table; to enable queries from Amazon Athena. In otherwords, a datalake for NBA data. The original implementation of the project was largely local using Python and the Boto3 SDK to configure the AWS resources. As part of the project, the service creation was moved to Terraform; and the logic of data export, transform, and load (ETL) was moved to AWS Lambda.

### AWS Architecture:
// TODO; upload JPEG/PNG of the Architecture and reference

**Services Used**:
- AWS Lambda
- Amazon Athena
- AWS glue
- Amazon S3

### Future Enhancements:
- Automating process to checking for stale data, updating the data.
- Frontend web application to visualize the data.

### Prerequisites:
- aws-cli/1.37.2
- Terraform v1.10.5
- hashicorp/aws v5.0 or greater

### Steps to deploy this in your account:
1) Clone the Directory to your local environment.
2) Configure AWS CLI and/or export AWS access keys as variables.
3) Change directory into `./Terraform`.
4) Initialize Terraform with `terraform init`
5) Deploy the resources with Terraform `terraform apply`
  - You will need to input the API token and URL for SportsDataIO address when applying/destroying the resources through Terraform. 

**NOTE** You can delete all resources with `terraform destroy`.

## References
//TODO; provide references to original project Github, video, discord, and AWS services.
