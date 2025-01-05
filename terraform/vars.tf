
# Define variable for RDS password to avoid hardcoding secrets
variable "secret_key" {
  description = "The Secret Key for Django"
  type        = string
  sensitive   = true
}
