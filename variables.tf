variable "subscription_id" {
  type        = string
  description = "Azure subscription id"
}

variable "tags" {
  type = map(string)

  description = "A map of tags to apply to the resources"

  default = {
    environment = "development"
    date        = "nov-2025"
    createdBy   = "Terraform"
  }
}

variable "location" {
  type        = string
  description = "The azure region to deploy"
  default = "westus3"
}

variable "environment" {
    type = string
    description = "The environment to deploy"
    default = "dev"
}

variable "project" {
    type = string
    description = "The name of the project"
    default = "rentalcars"
}

variable "admin_sql_password" {
    type = string
    description = "The password for the SQL admin user"
}

variable "synapse_admin_password" {
    type = string
    description = "The password for the Synapse admin user"
}