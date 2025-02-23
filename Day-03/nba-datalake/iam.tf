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
resource "aws_iam_role_policy" "DataLake-Caller-Policy" {
  role = aws_iam_role.DataLake-Caller-role.id
  policy = jsonencode ({
    Version = "2012-10-17"
    Statement = [
    {
      Sid = "databasecaller"
      Effect = "Allow"
      Action = [
        "athena:*",
        "s3:*"
        ]
      Resource = "*"
    },
  ]
})
}

# IAM role for Lambda
resource "aws_iam_role" "DataLake-Caller-role" {
  name               = "DataLake-Caller-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
