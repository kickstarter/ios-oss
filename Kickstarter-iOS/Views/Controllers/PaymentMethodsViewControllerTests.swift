// swiftlint:disable force_unwrapping

import Prelude
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library

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

    let response = UserEnvelope<GraphUserCreditCard>(
      me: GraphUserCreditCard.template
    )

    self.generateSnapshots(with: response)
  }

  func testView_NoCreditCards() {

    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.emptyTemplate)

    self.generateSnapshots(with: response)
  }

  private func generateSnapshots(with response: UserEnvelope<GraphUserCreditCard>) {
    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      (arg) in

      let (language, device) = arg
      withEnvironment(apiService: MockService(fetchGraphCreditCardsResponse: response),
                      language: language,
                      userDefaults: MockKeyValueStore()) {

                        let controller = PaymentMethodsViewController.instantiate()
                        let (parent, _) = traitControllers(device: device,
                                                           orientation: .portrait,
                                                           child: controller)

                        self.scheduler.run()

                        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
