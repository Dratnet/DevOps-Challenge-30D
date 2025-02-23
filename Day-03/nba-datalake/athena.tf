resource "aws_athena_database" "nba_data_lake" {
  name = "nba_data_lake"
  bucket = aws_s3_bucket.sports-analytics-data-lake.id
}

resource "aws_athena_workgroup" "nba_data_workgroup" {
  name = "nba_data_workgroup"
  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.sports-analytics-data-lake.bucket}/athena-results/"
    }
  }
}
