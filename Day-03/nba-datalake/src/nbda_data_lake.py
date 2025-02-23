import boto3
import json
import time
import urllib3
import os

# AWS configuration
region = "us-east-2"
bucket_name = os.getenv("NBA_S3_Bucket")

# Defining Sportsdata.io API configuration
api_key = os.getenv("SPORTS_DATA_API_KEY")
nba_endpoint = os.getenv("NBA_ENDPOINT_URL")

# Create AWS S3 clients
s3_client = boto3.client("s3", region_name=region)
glue_client = boto3.client("glue", region_name=region)
athena_client = boto3.client("athena", region_name=region)

# Function Definitions
def fetch_nba_data():
    """Fetch NBA player data from sportsdata.io."""
    http = urllib3.PoolManager()
    try:
        response = http.request("GET", nba_endpoint, headers={"Ocp-Apim-Subscription-Key": api_key})
        print("Fetched NBA data successfully.")
        return json.loads(response.data.decode("utf-8"))
    except Exception as e:
        print(f"Error fetching NBA data: {e}")
        return []

def convert_to_line_delimited_json(data):
    """Convert data to line-delimited JSON format."""
    print("Converting data to line-delimited JSON format...")
    return "\n".join([json.dumps(record) for record in data])

def upload_data_to_s3(data):
    """Upload NBA data to the S3 bucket."""
    try:
        # Convert data to line-delimited JSON
        line_delimited_data = convert_to_line_delimited_json(data)
        # Define S3 object key
        file_key = "raw-data/nba_player_data.jsonl"

        # Upload JSON data to S3
        s3_client.put_object(
            Bucket=bucket_name,
            Key=file_key,
            Body=line_delimited_data
        )
        print(f"Uploaded data to S3: {file_key}")
    except Exception as e:
        print(f"Error uploading data to S3: {e}")

# Main Workflow
def lambda_handler(event, context):
    print("Setting up data lake for NBA sports analytics...")
    nba_data = fetch_nba_data()
    if nba_data:  # Only proceed if data was fetched successfully
        upload_data_to_s3(nba_data)

if __name__ == "__main__":
    main()

