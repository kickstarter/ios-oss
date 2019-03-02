import Prelude
@testable import Kickstarter_Framework
@testable import Library
import XCTest

final class CreatePasswordViewControllerTests: TestCase {
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

  func testCreatePassword() {
    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(language: language) {
        let controller = CreatePasswordViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testNewPasswordTextFieldTargetActions() {
    let vc = MockCreatePasswordViewController()
    let actions = textFieldTargetActions(for: vc, row: .newPassword)

    XCTAssertEqual(vc, actions[0].target as? MockCreatePasswordViewController)
    XCTAssertTrue(sel_isEqual(actions[0].action, #selector(vc.newPasswordTextFieldChanged(_:))))
    XCTAssertEqual(vc, actions[1].target as? MockCreatePasswordViewController)
    XCTAssertTrue(sel_isEqual(actions[1].action, #selector(vc.newPasswordTextFieldDidReturn(_:))))
  }

  func testNewPasswordConfirmationTextFieldTargetActions() {
    let vc = MockCreatePasswordViewController()
    let actions = textFieldTargetActions(for: vc, row: .confirmNewPassword)

    XCTAssertEqual(vc, actions[0].target as? MockCreatePasswordViewController)
    XCTAssertTrue(sel_isEqual(actions[0].action, #selector(vc.newPasswordConfirmationTextFieldChanged(_:))))
    XCTAssertEqual(vc, actions[1].target as? MockCreatePasswordViewController)
    XCTAssertTrue(sel_isEqual(actions[1].action, #selector(vc.newPasswordConfirmationTextFieldDidReturn(_:))))
  }
}

fileprivate final class MockCreatePasswordViewController: UIViewController, CreatePasswordViewControllerType {
  @objc func newPasswordTextFieldChanged(_ sender: UITextField) { }
  @objc func newPasswordTextFieldDidReturn(_ sender: UITextField) { }
  @objc func newPasswordConfirmationTextFieldChanged(_ sender: UITextField) { }
  @objc func newPasswordConfirmationTextFieldDidReturn(_ sender: UITextField) { }
}
