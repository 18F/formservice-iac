# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# variables for dev/agency/microservice-rds
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

variable "region" {
  type    = string
  default = "us-gov-west-1"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}