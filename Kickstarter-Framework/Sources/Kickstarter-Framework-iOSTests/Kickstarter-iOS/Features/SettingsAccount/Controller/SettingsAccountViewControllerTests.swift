@testable import Kickstarter_Framework
@testable import KsApi
@testable import KsApiTestHelpers
import Library
@testable import LibraryTestHelpers
import Prelude
import SnapshotTesting
import XCTest

internal final class SettingsAccountViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView() {
    let user = GraphUser.template

    let response = UserEnvelope<GraphUser>(me: user)
    let mockService = MockService(fetchGraphUserResult: .success(response))

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad])
      .forEach { language, device in
        withEnvironment(apiService: mockService, language: language) {
          let vc = SettingsAccountViewController.instantiate()
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)

          self.scheduler.run()

          assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
        }
      }
  }

  func testAccountView_FetchUserAccountFieldsFailure() {
    Device.allCases.forEach { device in
      withEnvironment(apiService: MockService(fetchGraphUserResult: .failure(.couldNotParseJSON))) {
        let vc = SettingsAccountViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)

        self.scheduler.run()

        assertSnapshot(matching: parent.view, as: .image, named: "device_\(device)")
      }
    }
  }
}
