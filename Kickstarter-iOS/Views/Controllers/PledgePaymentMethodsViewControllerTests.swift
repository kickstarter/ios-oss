@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import UIKit

final class PledgePaymentMethodsViewControllerTests: TestCase {
  private let userWithCards = GraphUser.template |> \.storedCards .~ UserCreditCards(
    storedCards: [
      UserCreditCards.visa,
      UserCreditCards.masterCard
    ]
  )

  // FIXME: Cannot as of yet test Stripe payment sheet UI through "Add payment method" or the selection and display of `PledgePaymentSheetPaymentMethodCell`'s as all that is hidden behing the payment sheet. The current SPM Stripe framework (22.6.0) is not working when linked into our testing framework. Refer to `AddNewCardViewControllerTests` for more info.

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

  func testView_PledgeContext_HasNonPaymentSheetPaymentMethods_SelectedCard_WhenConfigured_Success() {
    let response = UserEnvelope<GraphUser>(me: self.userWithCards)
    let mockService = MockService(fetchGraphUserResult: .success(response))
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.paymentSheetEnabled.rawValue: false
      ]

    combos(Language.allLanguages, [Device.pad, Device.phone5_8inch]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        currentUser: User.template,
        language: language,
        optimizelyClient: mockOptimizelyClient
      ) {
        let controller = PledgePaymentMethodsViewController.instantiate()

        let data = PledgePaymentMethodsValue(
          user: .template,
          project: .template,
          reward: .template,
          context: .pledge,
          refTag: nil
        )
        controller.configure(with: data)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 400

        self.scheduler.advance(by: .seconds(1))

        self.allowLayoutPass()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
