# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

* App uses OOD [runtime configuration](https://github.com/OSC/ood-dashboard/wiki/Configuration-and-Branding).

## [v1.3.2] - 2017-06-29

* Replace memory graphs with moab node usage graphs

## [v1.3.1] - 2017-06-05

* Fix bug in `bin/setup` that crashes when `OOD_PORTAL` is set but not
  `OOD_SITE`

## [v1.3.0] - 2017-05-26

* Remove deprecation warnings
* Update to OodAppkit 1.0.1

## [v1.2.8] - 2017-04-21

* added a bin/setup script for easier deployment

## [v1.2.7] - 2017-01-26

* Single manifest

## [v1.2.6] - 2017-01-18

* add URI.js support

## [v1.2.5] - 2016-12-19

* properly specify category in AweSim manifest

## [v1.2.4] - 2016-12-16

* added separate manifests for both AweSim and OSC OnDemand portals, so that when this app is deployed to OSC OnDemand the app does not disappear from the navbar

## [v1.2.3] - 2016-12-16

* Update app category

## [v1.2.2] - 2016-12-16

* update AweSim dashboard title
* change VERSION to APP_VERSION to avoid conflicts

## [v1.2.1] - 2016-11-15

* Auto update visible graphs every 5 seconds

## [v1.2.0] - 2016-10-27

* Update to Rails 4.2.7.1
* Add version
* Graphical improvements

## [v1.2.0.awesim] - 2016-10-13

* Configured for AweSim on OOD

[Unreleased]: https://github.com/AweSim-OSC/osc-systemstatus/compare/v1.3.2...HEAD
[v1.3.2]: https://github.com/AweSim-OSC/osc-systemstatus/compare/v1.3.1...v1.3.2
[v1.3.1]: https://github.com/AweSim-OSC/osc-systemstatus/compare/v1.3.1...v1.3.2
[v1.3.0]: https://github.com/AweSim-OSC/osc-systemstatus/compare/v1.3.1...v1.3.2
[v1.2.8]: https://github.com/AweSim-OSC/osc-systemstatus/compare/v1.3.1...v1.3.2
[v1.2.7]: https://github.com/AweSim-OSC/osc-systemstatus/compare/v1.3.1...v1.3.2
[v1.2.6]: https://github.com/AweSim-OSC/osc-systemstatus/compare/v1.3.1...v1.3.2
[v1.2.5]: https://github.com/AweSim-OSC/osc-systemstatus/compare/v1.3.1...v1.3.2
[v1.2.4]: https://github.com/AweSim-OSC/osc-systemstatus/compare/v1.3.1...v1.3.2
[v1.2.3]: https://github.com/AweSim-OSC/osc-systemstatus/compare/v1.3.1...v1.3.2
[v1.2.2]: https://github.com/AweSim-OSC/osc-systemstatus/compare/v1.3.1...v1.3.2
[v1.2.1]: https://github.com/AweSim-OSC/osc-systemstatus/compare/v1.3.1...v1.3.2
[v1.2.0]: https://github.com/AweSim-OSC/osc-systemstatus/compare/v1.3.1...v1.3.2
[v1.2.0.awesim]: https://github.com/AweSim-OSC/osc-systemstatus/compare/v1.0.0...v1.3.2
