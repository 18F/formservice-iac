# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/mgmt-hosts
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  # The latest version of Terragrunt (v0.25.1 and above) recommends Terraform 0.13.3 or above.
  required_version = ">= 0.13.3"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.7.0"
    }
  }
}

resource "aws_ebs_encryption_by_default" "enabled" {
  enabled = true
}

###############
# Bastion Linux
###############
module "ec2_linux" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">=2.19.0"

  name           = "${var.name_prefix}-terraform-ec2"
  instance_count = 1

  ami           = var.linux_ami
  instance_type = var.linux_instance_type

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.linux_bastion.id]
  key_name              = var.key_pair
  monitoring = var.linux_monitoring
  # kms_keyid = var.kms_key

  root_block_device = [
    {
      volume_size = var.linux_root_block_size
      volume_type = "gp2",
      encrypted   = true,
      kms_key_id = var.kms_key
    },
  ]

  # ebs_block_device = [
  #   {
  #     device_name           = "/dev/xvdz"
  #     volume_type           = "gp2"
  #     volume_size           = "50"
  #     delete_on_termination = true,
  #     encrypted   = true
  #   }
  # ]

  tags = {
    "Env"  = "Private"
    "Name" = "${var.name_prefix}-linux-bastion"
  }
}
