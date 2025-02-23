# Database
resource "aws_glue_catalog_database" "glue_nba_database" {
  name = "glue_nba_database"
}

# JSON Table for Athena
resource "aws_glue_catalog_table" "nba_players" {
  name          = "nba_players"
  database_name = "glue_nba_database"
  table_type = "EXTERNAL_TABLE"
  parameters = {
    EXTERNAL              = "TRUE"
  }
  storage_descriptor {
    location      = "s3://${aws_s3_bucket.sports-analytics-data-lake.bucket}"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    ser_de_info {
      name                  = "nba-stream"
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
      }
    columns {
      name = "PlayerID"
      type = "int"
    }

    columns {
      name = "FirstName"
      type = "string"
    }

    columns {
      name    = "LastName"
      type    = "string"
    }

    columns {
      name    = "Team"
      type    = "string"
    }

    columns {
      name    = "Position"
      type    = "string"
    }
    columns {
      name    = "Points"
      type    = "int"
    }
  }
}
