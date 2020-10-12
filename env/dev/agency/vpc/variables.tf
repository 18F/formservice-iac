# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# variables for dev/agency/vpc
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
variable "region" {
  type    = string
  default = "us-gov-west-1"
}

variable "env" {
  type    = string
  default = "dev"
}

# ---------------------------------------------------------
# network
# ---------------------------------------------------------

variable "azs" {
  type    = list(string)
  default = ["us-gov-west-1a", "us-gov-west-1b"]
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.20.11.0/24", "10.20.12.0/24"]
}

variable "database_subnets" {
  type    = list(string)
  default = ["10.20.21.0/24", "10.20.22.0/24"]
}