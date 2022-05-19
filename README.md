# formservice-iac

## Platform Description

Forms.gov is a shared platform-as-a-service web product built and maintained by the Technology Transformation Services (TTS) Center of Excellence of the US General Services Administration (GSA). The product enables various federal agencies to create digital, sign-able forms as mandated by the 21st Century Integrated Digital Experience Act (21st Century IDEA). The platform offers the following self-service applications:

- developer portal for form development and api management
    - hosted in the test environment
    - domain: portal-test.forms.gov
- form manager portal to design forms and access form submission data
    - enables agencies to create signable forms using a GUI interface
        - after forms are created they are exposed via JSON API
        - a consuming public facing web application embeds the form using this API which allows customers sign and fill in documents
    - hosted in the prod environment
    - domain: portal.forms.gov
- electronic signature portal for agency staff to securely send ad-hoc documents for signature


## AWS Systems Manager (SSM)
We use [AWS Systems Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/what-is-systems-manager.html) (formerly known as *Amazon Simple Systems Manager (SSM)*) to run automated tasks on the ec2 instances that host the running formio containers.

We keep our SSM tasks in the `mgmt` directory for each environment. The following is a summary of the current state of Systems Manager in the `prod` environment:
```
ssm-window-hourly
│ a maintenance window that runs every hour, on the hour
│
└───ssm-target-ecs-hourly
│   │ a maintenance window target that targets all ec2 instances running formio applications
│   │
│   └───ssm-task-reboot-if-docker-dead
│         a maintenance window task that reboots the instance if the docker daemon is dead; FORMS-462
│
└───ssm-target-mgmt-server
│   │  a maintenance window target that targets the mgmt-server
│   │  
│   └───ssm-task-backup-mgmt-server
│         a maintenance window task that backs up faas-prod-mgmt-server files to s3; FORMS-531
│
└───ssm-target-runtime-submission-epa-hourly
    │  a maintenance window target that targets runtime-submission-epa instances
    │
    └───ssm-task-backup-docker-logs
          a maintenance window task that backs up runtime-submission-epa docker logs to s3; FORMS-820

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
