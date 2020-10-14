# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# dev/agency/microservice-rds
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
}
# --------------------------------------------------------
# get state of dev/agency/vpc
# --------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    region = var.region
    key    = "${var.env}/agency/vpc/terraform.tfstate"
    bucket = "faas-dev-terraform-state"
  }
}

locals {
  vpc_id                      = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnets              = data.terraform_remote_state.vpc.outputs.public_subnets
  private_subnets             = data.terraform_remote_state.vpc.outputs.database_subnets
  private_subnets_cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnets_cidr_blocks
  database_subnets            = data.terraform_remote_state.vpc.outputs.database_subnets
}

output "private_subnets" {
  value = local.private_subnets
}

# --------------------------------------------------------
# setup Agency microservice-rds postgres master/replica
# --------------------------------------------------------

/*
 security group for Agency Postgres
*/
resource "aws_security_group" "agencyPostgres-sg" {
  name        = "agencyPostgres-sg"
  description = "Allow ssh from bastion and TLS over 5432"
  vpc_id      = local.vpc_id

  ingress {
    description = "TLS from VPC private subnets"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = local.private_subnets_cidr_blocks
  }
  ingress {
    description = "TLS from LBs PC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["73.39.184.79/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_TLS"
  }
}

####################################
# Variables common to both instanceces
####################################
locals {
  engine            = "postgres"
  engine_version    = "9.6.9"
  instance_class    = "db.t2.large"
  allocated_storage = 5
  port              = "5432"
}

##############################################################
# Data sources to get VPC, subnets and security group details
##############################################################
# data "aws_vpc" "default" {
#   default = true
# }

# data "aws_subnet_ids" "all" {
#   vpc_id = data.aws_vpc.default.id
# }

# data "aws_security_group" "default" {
#   vpc_id = data.aws_vpc.default.id
#   name   = "default"
# }

###########
# Master DB
###########
module "master" {
  #source = "../../"
  source             = "terraform-aws-modules/rds/aws"
  ca_cert_identifier = "rds-ca-2017"

  identifier = "agency-master-postgres"

  engine            = local.engine
  engine_version    = local.engine_version
  instance_class    = local.instance_class
  allocated_storage = local.allocated_storage

  name     = "agencypostgres"
  username = var.db_username
  password = var.db_password
  port     = local.port

  #vpc_security_group_ids = [data.aws_security_group.default.id]
  vpc_security_group_ids = [aws_security_group.agencyPostgres-sg.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Backups are required in order to create a replica
  backup_retention_period = 1

  # DB subnet group
  #subnet_ids = data.aws_subnet_ids.all.ids
  subnet_ids = local.database_subnets

  create_db_option_group    = false
  create_db_parameter_group = false
}

############
# Replica DB
############
module "replica" {
  #source = "../../"
  source             = "terraform-aws-modules/rds/aws"
  ca_cert_identifier = "rds-ca-2017"

  identifier = "agency-replica-postgres"

  # Source database. For cross-region use this_db_instance_arn
  replicate_source_db = module.master.this_db_instance_id

  engine            = local.engine
  engine_version    = local.engine_version
  instance_class    = local.instance_class
  allocated_storage = local.allocated_storage

  # Username and password must not be set for replicas
  username = ""
  password = ""
  port     = local.port

  #vpc_security_group_ids = [data.aws_security_group.default.id]
  vpc_security_group_ids = [aws_security_group.agencyPostgres-sg.id]

  maintenance_window = "Tue:00:00-Tue:03:00"
  backup_window      = "03:00-06:00"

  # disable backups to create DB faster
  backup_retention_period = 0

  # Not allowed to specify a subnet group for replicas in the same region
  create_db_subnet_group = false

  create_db_option_group    = false
  create_db_parameter_group = false
}
