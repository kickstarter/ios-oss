import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi

internal final class SettingsAccountViewControllerTests: TestCase {

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

  func testView() {
    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad])
      .forEach { language, device in
        withEnvironment(language: language) {
            let vc = SettingsAccountViewController.instantiate()
            let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)

            self.scheduler.run()

            FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
        }
    }
  }

  func testAccountView_WhenUserEmailIsUnverified() {
    Device.allCases.forEach { device in
      let fields = UserAccountFields.template
        |> \.isEmailVerified .~ false
      let response = UserEnvelope(me: fields)

      withEnvironment(apiService: MockService(fetchGraphUserAccountFieldsResponse: response)) {
        let vc = SettingsAccountViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "device_\(device)")
      }
    }
  }

  func testAccountView_FetchUserAccountFieldsFailure() {
    Device.allCases.forEach { device in
      let error = GraphError.invalidInput

      withEnvironment(apiService: MockService(fetchGraphUserAccountFieldsError: error)) {
        let vc = SettingsAccountViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "device_\(device)")
      }
    }
  }
}
