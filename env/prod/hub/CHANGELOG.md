# Changelog
All notable changes to this project will be documented in this file. Changes to the dev and test environment are documented in the **Unreleased** section; changes to the prod environment are documented with the updated version and date the change was deployed.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- 2022-03-17 deployed CIS docker controls cis-5.12, cis-5.25 to dev

### Changed
- 2022-03-17 deployed ami-08f23b677a6ee3765 to dev
  - this ami configures/enables selinux on the docker daemon on the host machine

## [1.0.0] - 2022-03-10
### Changed
- deployed formio-enterprise:7.3.1 to prod
- deployed pdf-server:3.3.1 to prod
