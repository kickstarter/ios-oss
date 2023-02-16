@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import SnapshotTesting
import UIKit

class PaymentMethodsViewControllerTests: TestCase {
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

  func testView_WithCreditCards() {
    let graphUser = GraphUser.template |> \.storedCards .~ .template
    let response = UserEnvelope<GraphUser>(me: graphUser)

    self.generateSnapshots(with: response, name: "non-empty")
  }

  func testView_NoCreditCards() {
    let graphUser = GraphUser.template |> \.storedCards .~ .emptyTemplate
    let response = UserEnvelope<GraphUser>(me: graphUser)

    self.generateSnapshots(with: response, name: "empty")
  }

  private func generateSnapshots(with response: UserEnvelope<GraphUser>, name: String) {
    combos(Language.allLanguages, Device.allCases).forEach {
      arg in
      let controller = PaymentMethodsViewController.instantiate()
      let (language, device) = arg
      withEnvironment(
        apiService: MockService(fetchGraphUserResult: .success(response)),
        apiDelayInterval: .seconds(0),
        language: language,
        userDefaults: MockKeyValueStore()
      ) {
        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: controller
        )

        parent.view.layoutIfNeeded()

        self.scheduler.advance()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "\(name)_lang_\(language)_device_\(device)"
        )
      }
    }
  }
}
