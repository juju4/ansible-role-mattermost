# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Molecule test suite - limitations docker+systemd
- Kitchen test suite (lxd based)
- Test, support Ubuntu 18.04, 20.04, Centos 8

### Changed
- Change galaxy author and dependencies with maintained modules
- Lint
- Gitignore

### Removed
- Included tasks related to nginx and postgres as relying on roles to do it and avoid conflicting tasks affecting idempotence

