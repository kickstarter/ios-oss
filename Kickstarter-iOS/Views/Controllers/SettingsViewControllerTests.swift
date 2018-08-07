import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi

internal final class SettingsViewControllerTests: TestCase {

  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testNonCreator() {
    let currentUser = .template |> User.lens.stats.backedProjectsCount .~ 1234

    Language.allLanguages.forEach { language in
      Language.allLanguages.forEach { language in
        withEnvironment(
          apiService: MockService(fetchUserSelfResponse: currentUser),
          currentUser: currentUser,
          language: language) {

            let vc = SettingsViewController.instantiate()
            let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
            parent.view.frame.size.height = 1_600

            self.scheduler.run()

            FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)")
        }
      }
    }
  }

  func testCreator() {
    let currentUser = .template
      |> User.lens.stats.backedProjectsCount .~ 1234
      |> User.lens.stats.createdProjectsCount .~ 2

    Language.allLanguages.forEach { language in
      withEnvironment(
        apiService: MockService(fetchUserSelfResponse: currentUser),
        currentUser: currentUser,
        language: language) {

          let vc = SettingsViewController.instantiate()
          let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
          parent.view.frame.size.height = 1_600

          self.scheduler.run()

          FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)")}
      }
  }

  func testMember() {
    let currentUser = .template
      |> User.lens.stats.backedProjectsCount .~ 1234
      |> User.lens.stats.memberProjectsCount .~ 2

    Language.allLanguages.forEach { language in
      withEnvironment(
        apiService: MockService(fetchUserSelfResponse: currentUser),
        currentUser: currentUser,
        language: language) {

          let vc = SettingsViewController.instantiate()
          let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
          parent.view.frame.size.height = 1_600

          self.scheduler.run()

          FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)")
      }
    }
  }
}
