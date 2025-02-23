data "archive_file" "lambda" {
  type        = "zip"
  source_file = "../src/nbda_data_lake.py"
  output_path = "nbda_data_lake.zip"
}

resource "aws_lambda_function" "DataLake-Caller" {
  filename      = "nbda_data_lake.zip"
  function_name = "DataLake-Caller"
  handler = "nbda_data_lake.lambda_handler"
  role          = aws_iam_role.DataLake-Caller-role.arn
  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.13"

  environment {
    variables = {
      SPORTS_DATA_API_KEY = var.NBA_API_KEY
      NBA_ENDPOINT_URL = var.NBA_ENDPOINT_URL
      NBA_S3_Bucket = aws_s3_bucket.sports-analytics-data-lake.bucket 
    }
  }
  timeout = 30
}
