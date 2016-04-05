# Kickstarter for iOS and tvOS

[![Circle CI](https://circleci.com/gh/kickstarter/kickstarter-tv.svg?style=svg&circle-token=2b61f76d12b127455820924f347fd9e6697da9dc)](https://circleci.com/gh/kickstarter/kickstarter-tv)

## Getting Started

1. [Download](https://developer.apple.com/xcode/download/) the newest Xcode release.
1. Clone this repository.
1. Run `make dependencies` to install dependencies.
1. Run `make test-all` to build and run tests on all platforms.

## Deploying

Beta and iTunes deployments happen by pushing to the remote `beta-dist` and `itunes-dist` branches respectively, which triggers CircleCI to create ipa and dsym files and upload them to the appropriate service. This process can be done with a `make` command:

* `make deploy`: deploy `master` to beta users
* `BRANCH=feature make deploy`: deploy `feature` branch to beta users
* `RELEASE=itunes make deploy`: deploy `master` to iTunes connect

## Related projects

We make heavy use of the following projects, and so it can be helpful to be familiar with them:

* [Prelude](https://github.com/kickstarter/Kickstarter-Prelude)
* [Models](https://github.com/kickstarter/Kickstarter-Models)
* [KsApi](https://github.com/kickstarter/Kickstarter-KsApi)
* [ReactiveExtensions](https://github.com/kickstarter/Kickstarter-ReactiveExtensions)
