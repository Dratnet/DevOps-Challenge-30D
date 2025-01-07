variable "OPENWEATHER_API_KEY" {
  type = string
  description = "API Key for Provider"
  sensitive = true
  validation {
    condition = length(var.OPENWEATHER_API_KEY) > 0
    error_message = "The OpenWeather API Key must be a non-empty string."
  }
}

variable "AWS_BUCKET_NAME" {
  type = string
  description = "Name for the AWS Bucket"
  validation {
    condition = length(var.AWS_BUCKET_NAME) > 0
    error_message = "The AWS Bucket name must be a non-empty string."
  }
}

variable "AWS_BUCKET_REGION" {
  type = string
  description = "Region for the AWS Bucket"
  validation {
    condition = length(var.AWS_BUCKET_REGION) > 0
    error_message = "The AWS Bucket region must be a non-empty string."
  }
}

