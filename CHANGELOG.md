# Changelog
All notable changes to this project will be documented in this file. Changes to the dev and test environments are documented in the **Unreleased** section; changes to the prod environment are documented with the updated version and date the change was deployed.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- 2022-05-16 FORMS-845 update api-server, pdf-server container definitions and node memory allocation to `2048` for the hub-formio app in the dev environment
- 2022-05-13 FORMS-845 upgraded ec2 instances from t3.medium to t3.large for the hub-formio app in the dev environment
  - this is to accommodate formio's recommendation on memory requirements
- 2022-05-12 FORMS-832 deployed pdf-server:3.3.8 to the hub-formio app in the dev environment
  - this image has fewer vulnerabilities than the previous version, pdf-server:3.3.6
- 2022-05-05 FORMS-798 deployed ami-0fea79bafb589ff8e to all formio instances in the dev environment
  - this ami has 6 fewer known exploited vulnerabilities than the previous ami

## [1.1.4] - 2022-05-13
### Added
- 2022-05-13 FORMS-820 deployed ssm-task-backup-docker-logs to the runtime-submission-epa app in the prod environment
    - `env/prod/mgmt/ssm-task-backup-docker-logs` is an AWS Systems Manager maintenance window task that backs up runtime-submission-epa docker logs to s3
    - `env/prod/mgmt/s3-bucket-epa-docker-logs` creates an s3 bucket to host the logfiles
    - this is a stop-gap measure to collect logs from the running containers considering we removed the awslogs log driver on 2022-05-04 due to performance issues
### Removed
- 2022-05-13 FORMS-820 removed the elastic beanstalk environment variable `DEBUG=*` to turn off debug mode in the runtime-submission-epa app in the prod environment
    - we believe this environment variable was generating significantly more docker logs, which caused the `docker logs` command to hang and cpu to spike

## [1.1.3] - 2022-05-05
### Added
- 2022-05-05 FORMS-815 deployed ssm-task-run-patch-baseline to the prod environment
- 2022-05-03 FORMS-804 deployed ssm-task-run-patch-baseline to the test environment
- 2022-04-26 FORMS-346 deployed ssm-task-run-patch-baseline to the dev environment

### Removed
- 2022-05-04 FORMS-805 removed awslogs log driver from runtime-submission-epa app in prod
- 2022-05-03 FORMS-801 removed awslogs log driver from hub-formio and runtime-submission apps in the test environment

## [1.1.2] - 2022-04-28
### Changed
- 2022-04-28 FORMS-778 deployed:
    - ami-0968bfb2bef6a026e to hub-formio and runtime-submission prod
    - formio-enterprise:7.3.2 to runtime-submission-epa prod
- 2022-04-26 FORMS-776 deployed ami-0968bfb2bef6a026e to hub-formio and runtime-submission test
- 2022-04-21 FORMS-748 deployed ami-0968bfb2bef6a026e to hub-formio and runtime-submission dev

## [1.1.1] - 2022-04-21
### Changed
- 2022-04-21 FORMS-747 deployed formio-enterprise:7.3.2 to hub-formio prod
- 2022-04-19 FORMS-738 deployed formio-enterprise:7.3.2 to hub-formio test
- 2022-04-14 FORMS-717 deployed formio-enterprise:7.3.2 to hub-formio dev

## [1.1.0] - 2022-04-14
### Removed
- 2022-04-14 FORMS-709 removed cis docker recommendation 5.12 from prod
- 2022-04-12 FORMS-708 removed cis docker recommendation 5.12 from test
- 2022-04-07 FORMS-706 removed cis docker recommendation 5.12 from dev

## [1.0.3] - 2022-04-07
### Changed
- 2022-04-07 FORMS-696 deployed:
    - ami-03a0f325a864730cb to hub-formio prod
    - pdf-server:3.3.6 to hub-formio prod
    - ami-03a0f325a864730cb to runtime-submission prod
- 2022-04-05 FORMS-691 deployed:
    - ami-03a0f325a864730cb to hub-formio test
    - pdf-server:3.3.6 to hub-formio test
    - ami-03a0f325a864730cb to runtime-submission test
- 2022-04-01 FORMS-687 deployed:
    - ami-03a0f325a864730cb to hub-formio dev
    - pdf-server:3.3.6 to hub-formio dev
    - ami-03a0f325a864730cb to runtime-submission dev

## [1.0.2] - 2022-03-31
### Changed
- 2022-03-31 FORMS-619 deployed:
    - nginx:1.21.6-alpine to hub-formio prod
    - nginx:1.21.6-alpine to runtime-submission prod
    - pdf-server:3.3.5 to hub-formio prod
    - submission-server:9.0.33 to runtime-submission prod
- 2022-03-29 FORMS-617 deployed:
    - nginx:1.21.6-alpine to hub-formio test
    - nginx:1.21.6-alpine to runtime-submission test
    - pdf-server:3.3.5 to hub-formio test
    - submission-server:9.0.33 to runtime-submission test
- 2022-03-24 FORMS-617 deployed:
    - nginx:1.21.6-alpine to hub-formio dev
    - nginx:1.21.6-alpine to runtime-submission dev
    - pdf-server:3.3.5 to hub-formio dev
    - submission-server:9.0.33 to runtime-submission dev

## [1.0.1] - 2022-03-24
### Added
- 2022-03-24 FORMS-522 deployed CIS docker controls cis-5.12, cis-5.25 to hub-formio and runtime-submission prod
- 2022-03-22 FORMS-558 deployed CIS docker controls cis-5.12, cis-5.25 to hub-formio and runtime-submission test
- 2022-03-17 FORMS-562 deployed CIS docker controls cis-5.12, cis-5.25 to hub-formio and runtime-submission dev

### Changed
- 2022-03-22 FORMS-613 deployed ami-08f23b677a6ee3765 to hub-formio and runtime-submission test
- 2022-03-22 FORMS-612 deployed ami-08f23b677a6ee3765 to hub-formio and runtime-submission test
- 2022-03-17 FORMS-611 deployed ami-08f23b677a6ee3765 to hub-formio and runtime-submission dev
- ami-08f23b677a6ee3765 configures/enables selinux on the docker daemon on the host machine

## [1.0.0] - 2022-03-10
### Changed
- 2022-03-10 FORMS-383 deployed formio-enterprise:7.3.1 to hub-formio prod
- 2022-03-10 FORMS-383 deployed pdf-server:3.3.1 to hub-formio prod
