# Weather Data Collector
## Overview:
Build a weather data collection system which uses the OpenWeather API [1] to pull weather details for multiple cities, and store the data in AWS S3 [2] for dashboarding.

## AWS Architecture:
![AWS Architecture Diagram](./Images/ArchitetureDiagam.png)

**Services Used**:
1) AWS EventBridge Scheduler
2) AWS Lambda
3) AWS S3

## Future Enhancements:
1) Implement Data visualization through CloudWatch dashboards using custom metrics and/or explore other alternatives.
2) Add a private API for developers to request weather data ad-hoc and outside of the schedule.
3) Setup CI/CD pipeline for iteration.

### Prerequisites:
1) AWS Account to deploy resources
2) OpenWeather API account - One Call API 3.0
3) Terraform
4) Terraform state directory `~/Documents/Terraform/State/DevOps/Day-01/terraform.tfstate"`
  

### Steps to deploy this in your account:
1) Clone the Directory to your local environment.
2) Configure AWS CLI and/or export AWS access keys as variables.
3) Change directory into `./Terraform`.
4) Initialize Terraform with `terraform init`
5) Deploy the resources with Terraform `terraform apply`

**NOTE** You can delete all resources with `terraform destroy`, however please note this will delete all objects stored in the created S3 bucket. To disable this, change the `force_destroy = true` attribute in the `main.tf` file to *false*. 


## References:
1) - [OpenWeatherAPI](https://openweathermap.org/api)
2) - [AWS S3](https://docs.aws.amazon.com/s3/)
3) - [Youtube Video](https://youtu.be/A95XBJFOqjw) - ShaeInTheCloud
