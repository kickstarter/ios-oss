import Prelude
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import XCTest

final class ChangePasswordViewControllerTests: TestCase {
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

  func testChangePassword() {
    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(language: language) {
        let controller = ChangePasswordViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testMessageBannerContainerIsHiddenByDefault() {
    let controller = ChangePasswordViewController.instantiate()
    controller.beginAppearanceTransition(true, animated: false)
    controller.endAppearanceTransition()

    let messageBannerViewController = controller.children
      .compactMap { $0 as? MessageBannerViewController }.first

    guard let containerView = messageBannerViewController?.view.superview else {
      XCTFail("View should be created")
      return
    }

    XCTAssertTrue(containerView.isHidden)
  }

  func testMessageBannerContainerIsHiddenIsSetProperly() {
    let controller = ChangePasswordViewController.instantiate()
    _ = controller.view

    let messageBannerViewController = controller.children
      .compactMap { $0 as? MessageBannerViewController }.first

    guard let containerView = messageBannerViewController?.view.superview else {
      XCTFail("View should be created")
      return
    }

    controller.messageBannerViewControllerIsHidden(true)

    XCTAssertTrue(containerView.isHidden)

    controller.messageBannerViewControllerIsHidden(false)

    XCTAssertFalse(containerView.isHidden)
  }
}
