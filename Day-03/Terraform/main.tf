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
resource "aws_iam_role_policy" "GameDataAPI-Caller-Policy" {
  role = aws_iam_role.GameDataAPI-Caller-role.id
  policy = jsonencode ({
    Version = "2012-10-17"
    Statement = [
    {
      Sid = "gamedatasns"
      Effect = "Allow"
      Action = [
        "sns:Publish"
        ]
      Resource = "${aws_sns_topic.GameData_NBA_Topic.arn}"
    },
  ]
})
}

# IAM role for Lambda
resource "aws_iam_role" "GameDataAPI-Caller-role" {
  name               = "GameDataAPI-Caller-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# IAM Role for EventBridge Scheduler
resource "aws_iam_role" "GameDataAPI-Scheduler-Role" {
  name               = "GameDataAPI-Scheduler-Role"
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
resource "aws_iam_role_policy" "GameDataAPI-Scheduler-Role-Policy" {
  name   = "GameDataAPI-Scheduler-Role-Policy"
  role   = aws_iam_role.GameDataAPI-Scheduler-Role.id
  policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Effect : "Allow"
        Action : [
          "lambda:InvokeFunction"
        ]
        Resource : aws_lambda_function.GameDataAPI-Caller.arn
      }
    ]
  })
}

# Lambda configuration
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "../src/GameData_Notifications.py"
  output_path = "GameData_Notifications.zip"
}

resource "aws_lambda_function" "GameDataAPI-Caller" {
  filename      = "GameData_Notifications.zip"
  function_name = "GameDataAPI-Caller"
  handler = "GameData_Notifications.lambda_handler"
  role          = aws_iam_role.GameDataAPI-Caller-role.arn
  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.13"

  environment {
    variables = {
      NBA_API_KEY = var.NBA_API_KEY
      SNS_TOPIC_ARN = aws_sns_topic.GameData_NBA_Topic.arn
    }
  }
  timeout = 30
}

# EventBridge Scheduler Configuration
resource "aws_scheduler_schedule" "GameDataAPI-12-hour-Schedule" {
  name        = "GameDataAPI-12-hour-Schedul"
  description = "Schedule to invoke Lambda function every 2 hours"

  schedule_expression = "rate(2 hours)" # Cron or rate expression
  flexible_time_window {
    mode = "OFF" # No flexible time window
  }

  target {
    arn    = aws_lambda_function.GameDataAPI-Caller.arn
    role_arn = aws_iam_role.GameDataAPI-Scheduler-Role.arn
 }
}

#SNS Configurationi
resource "aws_sns_topic" "GameData_NBA_Topic" {
  name = "GameData_NBA_Topic"
}

resource "aws_sns_topic_subscription" "GameData_NBA_Subscription"{
  topic_arn = aws_sns_topic.GameData_NBA_Topic.arn
  protocol = "email"
  endpoint = var.GAMEDATA_NOTIFICATION_EMAIL
}
