# Kickstarter for iOS and tvOS

[![Circle CI](https://circleci.com/gh/kickstarter/kickstarter-tv.svg?style=svg&circle-token=2b61f76d12b127455820924f347fd9e6697da9dc)](https://circleci.com/gh/kickstarter/kickstarter-tv)

![Kickstarter for iOS](.github/app.jpg)

## Getting Started

1. [Download](https://developer.apple.com/xcode/download/) the newest Xcode release.
1. Clone this repository.
1. Run `make bootstrap` to install tools.
1. Run `make dependencies` to install library dependencies.
1. Run `make test-all` to build and run tests on all platforms.

## Deploying

Beta and iTunes deployments happen by pushing to the remote `beta-dist` and `itunes-dist` branches respectively, which triggers CircleCI to create ipa and dsym files and upload them to the appropriate service. This process can be done with a `make` command:

* `make deploy`: deploy `master` to beta users
* `BRANCH=feature make deploy`: deploy `feature` branch to beta users
* `RELEASE=itunes make deploy`: deploy `master` to iTunes connect

## Dependencies

We make heavy use of the following projects, and so it can be helpful to be familiar with them:

### 1st party

* [![Circle CI](https://circleci.com/gh/kickstarter/Kickstarter-Prelude.svg?style=svg&circle-token=ddbeef5e5b970496ddf6d7c81d60367eee16aa32)](https://circleci.com/gh/kickstarter/Kickstarter-Prelude) [Prelude](https://github.com/kickstarter/Kickstarter-Prelude): Foundation of types and functions missing from the Swift standard library.
* [![CircleCI](https://circleci.com/gh/kickstarter/ios-ksapi.svg?style=svg)](https://circleci.com/gh/kickstarter/ios-ksapi) [KsApi](https://github.com/kickstarter/ios-ksapi): A reactive networking layer for fetching data from Kickstarter's API.
* [![Circle CI](https://circleci.com/gh/kickstarter/Kickstarter-ReactiveExtensions.svg?style=svg&circle-token=87cb6246722fd8b503516bcdcf84e64256f86470)](https://circleci.com/gh/kickstarter/Kickstarter-ReactiveExtensions) [ReactiveExtensions](https://github.com/kickstarter/Kickstarter-ReactiveExtensions): A collection of operators missing from Reactive Cocoa.

### 3rd party

* [AlamofireImage](https://github.com/Alamofire/AlamofireImage)
* [Argo](https://github.com/thoughtbot/Argo)
* [FBSnapshotTestCase](https://github.com/facebook/ios-snapshot-test-case)
* [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)
