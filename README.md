# TTS Forms Service (FS) Infrastructure as Code

## Platform Description
Forms Service is a shared platform-as-a-service web product built and maintained by the Technology Transformation Services (TTS) Center of Excellence of the US General Services Administration (GSA). The product enables various federal agencies to create digital, sign-able forms as mandated by the 21st Century Integrated Digital Experience Act (21st Century IDEA). The platform offers the following self-service applications:

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

## Infrastructure Deployment
This section describes how to deploy the cloud infrastructure that runs the Forms Service application.

### Set up your local environment
1. Install the following dependencies
    - git
    - aws-cli
    - terraform
    - terragrunt
1. Configure local aws credentials
    - `aws configure`
      - https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html
1. Clone this repository
    - `git clone git@github.com:18F/formservice-iac.git`
1. Review and set the project-specific variables in the following files:
    - `env/env.hcl`
    - `env/provider.tf`
    - `env/region.hcl`
    - `env/terragrunt.hcl`
1. Review and set the AWS account locals in the following files:
    - `env/dev/account.hcl`
    - `env/dev/env.hcl`
    - `env/test/account.hcl`
    - `env/test/env.hcl`
    - `env/prod/account.hcl`
    - `env/prod/env.hcl`

### Deploy new images to the existing cloud infrastructure in Forms Service v1.2
This section describes how to deploy the latest image to Fargate Elastic Container Service (ECS) in Forms Service v1.2.

1. Update the appropriate image tag in the following file `env/<environment>/hub/formio/tenants/<tenant>/service/terragrunt.hcl`
    ```
    inputs = {
      enterprise_image = "306811362825.dkr.ecr.us-gov-west-1.amazonaws.com/formio/enterprise:7.3.2"
    }
    ```
1. Commit and push the update to the github repository
      - `git add env/<environment>/hub/formio/tenants/<tenant>/service/terragrunt.hcl`
      - `git commit -m "<Commit message>"`
      - `git push`
1. Connect to the mgmt-server via AWS Session Manager
1. Pull the update from github to the repository on the mgmt-server
      - `cd ~/terraform/formservice-iac/`
      - `git pull`
1. Navigate to the appropriate directory: `~/terraform/formservice-iac/env/<environment>/hub/formio/tenants/<tenant>/service`
1. Export the appropriate TERRAGRUNT_IAM_ROLE
1. Run `terragrunt plan`
1. Review the plan output
    1. Verify the plan output matches the expected changes
    1. Match the Jira ticket, the Google Calendar Invite, and the terragrunt plan output together - all of the following details should match:
        - Date and time of deployment
        - Target environment
        - Image version
1. Log in to the AWS Console to review the infrastructure before starting the deployment
    1. Navigate to `AWS Console > EC2 > Target Groups`
        - Select the relevant target group
            - `faas-<environment>-hub-<tenant>-formio-tg`
        - Click the **Targets** tab
        - Before running `terragrunt apply`, we expect there to be two healthy registered targets for the target group
    1. In another tab, navigate to `AWS Console > ECS > Clusters`
    1. Click on the appropriate cluster
        - `faas-<environment>-hub-formio-ecs-cluster`
    1. Click on the appropriate service
        - `faas-<environment>-hub-<tenant>-formio-service`
    1. Click on the **Tasks** tab
        - Before running `terragrunt apply`, we expect there to be at least two running tasks for the service
1. Run `terragrunt apply` if the output of the plan matches the expected changes
    - When working with terragrunt/terraform, review the output of `terragrunt apply` before approving the apply with `yes`
1. Verify the deployment completes successfully
    1. Navigate to `AWS Console > EC2 > Target Groups`
        - After running `terragrunt apply`, we expect there to be two healthy registered targets for the target group and another two registered targets will begin provisioning
        - Eventually, we expect the original two healthy registered targets to drain and traffic will be routed to the two new healthy registered targets
    1. In another tab, navigate to `AWS Console > ECS > Clusters`
    1. Click on the appropriate cluster
        - `faas-<environment>-hub-formio-ecs-cluster`
    1. Click on the appropriate service
        - `faas-<environment>-hub-<tenant>-formio-service`
    1. Click on the **Tasks** tab
        - After running `terragrunt apply`, we expect there to be at least ***four*** running tasks for the service
        - Eventually, we expect the original two running tasks to be marked for termination
1. Run smoke tests on the application

### Deploy bastion host mgmt-server
We use an EC2 instance as a bastion host for miscellaneous management of the cloud infrastructure.

