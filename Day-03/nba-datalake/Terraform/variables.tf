variable "NBA_API_KEY" {
  type = string
  description = "API Key for Provider"
  sensitive = true
  validation {
    condition = length(var.NBA_API_KEY) > 0
    error_message = "The SportsDataIO API Key must be a non-empty string."
  }
}

variable "NBA_ENDPOINT_URL" {
  type = string
  description = "URL for NBA data Access"
  sensitive = true
  validation {
    condition = length(var.NBA_ENDPOINT_URL) > 0
    error_message = "The endpoint URL must be a non-empty string."
  }
}
