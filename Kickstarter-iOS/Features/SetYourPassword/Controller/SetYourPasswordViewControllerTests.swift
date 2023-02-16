@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import SnapshotTesting
import XCTest

final class SetYourPasswordViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    super.tearDown()
  }

  func testSetYourPasswordViewController_DisabledSave() {
    let userTemplate = GraphUser.template |> \.isEmailVerified .~ true
    let userEnvelope = UserEnvelope(me: userTemplate)
    let service = MockService(fetchGraphUserResult: .success(userEnvelope))

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, device in
      withEnvironment(apiService: service, apiDelayInterval: .seconds(0), language: language) {
        let controller = SetYourPasswordViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }
}
