@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import UIKit

final class PledgeViewControllerTests: TestCase {
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

  func testView_PledgeContext_UnavailableStoredCards_OptimizelyExperiementVariant1Enabled() {
    let response = UserEnvelope<GraphUser>(me: self.userWithCards)
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments
      .~ [
        OptimizelyExperiment.Key.nativeRiskMessaging.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]
    let mockService = MockService(fetchGraphUserResult: .success(response))
    let project = Project.template
      |> \.availableCardTypes .~ [CreditCardType.discover.rawValue]

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        currentUser: User.template,
        language: language,
        optimizelyClient: mockOptimizelyClient
      ) {
        let controller = PledgeViewController.instantiate()

        let reward = Reward.template
        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          selectedQuantities: [reward.id: 1],
          selectedLocationId: nil,
          refTag: nil,
          context: .pledge
        )
        controller.configure(with: data)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_200

        self.scheduler.advance(by: .seconds(1))

        self.allowLayoutPass()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_PledgeContext_UnavailableStoredCards() {
    let response = UserEnvelope<GraphUser>(me: self.userWithCards)
    let mockService = MockService(fetchGraphUserResult: .success(response))
    let project = Project.template
      |> \.availableCardTypes .~ [CreditCardType.discover.rawValue]

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(apiService: mockService, currentUser: User.template, language: language) {
        let controller = PledgeViewController.instantiate()

        let reward = Reward.template
        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          selectedQuantities: [reward.id: 1],
          selectedLocationId: nil,
          refTag: nil,
          context: .pledge
        )
        controller.configure(with: data)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_200

        self.scheduler.advance(by: .seconds(1))

        self.allowLayoutPass()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
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

    combos([Language.en], [Device.phone4_7inch]).forEach { language, device in
      withEnvironment(apiService: mockService, currentUser: User.template, language: language) {
        let controller = PledgeViewController.instantiate()
        let reward = Reward.noReward
        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          selectedQuantities: [reward.id: 1],
          selectedLocationId: nil,
          refTag: nil,
          context: .pledge
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 800

        self.scheduler.advance(by: .seconds(1))

        self.allowLayoutPass()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_PledgeContext_NeedsConversion_IsFalse() {
    let response = UserEnvelope<GraphUser>(me: self.userWithCards)
    let mockService = MockService(fetchGraphUserResult: .success(response))
    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad], [nil, User.template])
      .forEach { language, device, currentUser in
        withEnvironment(apiService: mockService, currentUser: currentUser, language: language) {
          let controller = PledgeViewController.instantiate()
          let reward = Reward.template
          let project = Project.template
          let data = PledgeViewData(
            project: project,
            rewards: [reward],
            selectedQuantities: [reward.id: 1],
            selectedLocationId: nil,
            refTag: nil,
            context: .pledge
          )
          controller.configure(with: data)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          self.scheduler.advance(by: .seconds(1))

          let loggedIn = currentUser != nil
          let loggedInString = loggedIn ? "LoggedIn" : "LoggedOut"
          if loggedIn { parent.view.frame.size.height = 1_200 }

          self.allowLayoutPass()

          FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)_\(loggedInString)")
        }
      }
  }

