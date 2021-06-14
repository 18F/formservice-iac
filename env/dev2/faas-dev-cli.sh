#!/bin/bash

export AWS_PROFILE=faas-dev-cli

#aws eks --region us-gov-west-1 update-kubeconfig --name faas-sandb-agency01-eks
#export KUBECONFIG="~/.kube/config-faas-sandb-agency01-eks"

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

#complete -C /usr/local/bin/terraform terraform
test -e ~/.iterm2_shell_integration.bash && source ~/.iterm2_shell_integration.bash || true
export PATH=$PATH:$HOME/bin

# setup faas variables for use with terraform
#export AWS_PROFILE=tfuser-faas-dev
#export KUBECONFIG=$HOME/.kube/config-faas
# postgres
export TF_VAR_db_username=postgres
export TF_VAR_db_password=-66Post88-!
# documentDB
export TF_VAR_master_username=formio
export TF_VAR_master_password=-10Form21-!
# formio elastic beanstalk settings
export FORMIO_ADMIN_EMAIL=michael.p.jones@gsa.gov
export FORMIO_ADMIN_PASS=CHANGEME987
export FORMIO_DB_SECRET='$!--11Adr21--!'
export FORMIO_JWT_SECRET='$!--23Nhu--!!'
export FORMIO_LICENSE_KEY=VoP8ktRHTt7mqGLYNMhbq2aTxS79Wt
##############
# signrequest
##############
export STACKS_BUCKET_NAME='faas-sandb-hs-bucket'  # The S3 bucket to deploy the stack template to
# Set your AWS region to use
export AWS_REGION=us-gov-west-1
# These variables are stack specific
# The STACK_TEMPLATE shouyld reference to a stack template
# to reference the main signer application stack template defined in `infra/deploy/signer/main.py:template` do:
export STACK_TEMPLATE='infra.deploy.signer.main.template'
# Stacks can require more environment variables:
export GIT_VERSION='latest'  # Docker tag to deploy (git commit hash for production)
# for staging 1 do:
export SR_ENV='staging'   # VPC Environment (staging or production)
export SR_CLUSTER_ENV='srClusterSandb'  # Cluster Environment (dev, staging, prod .....)
export GIT_BRANCH_TO_DEPLOY='master'  # The branch from where to deploy, defaults to master.
export BASE_DOMAIN='sr-sand.appsquared.io'  # DomainName
export SR_SECRET_KEY_STORE='env-var-secrets-staging.json'
export CREATE_VPC=False
export DOCKER_REGISTRY=306881650362.dkr.ecr.us-gov-west-1.amazonaws.com
