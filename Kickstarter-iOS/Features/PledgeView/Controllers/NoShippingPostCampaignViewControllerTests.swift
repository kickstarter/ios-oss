@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import SnapshotTesting
import UIKit

final class NoShippingPostCampaignViewControllerTests: TestCase {
  private let userWithCards = GraphUser.template |> \.storedCards .~ UserCreditCards(
    storedCards: [
      UserCreditCards.visa,
      UserCreditCards.masterCard
    ]
  )

  private let userWithoutCards = GraphUser.template |> \.storedCards .~ UserCreditCards(
    storedCards: []
  )

  private let checkoutResponse = CreateCheckoutEnvelope(
    checkout: CreateCheckoutEnvelope.Checkout(id: "19", paymentUrl: "fake", backingId: "93")
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

  func testView_PledgeContext_UnavailableStoredCards() {
    let userResponse = UserEnvelope<GraphUser>(me: self.userWithCards)
    let mockService = MockService(
      createCheckoutResult: .success(self.checkoutResponse),
      fetchGraphUserResult: .success(userResponse)
    )
    let project = Project.template
      |> \.availableCardTypes .~ [CreditCardType.discover.rawValue]

    orthogonalCombos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        currentUser: User.template,
        language: language
      ) {
        let controller = NoShippingPostCampaignCheckoutViewController.instantiate()

        let shippingRule = ShippingRule.template
          |> ShippingRule.lens.estimatedMin .~ Money(amount: 0.0)
          |> ShippingRule.lens.estimatedMax .~ Money(amount: 0.0)
        let reward = Reward.template
          |> Reward.lens.shipping.enabled .~ true
          |> Reward.lens.shippingRules .~ [shippingRule]
        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          bonusSupport: 0,
          selectedShippingRule: shippingRule,
          selectedQuantities: [reward.id: 1],
          selectedLocationId: nil,
          refTag: nil,
          context: .latePledge
        )
        controller.configure(with: data)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_200

        self.scheduler.advance(by: .seconds(1))

        self.allowLayoutPass()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_ShowsEstimatedShippingView() {
    let project = Project.template
      |> Project.lens.state .~ .successful
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.visa
          |> Backing.lens.status .~ .errored
          |> Backing.lens.reward .~ Reward.noReward
          |> Backing.lens.rewardId .~ Reward.noReward.id
          |> Backing.lens.amount .~ 695.0
          |> Backing.lens.bonusAmount .~ 695.0
          |> Backing.lens.shippingAmount .~ 0
      )
    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.estimatedMin .~ Money(amount: 5.0)
      |> ShippingRule.lens.estimatedMax .~ Money(amount: 10.0)
      |> ShippingRule.lens.cost .~ 0.0
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]
      |> Reward.lens.id .~ 99

    let userResponse = UserEnvelope<GraphUser>(me: self.userWithoutCards)
    let mockService = MockService(
      createCheckoutResult: .success(self.checkoutResponse),
      fetchGraphUserResult: .success(userResponse)
    )

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.pad])
      .forEach { language, device in
        withEnvironment(
          apiService: mockService,
          currentUser: User.template,
          language: language
        ) {
          let controller = NoShippingPostCampaignCheckoutViewController.instantiate()
          let data = PledgeViewData(
            project: project,
            rewards: [reward],
            bonusSupport: 0,
            selectedShippingRule: shippingRule,
            selectedQuantities: [reward.id: 1],
            selectedLocationId: nil,
            refTag: nil,
            context: .latePledge
          )
          controller.configure(with: data)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          self.scheduler.advance(by: .seconds(1))

          self.allowLayoutPass()

          assertSnapshot(
            matching: parent.view,
            as: .image(perceptualPrecision: 0.98),
            named: "lang_\(language)_device_\(device)"
          )
        }
      }
  }

  func testView_AddOns_LoggedOut() {
    let project = Project.template

    let reward = Reward.template
      |> Reward.lens.id .~ 9
      |> Reward.lens.hasAddOns .~ true
    let addOn1 = Reward.template
      |> Reward.lens.id .~ 1
    let addOn2 = Reward.template
      |> Reward.lens.id .~ 12

    let data = PledgeViewData(
      project: project,
      rewards: [reward, addOn1, addOn2],
      bonusSupport: 0,
      selectedShippingRule: nil,
      selectedQuantities: [reward.id: 1, addOn1.id: 2, addOn2.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .latePledge
    )

    let mockService = MockService(createCheckoutResult: .success(self.checkoutResponse))

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.pad])
      .forEach { language, device in
        withEnvironment(
          apiService: mockService,
          language: language
        ) {
          let controller = NoShippingPostCampaignCheckoutViewController.instantiate()
          controller.configure(with: data)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          self.scheduler.advance(by: .seconds(1))

          self.allowLayoutPass()

          assertSnapshot(
            matching: parent.view,
            as: .image(perceptualPrecision: 0.98),
            named: "lang_\(language)_device_\(device)"
          )
        }
      }
  }
}