#### Deploy Prisma Cloud Defender on mgmt-server
1. Log in to [Prisma Cloud](https://app.gov.prismacloud.io)
1. Decommission the existing defender on the previous mgmt-server
    1. Navigate to `Compute > Manage > Defenders > Manage`
    1. Select the `...` on the defender
    1. Click **Decommission**
1. Deploy a new Prisma Cloud container defender to the new mgmt-server
    1. Navigate to `Compute > Manage > Defenders > Deploy > Defenders`
    1. Select `Single Defender` on step 1
    1. Select `Container Defender - Linux` on step 6
    1. Copy the curl script on step 8
    1. Paste the curl script in a terminal on the newly deployed mgmt-server to install a new Prisma Cloud container defender
    1. Verify the new defender is running
        1. Navigate to `Compute > Manage > Defenders > Manage tab > Defenders tab`
        1. Verify the ip address of the newly deployed mgmt-server is listed on this page
            - the defender type should be **Container Defender - Linux**
            - we can see more details on the defender by clicking the `...` under the **Actions** column
1. Configure the new Prisma Cloud container defender to scan our AWS Elastic Container Registry
    1. Navigate to `Compute > Defend > Vulnerabilities > Images > Registry Settings`
    1. Under the **Registries** heading, select the `...` for the Amazon EC2 Container Registry, then click **Edit**
        - this is where we tell Prisma the details of our AWS Elastic Container Registry
    1. Select the `ECR Scanner` next to **Scanners scope**
    1. Click the pencil icon to edit the **ECR Scanner**
    1. In the **Hosts** dropdown, select the ip address of the the new mgmt-server
    1. Verify the Prisma Cloud container defender is scanning our Elastic Container Registry
        1. Navigate to `Compute > Vulnerabilities > Images tab > Registries tab`
        1. Click **Scan** to scan our Elastic Container Registry for vulnerabilities

## Certificates
We manage three categories of certificates: domain-validated TLS certificates, container TLS certificates, and database certificates

### Replace domain-validated TLS certificates
We encrypt our domains with TLS certificates verified by DigitCert, and purchased/managed by GSA

### Replace container TLS certificates
For each task in ECS, we have three running containers:
  - a container running an nginx-proxy
  - a container running the service (either an api-server for each tenant or the pdf-server)
  - a container running TwistlockDefender, our security vulnerability scanning software

We use self-signed container TLS certificates to encrypt traffic between the nginx-proxy container and the respective service container (each tenant api-server or pdf-server), and the nginx-proxy and the Application Load Balancer (ALB). The nginx-proxy container pulls the certificate and private key from Elastic File System (EFS); the service container pulls the certificate and private key from AWS Secrets Manager.

1. Generate a Certificate Signing Request (CSR) and private key for each environment: dev, test, prod
    1. Connect to the prod-mgmt-server and navigate to the `/home/ssm-user/certs/container/` directory
        - this directory is backed up to s3 on an hourly basis
    1. Run the following command to generate the CSR and private key for each environment: dev, test, and prod
        - `openssl req -new -newkey rsa:4096 -nodes -out <YYYYMMDD>_<domain>.csr -keyout <YYYYMMDD>_<domain>.key -subj "/C=US/ST=District of Columbia/L=Washington/O=GSA/CN=<domain>"`
        - for container certificates, use the following domains for each environment:
            - dev.local
                - `openssl req -new -newkey rsa:4096 -nodes -out 20220629_dev_local.csr -keyout 20220629_dev_local.key -subj "/C=US/ST=District of Columbia/L=Washington/O=GSA/CN=dev.local"`
            - test.local
                - `openssl req -new -newkey rsa:4096 -nodes -out 20220629_test_local.csr -keyout 20220629_test_local.key -subj "/C=US/ST=District of Columbia/L=Washington/O=GSA/CN=test.local"`
            - prod.local
                - `openssl req -new -newkey rsa:4096 -nodes -out 20220629_prod_local.csr -keyout 20220629_prod_local.key -subj "/C=US/ST=District of Columbia/L=Washington/O=GSA/CN=prod.local"`
1. Create a self-signed certificate using the newly generated CSR and private key
    1. Run the following command to create a self-signed certificate for each environment: dev, test, prod
        - `openssl x509 -signkey <YYYYMMDD>_<domain>.key -in <YYYYMMDD>_<domain>.csr -req -days 365 -out <YYYYMMDD>_<domain>.crt`
        - dev.local
            - `openssl x509 -signkey 20220629_dev_local.key -in 20220629_dev_local.csr -req -days 365 -out 20220629_dev_local.crt`
        - test.local
            - `openssl x509 -signkey 20220629_test_local.key -in 20220629_test_local.csr -req -days 365 -out 20220629_test_local.crt`
        - prod.local
            - `openssl x509 -signkey 20220629_prod_local.key -in 20220629_prod_local.csr -req -days 365 -out 20220629_prod_local.crt`
1. Upload the artifacts to s3
      - we should now have a CSR, a private key, and a certificate for each environment in the `/home/ssm-user/certs/container/` directory:
        ```
        20220629_dev_local.crt
        20220629_dev_local.csr
        20220629_dev_local.key
        20220629_prod_local.crt
        20220629_prod_local.csr
        20220629_prod_local.key
        20220629_test_local.crt
        20220629_test_local.csr
        20220629_test_local.key
        ```
      - the directory `/home/ssm-user/certs/` on the `prod-mgmt-server` is backed up to `s3://faas-prod-mgmt-bucket` on an hourly basis
1. Enter the private key and certificate into AWS Secrets Manager in each AWS environment (dev, test, prod); each service container (each tenant api-server or the pdf-server) pulls the certificate and private key from AWS Secrets Manager
    1. Navigate to `AWS Secrets Manager > Secrets` in the AWS Console
        - there are secrets for each service (each tenant api-server and the pdf-server)
        - repeat the following steps for each service
    1. Click on the secret for the appropriate service
    1. Click **Retrieve secret value** to display the secrets
    1. Click **Edit** to edit the secrets
    1. Click the **Plaintext** tab to edit the secrets in a minified json format
    1. Replace the secret values of the `SSL_KEY` and `SSL_CERT`
        - each secret value needs to be on one line, not in originally generated multiline format
        - in a text editor, replace all invisible new lines with the newline character (`\n`)
    1. Click the **Save** button
    1. Stop the container task in ECS; when the api-server/pdf-server containers start up, they should pull the newly generated certificate and private key from Secrets Manager
1. Replace the certificates on the Elastic File System (EFS) mount in each environment: dev, test, prod
    1. Copy the newly generated certificate and private key to the appropriate EFS mount; the following commands copy the dev certificate and the dev private key from s3 to the dev Elastic File System, which is mounted to the dev-mgmt-server
        ```
        aws s3 cp --recursive --region us-gov-west-1 s3://faas-prod-mgmt-bucket/mgmt-server/certs/container/20220629_dev_local.crt /mnt/efs/nginx/certs/

        aws s3 cp --recursive --region us-gov-west-1  s3://faas-prod-mgmt-bucket/mgmt-server/certs/container/20220629_dev_local.key /mnt/efs/nginx/certs/
        ```
    1. Update the nginx configuration for the api-server and pdf-server to use the newly generated certificate and private key
        - `vi /mnt/efs/nginx/api-conf/default.conf`
        ```
        server {
          listen 8443 ssl;
          ssl_certificate      /src/certs/20220629_dev_local.crt;
          ssl_certificate_key  /src/certs/20220629_dev_local.key;
        ```
    1. Stop the container task in ECS; when the nginx-proxy containers start up, they should pull the newly generated certificate and private key from the respective Elastic File System

### Replace database certificates
AWS replaces their service-level database certificates every several years for miscellaneous purposes. A notice with instructions will be sent to the following email distribution list several months before action is required: forms-devops@gsa.gov

## AWS Systems Manager (SSM)
We use [AWS Systems Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/what-is-systems-manager.html) (formerly known as *Amazon Simple Systems Manager (SSM)*) to run automated tasks on ec2 instances.

We keep our SSM tasks in the `mgmt` directory for each environment. The following is a summary of the current state of Systems Manager in the `prod` environment:
```
ssm-window-hourly
│ a maintenance window that runs every hour, on the hour
│
└───ssm-target-mgmt-server-hourly
    │  a maintenance window target that targets the mgmt-server
    │  
    └───ssm-task-backup-mgmt-server
          a maintenance window task that backs up faas-prod-mgmt-server files to s3; FORMS-531

ssm-window-thurs-7am-et
│ a maintenance window that runs Thursdays at 7am ET
│  
└───ssm-target-mgmt-server-thurs-7am-et
    │  a maintenance window target that targets the mgmt-server
    │
    └───ssm-task-run-patch-baseline
          a maintenance window task that applies the default baseline to patch instances, then reboots the instances; FORMS-859

```
test
