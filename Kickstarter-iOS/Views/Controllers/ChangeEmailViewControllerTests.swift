@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class ChangeEmailViewControllerTests: TestCase {
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

  func testChangeEmail() {
    let userTemplate = GraphUser.template |> \.isEmailVerified .~ true
    let userEnvelope = UserEnvelope(me: userTemplate)
    let service = MockService(fetchGraphUserResult: .success(userEnvelope))

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(apiService: service, currentUser: User.template, language: language) {
        let controller = ChangeEmailViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        scheduler.advance()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testChangeEmailScreen_unverifiedEmail() {
    let userTemplate = GraphUser.template |> \.isEmailVerified .~ false
    let userEnvelope = UserEnvelope(me: userTemplate)
    let service = MockService(fetchGraphUserResult: .success(userEnvelope))
    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(apiService: service, currentUser: User.template, language: language) {
        let controller = ChangeEmailViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        scheduler.advance()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testChangeEmailScreen_unverifiedEmail_isCreator() {
    let creator = User.template
      |> \.stats.createdProjectsCount .~ 3
    let userTemplate = GraphUser.template |> \.isEmailVerified .~ false
    let userEnvelope = UserEnvelope(me: userTemplate)
    let service = MockService(fetchGraphUserResult: .success(userEnvelope))

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(
        apiService: service,
        currentUser: creator,
        language: language
      ) {
        let controller = ChangeEmailViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        scheduler.advance()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testChangeEmailScreen_undeliverableEmail() {
    let userTemplate = GraphUser.template
      |> \.isEmailVerified .~ false
      |> \.isDeliverable .~ false
    let userEnvelope = UserEnvelope(me: userTemplate)
    let service = MockService(fetchGraphUserResult: .success(userEnvelope))
    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(apiService: service, currentUser: User.template, language: language) {
        let controller = ChangeEmailViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        scheduler.advance()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testMessageBannerContainerIsSetToHiddenByDefault() {
    let controller = ChangeEmailViewController.instantiate()
    controller.beginAppearanceTransition(true, animated: false)
    controller.endAppearanceTransition()

    let messageBannerViewController = controller.children
      .compactMap { $0 as? MessageBannerViewController }.first

    guard let view = messageBannerViewController?.view else {
      XCTFail("View should be created")
      return
    }

    XCTAssertTrue(view.isHidden)
  }
}
