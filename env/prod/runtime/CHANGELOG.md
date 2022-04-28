# Changelog
All notable changes to this project will be documented in this file. Changes to the dev and test environment are documented in the **Unreleased** section; changes to the prod environment are documented with the updated version and date the change was deployed.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.3]
### Changed
- 2022-04-28 FORMS-778 deployed formio-enterprise:7.3.2 to runtime-submission-epa prod

### Changed
- 2022-04-28 FORMS-778 deployed ami-0968bfb2bef6a026e to prod
- 2022-04-26 FORMS-776 deployed ami-0968bfb2bef6a026e to test
- 2022-04-21 FORMS-748 deployed ami-0968bfb2bef6a026e to dev

## [1.0.2] - 2022-04-07
### Changed
- 2022-04-07 FORMS-696 deployed ami-03a0f325a864730cb to prod
- 2022-04-05 FORMS-691 deployed ami-03a0f325a864730cb to test
- 2022-04-01 FORMS-687 deployed ami-03a0f325a864730cb to dev

## [1.0.1] - 2022-03-31
### Changed
- 2022-03-31 FORMS-619 deployed nginx:1.21.6-alpine to prod
- 2022-03-31 FORMS-619 deployed submission-server:9.0.33 to prod
- 2022-03-29 FORMS-617 deployed nginx:1.21.6-alpine to test
- 2022-03-29 FORMS-617 deployed submission-server:9.0.33 to test
- 2022-03-24 FORMS-617 deployed nginx:1.21.6-alpine to dev
- 2022-03-24 FORMS-617 deployed submission-server:9.0.33 to dev

## [1.0.0] - 2022-03-24
### Added
- 2022-03-24 FORMS-522 deployed CIS docker controls cis-5.12, cis-5.25 to prod
- 2022-03-22 FORMS-558 deployed CIS docker controls cis-5.12, cis-5.25 to test
- 2022-03-17 FORMS-562 deployed CIS docker controls cis-5.12, cis-5.25 to dev

### Changed
- 2022-03-24 FORMS-613 deployed ami-08f23b677a6ee3765 to prod
- 2022-03-22 FORMS-612 deployed ami-08f23b677a6ee3765 to test
- 2022-03-17 FORMS-611 deployed ami-08f23b677a6ee3765 to dev
- ami-08f23b677a6ee3765 configures/enables selinux on the docker daemon on the host machine
