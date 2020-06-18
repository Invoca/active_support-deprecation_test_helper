# CHANGELOG for `activesupport-deprecation_test_helper`

Inspired by [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

Note: this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.2] - 2020-06-18
### Fixed
- RSpec configuration bug where after(:suite) callback was unable to execute successfully

## [0.1.1] - 2020-06-18
### Fixed
- RSpec configuration no longer runs multiple times during the test run

## [0.1.0] - 2020-06-18
### Added
- Added ability to configure your tests to record and report unexpected deprecation warnings
- Added support for configuration in `Minitest` and `RSpec`

[0.1.0]: https://github.com/Invoca/active_support-deprecation_warning_helper/tree/v0.1.0
