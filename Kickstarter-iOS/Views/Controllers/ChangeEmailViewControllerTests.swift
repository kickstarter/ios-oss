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
    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(currentUser: User.template, language: language) {
        let controller = ChangeEmailViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        scheduler.advance()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testChangeEmailScreen_unverifiedEmail() {
    let userEmailFields = UserEmailFields.template |> \.isEmailVerified .~ false
    let service = MockService(fetchGraphUserEmailFieldsResponse: userEmailFields)
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
    let userEmailFields = UserEmailFields.template |> \.isEmailVerified .~ false

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(
        apiService: MockService(fetchGraphUserEmailFieldsResponse: userEmailFields),
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
    let userEmailFields = UserEmailFields.template |> \.isEmailVerified .~ false |> \.isDeliverable .~ false
    let service = MockService(fetchGraphUserEmailFieldsResponse: userEmailFields)
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
