variable "NBA_API_KEY" {
  type = string
  description = "API Key for Provider"
  sensitive = true
  validation {
    condition = length(var.NBA_API_KEY) > 0
    error_message = "The SportsDataIO API Key must be a non-empty string."
  }
}

variable "GAMEDATA_NOTIFICATION_EMAIL"{
  type = string
  description = "Provide the email address to subscribe to the Game Data Notification Topic"
  validation {
    condition = length(var.GAMEDATA_NOTIFICATION_EMAIL) > 0
    error_message = "The email address must be a non-empty string."
  }
}
