@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import XCTest

internal final class SettingsAccountViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView() {
    let user = GraphUser.template
      |> \.hasPassword .~ true
      |> \.isEmailVerified .~ true

    let response = UserEnvelope<GraphUser>(me: user)
    let mockService = MockService(fetchGraphUserResult: .success(response))

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad])
      .forEach { language, device in
        withEnvironment(apiService: mockService, language: language) {
          let vc = SettingsAccountViewController.instantiate()
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)

          self.scheduler.run()

          FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
        }
      }
  }

  func testAccountView_EmailPasswordSectionHidden() {
    let user = GraphUser.template
      |> \.hasPassword .~ false

    let response = UserEnvelope<GraphUser>(me: user)
    let mockService = MockService(fetchGraphUserResult: .success(response))

    Device.allCases.forEach { device in

      withEnvironment(apiService: mockService) {
        let vc = SettingsAccountViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "device_\(device)")
      }
    }
  }

  func testAccountView_WhenUserEmailIsUnverified() {
    Device.allCases.forEach { device in
      let fields = GraphUser.template
        |> \.isEmailVerified .~ false
      let response = UserEnvelope(me: fields)

      withEnvironment(apiService: MockService(fetchGraphUserResult: .success(response))) {
        let vc = SettingsAccountViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "device_\(device)")
      }
    }
  }

  func testAccountView_FetchUserAccountFieldsFailure() {
    Device.allCases.forEach { device in
      withEnvironment(apiService: MockService(fetchGraphUserResult: .failure(.couldNotParseJSON))) {
        let vc = SettingsAccountViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "device_\(device)")
      }
    }
  }
}
