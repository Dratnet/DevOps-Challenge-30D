# IAM policy for Lambda

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# IAM Role policy for Lambda
resource "aws_iam_role_policy" "WeatherAPI-Caller-Policy" {
  role = aws_iam_role.WeatherAPI-Caller-role.id
  policy = jsonencode ({
    Version = "2012-10-17"
    Statement = [
    {
      Sid = "AccessToS3"
      Effect = "Allow"
      Action = [
        "s3:Put*",
        "s3:List*",
        "s3:Get*",
        "s3:Create*",
        ]
      Resource = "*"
    },
  ]
})
}

# IAM role for Lambda
resource "aws_iam_role" "WeatherAPI-Caller-role" {
  name               = "WeatherAPI-Caller-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# IAM Role for EventBridge Scheduler
resource "aws_iam_role" "WeatherAPI-Scheduler-Role" {
  name               = "WeatherAPI-Scheduler-Role"
  assume_role_policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Effect : "Allow"
        Principal : {
          Service : "scheduler.amazonaws.com"
        }
        Action : "sts:AssumeRole"
      }
    ]
  })
}

# IAM role policy 
resource "aws_iam_role_policy" "WeatherAPI-Scheduler-Role-Policy" {
  name   = "WeatherAPI-Scheduler-Role-Policy"
  role   = aws_iam_role.WeatherAPI-Scheduler-Role.id
  policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Effect : "Allow"
        Action : [
          "lambda:InvokeFunction"
        ]
        Resource : aws_lambda_function.WeatherAPI-Caller.arn
      }
    ]
  })
}

# Lambda configuration
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "../src/WeatherAPI-Caller.py"
  output_path = "WeatherAPI-Output.zip"
}

resource "aws_lambda_function" "WeatherAPI-Caller" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "WeatherAPI-Output.zip"
  function_name = "WeatherAPI-Caller"
  handler = "WeatherAPI-Caller.lambda_handler"
  role          = aws_iam_role.WeatherAPI-Caller-role.arn
  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.13"

  environment {
    variables = {
      AWS_BUCKET_NAME = var.AWS_BUCKET_NAME
      AWS_BUCKET_REGION = var.AWS_BUCKET_REGION
      OPENWEATHER_API_KEY = var.OPENWEATHER_API_KEY
    }
  }
  timeout = 30
}

# S3 Configuration
resource "aws_s3_bucket" "WeatherAPI-Bucket" {
  bucket = var.AWS_BUCKET_NAME
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "WeatherAPI-Bucket-Policy" {
  bucket = aws_s3_bucket.WeatherAPI-Bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# EventBridge Scheduler Configuration
resource "aws_scheduler_schedule" "WeatherAPI-12-hour-Schedule" {
  name        = "WeatherAPI-12-hour-Schedul"
  description = "Schedule to invoke Lambda function every 12 hours"

  schedule_expression = "rate(12 hours)" # Cron or rate expression
  flexible_time_window {
    mode = "OFF" # No flexible time window
  }

  target {
    arn    = aws_lambda_function.WeatherAPI-Caller.arn
    role_arn = aws_iam_role.WeatherAPI-Scheduler-Role.arn

    input = jsonencode({
      key1 = "value1",
      key2 = "value2"
    }) # Optional: Specify input payload for Lambda function
  }
}
