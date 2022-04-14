@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
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

    self.generateSnapshots(with: response)
  }

  func testView_NoCreditCards() {
    let graphUser = GraphUser.template |> \.storedCards .~ .emptyTemplate
    let response = UserEnvelope<GraphUser>(me: graphUser)

    self.generateSnapshots(with: response)
  }

  private func generateSnapshots(with response: UserEnvelope<GraphUser>) {
    combos(Language.allLanguages, Device.allCases).forEach {
      arg in

      let (language, device) = arg
      withEnvironment(
        apiService: MockService(fetchGraphUserResult: .success(response)),
        language: language,
        userDefaults: MockKeyValueStore()
      ) {
        let controller = PaymentMethodsViewController.instantiate()
        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: controller
        )

        parent.view.layoutIfNeeded()

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
