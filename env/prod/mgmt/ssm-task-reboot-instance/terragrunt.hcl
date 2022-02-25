locals {
  # Automatically load environment-level variables
  account_vars      = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars  = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  account_num       = local.account_vars.locals.aws_account_id
  env               = local.environment_vars.locals.environment
}

// specify module source
terraform {
  source = "git@github.com-gsa:18F/formservice-iac-modules.git//maintenance-window-task"
}

// include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

// depends on maintenance window
dependency "ssm-window-hourly" {
  config_path = "../ssm-window-hourly"
}

// depends on maintenance window target
dependency "ssm-target-ecs-hourly" {
  config_path = "../ssm-target-ecs-hourly"
}

// depends on iam role
dependency "acct-security" {
  config_path = "../security"
}

// pass variables into module
inputs = {
  account_num               = "${local.account_num}"
  env                       = "${local.env}"
  // maintenance window task: update ecs agent
  max_concurrency           = 1
  max_errors                = 1
  priority                  = 1
  task_arn                  = "AWS-RunShellScript"
  task_type                 = "RUN_COMMAND"
  window_id                 = dependency.ssm-window-hourly.outputs.id
  target_type               = "WindowTargetIds"
  target_ids                = [dependency.ssm-target-ecs-hourly.outputs.id]
  timeout_seconds           = 600
  cloudwatch_output_enabled = true
  commands                  = [
    "if [[ \"$(sudo service docker status)\" == *\"dead\"* ]] ; then aws sns publish --topic-arn arn:aws-us-gov:sns:us-gov-west-1:${local.account_num}:Forms-Service-Issue-Alert --message 'The docker daemon is dead on ec2 instance $(curl -s http://169.254.169.254/latest/meta-data/instance-id) in the $( curl -s http://169.254.169.254/latest/meta-data/public-keys | sed 's/-.*//; s/.*=//') environment. AWS Systems Manager is rebooting the instance now. This message and reboot command was triggered by an AWS Systems Manager maintenance window task.' && sudo reboot ; fi"
  ]
  // attach iam policy to iam role
  iam_role                  = dependency.acct-security.outputs.beanstalk_ec2_role_name
  iam_policy_name           = "AllowPublishToTopicSSMTaskRebootInstance"
  iam_policy_document       = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sns:Publish",
            "Resource": "arn:aws-us-gov:sns:us-gov-west-1:${local.account_num}:Forms-Service-Issue-Alert"
        }
    ]
}
EOF
}
