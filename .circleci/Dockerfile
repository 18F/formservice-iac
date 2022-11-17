# this Dockerfile creates the base image for the CircleCI pipeline to run terragrunt apply

# steps to build this image and push to our ECR
## export appropriate aws profile/credentials
## aws ecr get-login-password --region us-gov-west-1 | docker login --username AWS --password-stdin 306811362825.dkr.ecr.us-gov-west-1.amazonaws.com
## cd formservice-iac/.circleci
## docker build -t 306811362825.dkr.ecr.us-gov-west-1.amazonaws.com/circleci/ubuntu:22.10 .
## docker push 306811362825.dkr.ecr.us-gov-west-1.amazonaws.com/circleci/ubuntu:22.10

# use ubuntu; unable to install AWS CLI v2.x.x on alpine
FROM ubuntu:22.10

# install dependencies
RUN apt update && apt install -y git wget unzip curl jq

# install terraform
RUN wget -O terraform.zip https://releases.hashicorp.com/terraform/1.2.4/terraform_1.2.4_linux_amd64.zip  \
&& unzip terraform.zip \
&& rm terraform.zip \
&& mv terraform /usr/bin/terraform \
&& chmod uo+x /usr/bin/terraform

# install terragrunt
RUN wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.40.0/terragrunt_linux_amd64 \
&& mv terragrunt_linux_amd64 /usr/bin/terragrunt \
&& chmod uo+x /usr/bin/terragrunt

# install aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
&& unzip -o awscliv2.zip \
&& ./aws/install
