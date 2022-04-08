# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  subenv      = local.environment_vars.locals.subenv
  name_prefix = "${local.project}-${local.env}-${local.subenv}"

  #set VPC CIDR
  CIDR = "10.130.0.0/16"
}

## DEPENDENCIES - No current dependencies for this module


## MODULE
terraform {
  source = "git::https://github.com/18F/formservice-iac-modules.git//egress-vpc"
}

## MAIN
inputs = {
  name_prefix = "${local.name_prefix}-vpc"
  vpc_cidr = local.CIDR
  single_nat_gateway = false # set to false for one NAT gateway per subnet
  environment = local.env
  project = local.project

  name             = "${local.name_prefix}-vpc"
  cidr             = local.CIDR
  public_subnets   = [
    cidrsubnet(local.CIDR, 8, 1), # "10.20.0.0/16" becomes ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
    cidrsubnet(local.CIDR, 8, 2),
    cidrsubnet(local.CIDR, 8, 3)
  ]
  private_subnets   = [
    cidrsubnet(local.CIDR, 8, 11),
    cidrsubnet(local.CIDR, 8, 12),
    cidrsubnet(local.CIDR, 8, 13)
  ]
  inspection_subnets   = [
    cidrsubnet(local.CIDR, 8, 21),
    cidrsubnet(local.CIDR, 8, 22),
    cidrsubnet(local.CIDR, 8, 23)
  ]
  ###################################################
  # Cloudwatch log group and IAM role will be created
  ###################################################
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 600

  vpc_flow_log_tags = { Name = "${local.name_prefix}-vpc-flow-logs-cloudwatch" }

  manage_default_route_table = true
  default_route_table_tags   = { DefaultRouteTable = true }
  map_public_ip_on_launch = false

  # Default security group - ingress/egress rules cleared to deny all
  #manage_default_security_group  = true
  #default_security_group_ingress = []
  #default_security_group_egress  = []

  ###################
  # public subnets
  ###################
  public_acl_tags         = { Name = "$localr.name_prefix}-public-acl" }
  public_subnet_tags      = { Name = "${local.name_prefix}-public" }
  public_route_table_tags = { Name = "${local.name_prefix}-public-rt" }
  ###################
  # private subnets
  ###################
  private_dedicated_network_acl = true
  private_acl_tags              = { Name = "${local.name_prefix}-private-acl" }
  private_subnet_tags           = { Name = "${local.name_prefix}-private" }
  private_route_table_tags      = { Name = "${local.name_prefix}-private-rt" }
  ###################
  # inspection subnets
  ###################
  inspection_dedicated_network_acl = true
  inspection_acl_tags              = { Name = "${local.name_prefix}-inspection-acl" }
  inspection_subnet_tags           = { Name = "${local.name_prefix}-inspection" }
  inspection_route_table_tags      = { Name = "${local.name_prefix}-inspection-rt" }

  # dns
  enable_dns_support   = true
  enable_dns_hostnames = true

  # nat
  enable_nat_gateway = true
  single_nat_gateway = false


}
