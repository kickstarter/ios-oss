# Kickstarter for iOS

[![Circle CI](https://circleci.com/gh/kickstarter/ios-oss.svg?style=svg)](https://circleci.com/gh/kickstarter/ios-oss)

Welcome to Kickstarter’s open source iOS app! Come on in, take your shoes off,
stay a while—explore how Kickstarter’s native squad has built and continues to
build the app.

We've also open sourced our [Android app](https://github.com/kickstarter/android-oss),
and read more about our journey to open source [here TODO LINK]().

## Getting Started

1. [Download](https://developer.apple.com/xcode/download/) the newest Xcode
release.
1. Clone this repository.
1. Run `make bootstrap` to install tools.
1. Run `make dependencies` to install library dependencies.
1. Run `make test-all` to build and run tests on all platforms.

## Deploying

Beta and iTunes deployments happen by pushing to the remote `beta-dist` and
`itunes-dist` branches respectively, which triggers CircleCI to create ipa and
dsym files and upload them to the appropriate service. This process can be done
with a `make` command:

* `make deploy`: deploy `master` to beta users
* `BRANCH=feature make deploy`: deploy `feature` branch to beta users
* `RELEASE=itunes make deploy`: deploy `master` to iTunes connect

## Dependencies

We make heavy use of the following projects, and so it can be helpful to be
familiar with them:

### 1st party

* [![Circle CI](https://circleci.com/gh/kickstarter/Kickstarter-Prelude.svg?style=svg)](https://circleci.com/gh/kickstarter/Kickstarter-Prelude)
[Prelude](https://github.com/kickstarter/Kickstarter-Prelude): Foundation of
types and functions we feel are missing from the Swift standard library.
* [![CircleCI](https://circleci.com/gh/kickstarter/ios-ksapi.svg?style=svg)](https://circleci.com/gh/kickstarter/ios-ksapi)
[KsApi](https://github.com/kickstarter/ios-ksapi): Models and reactive
networking layer for fetching data from Kickstarter's API.
* [![Circle CI](https://circleci.com/gh/kickstarter/Kickstarter-ReactiveExtensions.svg?style=svg&)](https://circleci.com/gh/kickstarter/Kickstarter-ReactiveExtensions)
[ReactiveExtensions](https://github.com/kickstarter/Kickstarter-ReactiveExtensions):
A collection of operators we like to add to ReactiveCocoa.

### 3rd party

* [AlamofireImage](https://github.com/Alamofire/AlamofireImage)
* [Argo](https://github.com/thoughtbot/Argo)
* [FBSnapshotTestCase](https://github.com/facebook/ios-snapshot-test-case)
* [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)

## Contributing

We intend for this project to be an educational resource: we are excited to
share our wins, mistakes, and methodology of iOS development as we work
in the open. Our primary focus is to continue improving the app for our users in
line with our roadmap.

The best way to submit feedback and report bugs is to open a Github issue.
Please be sure to include your operating system, device, version number, and
steps to reproduce reported bugs. Keep in mind that all participants will be
expected to follow our code of conduct.

## Code of Conduct

We aim to share our knowledge and findings as we work daily to improve our
product, for our community, in a safe and open space. We work as we live, as
kind and considerate human beings who learn and grow from giving and receiving
positive, constructive feedback. We reserve the right to delete or ban any
behavior violating this base foundation of respect.

## Documentation

While we're at it, why not share our docs? Check out the
[native docs](https://github.com/kickstarter/native-docs) we have written so far
for more documentation.

## License

Copyright Kickstarter, [PBC](https://www.kickstarter.com/charter).

Kickstarter for iOS is released under the [Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
