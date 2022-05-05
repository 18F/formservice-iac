# formservice-iac

## AWS Systems Manager (SSM)
We use [AWS Systems Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/what-is-systems-manager.html) (formerly known as "Amazon Simple Systems Manager (SSM)") to run automated tasks on the ec2 instances that host the running formio containers.

We keep our SSM tasks in the `mgmt` directory for each environment. The following is a summary of the current state of Systems Manager in the `prod` environment:
```
ssm-window-hourly
│ a maintenance window that runs every hour, on the hour
│
└───ssm-target-ecs-hourly
    │ a maintenance window target that targets all ec2 instances running formio applications
    │
    └───ssm-task-reboot-if-docker-dead
          a maintenance window task that reboots the instance if the docker daemon is dead; FORMS-462

ssm-window-thurs-7am-et
│ a maintenance window that runs Thursdays at 7am ET
│  
└───ssm-target-ecs-thurs-7am-et
    │ a maintenance window target that targets all ec2 instances running formio applications
    │
    └───ssm-task-run-patch-baseline
    │     a maintenance window task that applies the default baseline to patch instances, then reboots the instances; FORMS-346
    │
    └───ssm-task-set-logfile-permissions
    │     a maintenance window task sets appropriate permissions on logfiles; FORMS-284
    │
    └───ssm-task-update-ecs-agent
          a maintenance window task that installs available updates for the ecs agent, then restarts docker and starts ecs; FORMS-142
```
