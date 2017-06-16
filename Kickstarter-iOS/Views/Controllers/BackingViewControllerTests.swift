import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi

internal final class BackingViewControllerTests: TestCase {
  fileprivate let cosmicSurgery = Project.cosmicSurgery
    |> Project.lens.state .~ .successful
  fileprivate let backing = Backing.template
    |> Backing.lens.pledgedAt .~ 1468527587.32843
  fileprivate let brando = User.brando

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
    let project = self.cosmicSurgery
    let backer = self.brando

    Language.allLanguages.forEach { language in
      withEnvironment(apiService: MockService(fetchBackingResponse: backing), currentUser: backer,
      language: language) {
        let controller = BackingViewController.configuredWith(project: project, backer: backer)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testCurrentUserIsBacker_NoReward() {
    let project = self.cosmicSurgery
    let backer = self.brando
    let reward = Reward.noReward

    withEnvironment(apiService: MockService(fetchBackingResponse: backing |> Backing.lens.reward .~ reward),
                    currentUser: backer,
                    language: .en) {
                      let controller = BackingViewController.configuredWith(project: project, backer: backer)
                      let (parent, _) = traitControllers(device: .phone4_7inch,
                                                         orientation: .portrait,
                                                         child: controller)

                      self.scheduler.run()

                      FBSnapshotVerifyView(parent.view, identifier: "lang_en")
    }
  }

  func testCurrentUserIsCreator() {
    let creator = .template |> User.lens.id .~ 42
    let project = self.cosmicSurgery
      |> Project.lens.creator .~ creator

    Language.allLanguages.forEach { language in
      withEnvironment(apiService: MockService(fetchBackingResponse: backing), currentUser: creator,
      language: language) {
        let controller = BackingViewController.configuredWith(project: project, backer: nil)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)

         self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testCurrentUserIsCollaborator() {
    let creator = .template |> User.lens.id .~ 42
    let project = self.cosmicSurgery
      |> Project.lens.creator .~ creator
    let backer = self.brando
    let collaborator = .template |> User.lens.id .~ 99

    Language.allLanguages.forEach { language in
      withEnvironment(apiService: MockService(fetchBackingResponse: backing), currentUser: collaborator,
      language: language) {
        let controller = BackingViewController.configuredWith(project: project, backer: backer)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)

         self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }
}