  func testView_PledgeContext_NeedsConversion_IsTrue() {
    let response = UserEnvelope<GraphUser>(me: self.userWithCards)
    let mockService = MockService(fetchGraphUserResult: .success(response))
    let reward = Reward.template
      |> Reward.lens.minimum .~ 10.0

    let project = Project.template
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.visa
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 0
          |> Backing.lens.amount .~ 10.0
      )
      |> Project.lens.stats.currentCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ .some(2.0)

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad], [nil, User.template])
      .forEach { language, device, currentUser in
        withEnvironment(apiService: mockService, currentUser: currentUser, language: language) {
          let controller = PledgeViewController.instantiate()
          let data = PledgeViewData(
            project: project,
            rewards: [reward],
            selectedQuantities: [reward.id: 1],
            selectedLocationId: nil,
            refTag: nil,
            context: .pledge
          )
          controller.configure(with: data)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          self.scheduler.advance(by: .seconds(1))

          let loggedIn = currentUser != nil
          let loggedInString = loggedIn ? "LoggedIn" : "LoggedOut"
          if loggedIn { parent.view.frame.size.height = 1_200 }

          self.allowLayoutPass()

          FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)_\(loggedInString)")
        }
      }
  }

  func testView_UpdateContext_NeedsConversion_IsFalse() {
    let reward = Reward.template
      |> Reward.lens.minimum .~ 10.0
      |> (Reward.lens.shipping .. Reward.Shipping.lens.enabled) .~ true

    let project = Project.template
      |> Project.lens.stats.currency .~ Currency.USD.rawValue
      |> Project.lens.stats.currentCurrency .~ Currency.USD.rawValue
      |> Project.lens.country .~ .us
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.visa
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 0
          |> Backing.lens.amount .~ 10.0
      )

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(currentUser: .template, language: language) {
        let controller = PledgeViewController.instantiate()
        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          selectedQuantities: [reward.id: 1],
          selectedLocationId: nil,
          refTag: nil,
          context: .update
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.advance(by: .seconds(1))

        self.allowLayoutPass()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_UpdateContext_NeedsConversion_IsFalse_OptimizelyExperimentVariant1Enabled() {
    let reward = Reward.template
      |> Reward.lens.minimum .~ 10.0
      |> (Reward.lens.shipping .. Reward.Shipping.lens.enabled) .~ true
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments
      .~ [
        OptimizelyExperiment.Key.nativeRiskMessaging.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]
    let project = Project.template
      |> Project.lens.stats.currency .~ Currency.USD.rawValue
      |> Project.lens.stats.currentCurrency .~ Currency.USD.rawValue
      |> Project.lens.country .~ .us
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.visa
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 0
          |> Backing.lens.amount .~ 10.0
      )

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(currentUser: .template, language: language, optimizelyClient: mockOptimizelyClient) {
        let controller = PledgeViewController.instantiate()
        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          selectedQuantities: [reward.id: 1],
          selectedLocationId: nil,
          refTag: nil,
          context: .update
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.advance(by: .seconds(1))

        self.allowLayoutPass()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_UpdateContext_withConversionLabel() {
    let reward = Reward.template
      |> Reward.lens.minimum .~ 10.0
      |> (Reward.lens.shipping .. Reward.Shipping.lens.enabled) .~ true
    let project = Project.template
      |> Project.lens.stats.currency .~ Currency.HKD.rawValue
      |> Project.lens.stats.currentCurrency .~ Currency.USD.rawValue
      |> Project.lens.country .~ .hk
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.visa
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 0
          |> Backing.lens.amount .~ 10.0
      )

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(currentUser: .template, language: language) {
        let controller = PledgeViewController.instantiate()
        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          selectedQuantities: [reward.id: 1],
          selectedLocationId: nil,
          refTag: nil,
          context: .update
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.advance(by: .seconds(1))

        self.allowLayoutPass()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_UpdateContext_withRewardIsLocalPickup() {
    let reward = Reward.template
      |> Reward.lens.shipping.preference .~ .local
      |> Reward.lens.localPickup .~ .losAngeles
    let project = Project.template
      |> Project.lens.stats.currency .~ Currency.HKD.rawValue
      |> Project.lens.stats.currentCurrency .~ Currency.USD.rawValue
      |> Project.lens.country .~ .hk
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.visa
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 0
          |> Backing.lens.amount .~ 10.0
      )

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(currentUser: .template, language: language) {
        let controller = PledgeViewController.instantiate()
        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          selectedQuantities: [reward.id: 1],
          selectedLocationId: nil,
          refTag: nil,
          context: .update
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.advance(by: .seconds(1))

        self.allowLayoutPass()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_UpdateContext_NeedsConversion_IsTrue() {
    let reward = Reward.template
      |> Reward.lens.minimum .~ 10.0
      |> (Reward.lens.shipping .. Reward.Shipping.lens.enabled) .~ true

    let project = Project.template
      |> Project.lens.stats.currentCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ .some(2.0)
      |> Project.lens.country .~ .us
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.visa
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 0
          |> Backing.lens.amount .~ 10.0
      )

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(currentUser: .template, language: language) {
        let controller = PledgeViewController.instantiate()
        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          selectedQuantities: [reward.id: 1],
          selectedLocationId: nil,
          refTag: nil,
          context: .update
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.advance(by: .seconds(1))

        self.allowLayoutPass()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_ChangePaymentMethodContext_NeedsConversion_IsTrue() {
    let response = UserEnvelope<GraphUser>(me: self.userWithCards)
    let mockService = MockService(fetchGraphUserResult: .success(response))
    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.minimum .~ 695.0

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.amex
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.bonusAmount .~ 5.0
          |> Backing.lens.shippingAmount .~ 5
          |> Backing.lens.amount .~ 700.0
      )

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(apiService: mockService, currentUser: .template, language: language) {
        let controller = PledgeViewController.instantiate()
        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          selectedQuantities: [reward.id: 1],
          selectedLocationId: nil,
          refTag: nil,
          context: .changePaymentMethod
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.advance(by: .seconds(1))

        self.allowLayoutPass()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_ChangePaymentMethodContext_NeedsConversion_IsFalse() {
    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.minimum .~ 695.0

    let project = Project.template
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.template
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 5
          |> Backing.lens.bonusAmount .~ 5.0
          |> Backing.lens.amount .~ 700.0
      )

    let response = UserEnvelope<GraphUser>(me: self.userWithCards)
    let mockService = MockService(fetchGraphUserResult: .success(response))

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(apiService: mockService, currentUser: .template, language: language) {
        let controller = PledgeViewController.instantiate()
        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          selectedQuantities: [reward.id: 1],
          selectedLocationId: nil,
          refTag: nil,
          context: .changePaymentMethod
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.advance(by: .seconds(1))

        self.allowLayoutPass()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_ChangePaymentMethodContext_UnavailableStoredCards() {
    let response = UserEnvelope<GraphUser>(me: self.userWithCards)
    let mockService = MockService(fetchGraphUserResult: .success(response))
    let project = Project.template
      |> Project.lens.personalization.backing .~ (Backing.template
        |> Backing.lens.paymentSource .~
        (.template |> \.id .~ "123")
        |> Backing.lens.shippingAmount .~ 0
        |> Backing.lens.bonusAmount .~ 2.0
        |> Backing.lens.amount .~ 12.0
      )
      |> \.availableCardTypes .~ [CreditCardType.discover.rawValue]

    let reward = Reward.template

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(apiService: mockService, currentUser: User.template, language: language) {
        let controller = PledgeViewController.instantiate()
        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          selectedQuantities: [reward.id: 1],
          selectedLocationId: nil,
          refTag: nil,
          context: .changePaymentMethod
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.advance(by: .seconds(1))

        self.allowLayoutPass()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_ShowsShippingLocationSection() {
    let reward = Reward.template
      |> (Reward.lens.shipping .. Reward.Shipping.lens.enabled) .~ true

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad], [nil, User.template])
      .forEach { language, device, currentUser in
        withEnvironment(language: language) {
          let controller = PledgeViewController.instantiate()
          let data = PledgeViewData(
            project: .template,
            rewards: [reward],
            selectedQuantities: [reward.id: 1],
            selectedLocationId: nil,
            refTag: nil,
            context: .pledge
          )
          controller.configure(with: data)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          self.scheduler.advance(by: .seconds(1))

          let loggedIn = currentUser != nil
          let loggedInString = loggedIn ? "LoggedIn" : "LoggedOut"
          if loggedIn { parent.view.frame.size.height = 1_200 }

          self.allowLayoutPass()

          FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)_\(loggedInString)")
        }
      }
  }

  func testView_ShowsShippingSummaryViewSection() {
    let reward = Reward.template
      |> (Reward.lens.shipping .. Reward.Shipping.lens.enabled) .~ true

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad], [nil, User.template])
      .forEach { language, device, currentUser in
        withEnvironment(language: language) {
          let controller = PledgeViewController.instantiate()
          let data = PledgeViewData(
            project: .template,
            rewards: [reward, .noReward],
            selectedQuantities: [reward.id: 1, Reward.noReward.id: 1],
            selectedLocationId: nil,
            refTag: nil,
            context: .pledge
          )
          controller.configure(with: data)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          self.scheduler.advance(by: .seconds(1))

          let loggedIn = currentUser != nil
          let loggedInString = loggedIn ? "LoggedIn" : "LoggedOut"
          if loggedIn { parent.view.frame.size.height = 1_200 }

          self.allowLayoutPass()

          FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)_\(loggedInString)")
        }
      }
  }

  func testView_ShowsRewardLocationSection() {
    let reward = Reward.template
      |> (Reward.lens.shipping .. Reward.Shipping.lens.enabled) .~ false
      |> (Reward.lens.shipping .. Reward.Shipping.lens.preference) .~ .local
      |> Reward.lens.localPickup .~ Location.losAngeles

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad], [nil, User.template])
      .forEach { language, device, currentUser in
        withEnvironment(language: language) {
          let controller = PledgeViewController.instantiate()
          let data = PledgeViewData(
            project: .template,
            rewards: [reward, .noReward],
            selectedQuantities: [reward.id: 1, Reward.noReward.id: 1],
            selectedLocationId: nil,
            refTag: nil,
            context: .pledge
          )
          controller.configure(with: data)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          self.scheduler.advance(by: .seconds(1))

          let loggedIn = currentUser != nil
          let loggedInString = loggedIn ? "LoggedIn" : "LoggedOut"
          if loggedIn { parent.view.frame.size.height = 1_200 }

          self.allowLayoutPass()

          FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)_\(loggedInString)")
        }
      }
  }

  func testView_HasAddOns_ShippingSelected() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.id .~ 99
    let addOnReward1 = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.id .~ 1
    let addOnReward2 = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.id .~ 2

    let data = PledgeViewData(
      project: project,
      rewards: [reward, addOnReward1, addOnReward2],
      selectedQuantities: [reward.id: 1, addOnReward1.id: 2, addOnReward2.id: 1],
      selectedLocationId: ShippingRule.template.id,
      refTag: .projectPage,
      context: .pledge
    )

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad], [nil, User.template])
      .forEach { language, device, currentUser in
        withEnvironment(language: language) {
          let controller = PledgeViewController.instantiate()
          controller.configure(with: data)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
          self.scheduler.advance(by: .seconds(1))

          let loggedIn = currentUser != nil
          let loggedInString = loggedIn ? "LoggedIn" : "LoggedOut"
          if loggedIn { parent.view.frame.size.height = 1_200 }

          self.allowLayoutPass()

          FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)_\(loggedInString)")
        }
      }
  }
}
