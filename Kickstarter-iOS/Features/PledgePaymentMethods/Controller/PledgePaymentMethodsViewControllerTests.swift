@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import SnapshotTesting
import UIKit

final class PledgePaymentMethodsViewControllerTests: TestCase {
  private let userWithCards = GraphUser.template |> \.storedCards .~ UserCreditCards(
    storedCards: [
      UserCreditCards.visa,
      UserCreditCards.masterCard
    ]
  )

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

  func testView_PledgeContext_AddNewCardNonLoadingState_Success() {
    let response = UserEnvelope<GraphUser>(me: self.userWithCards)
    let envelope = ClientSecretEnvelope(clientSecret: "test")
    let mockService = MockService(
      createStripeSetupIntentResult: .success(envelope),
      fetchGraphUserResult: .success(response)
    )
    let project = Project.template
      |> \.availableCardTypes .~ [CreditCardType.visa.rawValue, CreditCardType.mastercard.rawValue]

    combos(Language.allLanguages, [Device.pad, Device.phone4_7inch]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        currentUser: User.template,
        language: language
      ) {
        let controller = PledgePaymentMethodsViewController.instantiate()

        let reward = Reward.template
        let data = PledgePaymentMethodsValue(
          user: .template,
          project: project,
          reward: reward,
          context: .pledge,
          refTag: nil,
          pledgeTotal: Double.nan,
          paymentSheetType: .setupIntent
        )

        controller.configure(with: data)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 400

        self.scheduler.advance(by: .seconds(1))

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_PledgeContext_AddNewCardLoadingState_Success() {
    let response = UserEnvelope<GraphUser>(me: self.userWithCards)
    /// Using .failure case to prevent real Stripe sheet from being shown.
    let mockService = MockService(
      createStripeSetupIntentResult: .failure(.couldNotParseJSON),
      fetchGraphUserResult: .success(response)
    )
    let project = Project.template
      |> \.availableCardTypes .~ [CreditCardType.visa.rawValue, CreditCardType.mastercard.rawValue]

    combos(Language.allLanguages, [Device.pad, Device.phone4_7inch]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        currentUser: User.template,
        language: language
      ) {
        let controller = PledgePaymentMethodsViewController.instantiate()

        let reward = Reward.template
        let data = PledgePaymentMethodsValue(
          user: .template,
          project: project,
          reward: reward,
          context: .pledge,
          refTag: nil,
          pledgeTotal: Double.nan,
          paymentSheetType: .setupIntent
        )

        controller.configure(with: data)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 400

        self.scheduler.advance(by: .seconds(1))

        controller.cancelModalPresentation(false)

        self.scheduler.advance(by: .seconds(1))

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }
}
