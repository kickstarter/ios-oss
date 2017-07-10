import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi

internal final class BackingViewControllerTests: TestCase {
  private let cosmicSurgery = Project.cosmicSurgery
    |> Project.lens.state .~ .successful
  private let backing = Backing.template
    |> Backing.lens.pledgedAt .~ 1468527587.32843
  private let brando = User.brando |> User.lens.avatar.small .~ ""
  private let creator = .template |> User.lens.id .~ 42

  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testCurrentUserIsBacker() {
    Language.allLanguages.forEach { language in
      withEnvironment(apiService: MockService(fetchBackingResponse: self.backing), currentUser: self.brando,
      language: language) {
        let controller = BackingViewController.configuredWith(project: self.cosmicSurgery, backer: nil)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testCurrentUserIsBacker_Backing_Canceled() {
    let backingCanceled = self.backing |> Backing.lens.status .~ .canceled

    Language.allLanguages.forEach { language in
      withEnvironment(apiService: MockService(fetchBackingResponse: backingCanceled),
                      currentUser: self.brando,
                      language: language) {
                        let controller = BackingViewController.configuredWith(project: self.cosmicSurgery,
                                                                              backer: nil)
                        let (parent, _) = traitControllers(device: .phone4_7inch,
                                                           orientation: .portrait,
                                                           child: controller)

                        self.scheduler.run()

                        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testCurrentUserIsBacker_Backing_Collected() {
    let backingCollected = self.backing |> Backing.lens.status .~ .collected

    Language.allLanguages.forEach { language in
      withEnvironment(apiService: MockService(fetchBackingResponse: backingCollected),
                      currentUser: self.brando,
                      language: language) {
                        let controller = BackingViewController.configuredWith(project: self.cosmicSurgery,
                                                                              backer: nil)
                        let (parent, _) = traitControllers(device: .phone4_7inch,
                                                           orientation: .portrait,
                                                           child: controller)

                        self.scheduler.run()

                        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testCurrentUserIsBacker_Backing_Dropped() {
    let backingDropped = self.backing |> Backing.lens.status .~ .dropped

    Language.allLanguages.forEach { language in
      withEnvironment(apiService: MockService(fetchBackingResponse: backingDropped),
                      currentUser: self.brando,
                      language: language) {
                        let controller = BackingViewController.configuredWith(project: self.cosmicSurgery,
                                                                              backer: nil)
                        let (parent, _) = traitControllers(device: .phone4_7inch,
                                                           orientation: .portrait,
                                                           child: controller)

                        self.scheduler.run()

                        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testCurrentUserIsBacker_Backing_Errored() {
    let backingErrored = self.backing |> Backing.lens.status .~ .errored

    Language.allLanguages.forEach { language in
      withEnvironment(apiService: MockService(fetchBackingResponse: backingErrored),
                      currentUser: self.brando,
                      language: language) {
                        let controller = BackingViewController.configuredWith(project: self.cosmicSurgery,
                                                                              backer: nil)
                        let (parent, _) = traitControllers(device: .phone4_7inch,
                                                           orientation: .portrait,
                                                           child: controller)

                        self.scheduler.run()

                        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testCurrentUserIsBacker_Project_Failed() {
    let projectFailed = self.cosmicSurgery |> Project.lens.state .~ .failed

    Language.allLanguages.forEach { language in
      withEnvironment(apiService: MockService(fetchBackingResponse: self.backing),
                      currentUser: self.brando,
                      language: language) {
                        let controller = BackingViewController.configuredWith(project: projectFailed,
                                                                              backer: nil)
                        let (parent, _) = traitControllers(device: .phone4_7inch,
                                                           orientation: .portrait,
                                                           child: controller)

                        self.scheduler.run()

                        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testCurrentUserIsBacker_NoReward() {
    let reward = Reward.noReward
    let backingNoReward = self.backing |> Backing.lens.reward .~ reward

    withEnvironment(apiService: MockService(fetchBackingResponse: backingNoReward),
                    currentUser: self.brando,
                    language: .en) {
                      let controller = BackingViewController.configuredWith(project: self.cosmicSurgery,
                                                                            backer: self.brando)
                      let (parent, _) = traitControllers(device: .phone4_7inch,
                                                         orientation: .portrait,
                                                         child: controller)

                      self.scheduler.run()

                      FBSnapshotVerifyView(parent.view, identifier: "lang_en")
    }
  }

  func testCurrentUserIsCreator() {
    let project = self.cosmicSurgery
      |> Project.lens.creator .~ self.creator

    Language.allLanguages.forEach { language in
      withEnvironment(apiService: MockService(fetchBackingResponse: self.backing), currentUser: self.creator,
      language: language) {
        let controller = BackingViewController.configuredWith(project: project, backer: .template)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)

         self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testCurrentUserIsCreator_Backing_Canceled() {
    let backingCanceled = self.backing |> Backing.lens.status .~ .canceled

    Language.allLanguages.forEach { language in
      withEnvironment(apiService: MockService(fetchBackingResponse: backingCanceled),
                      currentUser: self.creator,
                      language: language) {
                        let controller = BackingViewController.configuredWith(project: self.cosmicSurgery,
                                                                              backer: .template)
                        let (parent, _) = traitControllers(device: .phone4_7inch,
                                                           orientation: .portrait,
                                                           child: controller)

                        self.scheduler.run()

                        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testCurrentUserIsCreator_Backing_Collected() {
    let backingCollected = self.backing |> Backing.lens.status .~ .collected

    Language.allLanguages.forEach { language in
      withEnvironment(apiService: MockService(fetchBackingResponse: backingCollected),
                      currentUser: self.creator,
                      language: language) {
                        let controller = BackingViewController.configuredWith(project: self.cosmicSurgery,
                                                                              backer: .template)
                        let (parent, _) = traitControllers(device: .phone4_7inch,
                                                           orientation: .portrait,
                                                           child: controller)

                        self.scheduler.run()

                        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testCurrentUserIsCreator_Backing_Dropped() {
    let backingDropped = self.backing |> Backing.lens.status .~ .dropped

    Language.allLanguages.forEach { language in
      withEnvironment(apiService: MockService(fetchBackingResponse: backingDropped),
                      currentUser: self.creator,
                      language: language) {
                        let controller = BackingViewController.configuredWith(project: self.cosmicSurgery,
                                                                              backer: .template)
                        let (parent, _) = traitControllers(device: .phone4_7inch,
                                                           orientation: .portrait,
                                                           child: controller)

                        self.scheduler.run()

                        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testCurrentUserIsCreator_Backing_Errored() {
    let backingErrored = self.backing |> Backing.lens.status .~ .errored

    Language.allLanguages.forEach { language in
      withEnvironment(apiService: MockService(fetchBackingResponse: backingErrored),
                      currentUser: self.creator,
                      language: language) {
                        let controller = BackingViewController.configuredWith(project: self.cosmicSurgery,
                                                                              backer: .template)
                        let (parent, _) = traitControllers(device: .phone4_7inch,
                                                           orientation: .portrait,
                                                           child: controller)

                        self.scheduler.run()

                        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testCurrentUserIsCreator_Project_Failed() {
    let projectFailed = self.cosmicSurgery |> Project.lens.state .~ .failed

    Language.allLanguages.forEach { language in
      withEnvironment(apiService: MockService(fetchBackingResponse: self.backing),
                      currentUser: self.creator,
                      language: language) {
                        let controller = BackingViewController.configuredWith(project: projectFailed,
                                                                              backer: .template)
                        let (parent, _) = traitControllers(device: .phone4_7inch,
                                                           orientation: .portrait,
                                                           child: controller)

                        self.scheduler.run()

                        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }
}
