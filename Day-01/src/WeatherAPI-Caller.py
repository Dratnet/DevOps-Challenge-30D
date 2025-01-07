import json
import os
import boto3
import logging
from datetime import datetime
import urllib3

# Configure Logging
logger = logging.getLogger()
logger.setLevel("INFO")

class WeatherDashboard:
    def __init__(self):
        self.api_key = os.environ['OPENWEATHER_API_KEY']
        self.bucket_name = os.environ['AWS_BUCKET_NAME']
        self.bucket_region = os.environ['AWS_BUCKET_REGION']
        self.s3_client = boto3.client('s3')
        self.http = urllib3.PoolManager()  # Create a PoolManager instance

    def create_bucket_if_not_exists(self):
        """Create S3 bucket if it doesn't exist"""
        try:
            self.s3_client.head_bucket(Bucket=self.bucket_name)
            print(f"Bucket {self.bucket_name} exists")
        except self.s3_client.exceptions.ClientError:
            print(f"Creating bucket {self.bucket_name}")
            try:
                self.s3_client.create_bucket(Bucket=self.bucket_name,CreateBucketConfiguration={'LocationConstraint': self.bucket_region,})
                print(f"Successfully created bucket {self.bucket_name}")
            except Exception as e:
                print(f"Error creating bucket: {e}")

    def fetch_weather(self, city):
        """Fetch weather data from OpenWeather API using urllib3"""
        base_url = "http://api.openweathermap.org/data/2.5/weather"
        params = {
            "q": city,
            "appid": self.api_key,
            "units": "imperial"
        }
        
        # Construct query parameters
        url = f"{base_url}?{urllib3.request.urlencode(params)}"
        
        try:
            response = self.http.request('GET', url)
            
            # Check for HTTP errors
            if response.status != 200:
                print(f"Error fetching weather data: HTTP {response.status}")
                return None
            
            # Parse JSON response
            return json.loads(response.data.decode('utf-8'))
        except Exception as e:
            print(f"Error fetching weather data: {e}")
            return None

    def save_to_s3(self, weather_data, city):
        """Save weather data to S3 bucket"""
        if not weather_data:
            return False
            
        timestamp = datetime.now().strftime('%Y%m%d-%H%M%S')
        file_name = f"weather-data/{city}-{timestamp}.json"
        
        try:
            weather_data['timestamp'] = timestamp
            self.s3_client.put_object(
                Bucket=self.bucket_name,
                Key=file_name,
                Body=json.dumps(weather_data),
                ContentType='application/json'
            )
            print(f"Successfully saved data for {city} to S3")
            return True
        except Exception as e:
            print(f"Error saving to S3: {e}")
            return False

def lambda_handler(event, context):
    """AWS Lambda entry point"""
    dashboard = WeatherDashboard()
    
    # Create bucket if needed
    dashboard.create_bucket_if_not_exists()
    
    # List of cities to fetch weather data for
    cities = ["Austin", "Seattle", "New York", "San Diego", "Chicago"]
    
    for city in cities:
        logger.info(f"\nFetching weather for {city}...")
        weather_data = dashboard.fetch_weather(city)
        if weather_data:
            temp = weather_data['main']['temp']
            feels_like = weather_data['main']['feels_like']
            humidity = weather_data['main']['humidity']
            description = weather_data['weather'][0]['description']
            
            logger.info(f"Temperature: {temp}°F")
            logger.info(f"Feels like: {feels_like}°F")
            logger.info(f"Humidity: {humidity}%")
            logger.info(f"Conditions: {description}")
            
            # Save to S3
            success = dashboard.save_to_s3(weather_data, city)
            if success:
                logger.info(f"Weather data for {city} saved to S3!")
        else:
            logger.info(f"Failed to fetch weather data for {city}")

    return {
        "statusCode": 200,
        "body": json.dumps("Weather data processed successfully.")
    }

