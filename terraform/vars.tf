variable "app_name" {
  description = "The name of the app, resources will be tagged using this name"
}

# Define variable for RDS password to avoid hardcoding secrets
variable "secret_key" {
  description = "The Secret Key for Django"
  type        = string
  sensitive   = true
}

####
# database vars
####
variable "db_username" {
  description = "The username for the RDS database."
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

variable "db_identifier" {
  description = "The identifier for the RDS database."
}

####
# s3 static hosting vars
####

variable "ecr_app_name" {
  description = "The name of the ecr"
}