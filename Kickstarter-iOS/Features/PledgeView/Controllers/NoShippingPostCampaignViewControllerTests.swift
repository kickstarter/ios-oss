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
    let response = UserEnvelope<GraphUser>(me: self.userWithCards)
    let mockService = MockService(fetchGraphUserResult: .success(response))
    let project = Project.template
      |> \.availableCardTypes .~ [CreditCardType.discover.rawValue]
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.noShippingAtCheckout.rawValue: true
    ]

    orthogonalCombos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        currentUser: User.template,
        language: language,
        remoteConfigClient: mockConfigClient
      ) {
        let controller = NoShippingPostCampaignCheckoutViewController.instantiate()

        let shippingRule = ShippingRule.template
          |> ShippingRule.lens.estimatedMin .~ Money(amount: 5.0)
          |> ShippingRule.lens.estimatedMax .~ Money(amount: 10.0)
        let reward = Reward.template
          |> Reward.lens.shipping.enabled .~ true
          |> Reward.lens.shippingRules .~ [shippingRule]
        let data = PostCampaignCheckoutData(
          project: project,
          baseReward: reward,
          rewards: [reward],
          selectedQuantities: [:],
          bonusAmount: 0,
          total: 5,
          shipping: nil,
          refTag: nil,
          context: .pledge,
          checkoutId: "0",
          backingId: "backingId",
          selectedShippingRule: .template
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

  func testView_PledgeContext_FixPaymentMethod_ErroredCard() {
    let response = UserEnvelope<GraphUser>(me: self.userWithCards)
    let mockService = MockService(fetchGraphUserResult: .success(response))
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
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.noShippingAtCheckout.rawValue: true
    ]

    orthogonalCombos([Language.en], [Device.phone4_7inch]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        currentUser: User.template,
        language: language,
        remoteConfigClient: mockConfigClient
      ) {
        let controller = NoShippingPostCampaignCheckoutViewController.instantiate()
        let reward = Reward.noReward
        let data = PostCampaignCheckoutData(
          project: project,
          baseReward: reward,
          rewards: [reward],
          selectedQuantities: [:],
          bonusAmount: 0,
          total: 5,
          shipping: nil,
          refTag: nil,
          context: .pledge,
          checkoutId: "0",
          backingId: "backingId",
          selectedShippingRule: .template
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 800

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

  func testView_ShowsShippingSummaryViewSection() {
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
    let reward = Reward.template
      |> (Reward.lens.shipping .. Reward.Shipping.lens.enabled) .~ true
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.noShippingAtCheckout.rawValue: true
    ]

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.pad])
      .forEach { language, device in
        withEnvironment(language: language, remoteConfigClient: mockConfigClient) {
          let controller = NoShippingPostCampaignCheckoutViewController.instantiate()
          let data = PostCampaignCheckoutData(
            project: project,
            baseReward: reward,
            rewards: [reward],
            selectedQuantities: [:],
            bonusAmount: 0,
            total: 5,
            shipping: nil,
            refTag: nil,
            context: .pledge,
            checkoutId: "0",
            backingId: "backingId",
            selectedShippingRule: .template
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
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRules .~ [shippingRule]
      |> Reward.lens.id .~ 99
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.noShippingAtCheckout.rawValue: true
    ]

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.pad])
      .forEach { language, device in
        withEnvironment(language: language, remoteConfigClient: mockConfigClient) {
          let controller = NoShippingPostCampaignCheckoutViewController.instantiate()
          let data = PostCampaignCheckoutData(
            project: project,
            baseReward: reward,
            rewards: [reward],
            selectedQuantities: [:],
            bonusAmount: 0,
            total: 5,
            shipping: nil,
            refTag: nil,
            context: .pledge,
            checkoutId: "0",
            backingId: "backingId",
            selectedShippingRule: .template
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

  func testView_HasAddOns() {
    let project = Project.template
    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.estimatedMin .~ Money(amount: 5.0)
      |> ShippingRule.lens.estimatedMax .~ Money(amount: 10.0)
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRules .~ [shippingRule]
      |> Reward.lens.id .~ 99

    let data = PostCampaignCheckoutData(
      project: project,
      baseReward: reward,
      rewards: [reward],
      selectedQuantities: [:],
      bonusAmount: 0,
      total: 5,
      shipping: nil,
      refTag: nil,
      context: .pledge,
      checkoutId: "0",
      backingId: "backingId",
      selectedShippingRule: .template
    )
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.noShippingAtCheckout.rawValue: true
    ]

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.pad])
      .forEach { language, device in
        withEnvironment(language: language, remoteConfigClient: mockConfigClient) {
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
