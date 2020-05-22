@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import UIKit

final class PledgeViewControllerTests: TestCase {
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
    let userEnvelope = UserEnvelope(me: GraphUserCreditCard.withCards([
      GraphUserCreditCard.visa,
      GraphUserCreditCard.masterCard
    ]))
    let mockService = MockService(fetchGraphCreditCardsResponse: userEnvelope)
    let project = Project.template
      |> \.availableCardTypes .~ [CreditCardType.discover.rawValue]

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(apiService: mockService, currentUser: User.template, language: language) {
        let controller = PledgeViewController.instantiate()
        controller.configureWith(project: project, reward: .template, refTag: nil, context: .pledge)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_200

        self.scheduler.advance(by: .seconds(1))

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_PledgeContext_FixPaymentMethod_ErroredCard() {
    let userEnvelope = UserEnvelope(me: GraphUserCreditCard.withCards([
      GraphUserCreditCard.visa,
      GraphUserCreditCard.masterCard
    ]))
    let mockService = MockService(fetchGraphCreditCardsResponse: userEnvelope)
    let project = Project.template
      |> Project.lens.state .~ .successful
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.visa
          |> Backing.lens.status .~ .errored
          |> Backing.lens.reward .~ Reward.noReward
          |> Backing.lens.rewardId .~ Reward.noReward.id
          |> Backing.lens.shippingAmount .~ 5
          |> Backing.lens.amount .~ 700.0
      )

    combos([Language.en], [Device.phone4_7inch]).forEach { language, device in
      withEnvironment(apiService: mockService, currentUser: User.template, language: language) {
        let controller = PledgeViewController.instantiate()
        controller.configureWith(project: project, reward: .template, refTag: nil, context: .pledge)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 800

        self.scheduler.advance(by: .seconds(1))

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_PledgeContext_NeedsConversion_IsFalse() {
    let userEnvelope = UserEnvelope(me: GraphUserCreditCard.withCards([
      GraphUserCreditCard.visa,
      GraphUserCreditCard.masterCard
    ]))
    let mockService = MockService(fetchGraphCreditCardsResponse: userEnvelope)
    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad], [nil, User.template])
      .forEach { language, device, currentUser in
        withEnvironment(apiService: mockService, currentUser: currentUser, language: language) {
          let controller = PledgeViewController.instantiate()
          controller.configureWith(project: .template, reward: .template, refTag: nil, context: .pledge)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          self.scheduler.advance(by: .seconds(1))

          let loggedIn = currentUser != nil
          let loggedInString = loggedIn ? "LoggedIn" : "LoggedOut"
          if loggedIn { parent.view.frame.size.height = 1_200 }

          FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)_\(loggedInString)")
        }
      }
  }

  func testView_PledgeContext_NeedsConversion_IsTrue() {
    let userEnvelope = UserEnvelope(me: GraphUserCreditCard.withCards([
      GraphUserCreditCard.visa,
      GraphUserCreditCard.masterCard
    ]))
    let mockService = MockService(fetchGraphCreditCardsResponse: userEnvelope)
    let project = Project.template
      |> Project.lens.stats.currentCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 2.0

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad], [nil, User.template])
      .forEach { language, device, currentUser in
        withEnvironment(apiService: mockService, currentUser: currentUser, language: language) {
          let controller = PledgeViewController.instantiate()
          controller.configureWith(project: project, reward: .template, refTag: nil, context: .pledge)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          self.scheduler.advance(by: .seconds(1))

          let loggedIn = currentUser != nil
          let loggedInString = loggedIn ? "LoggedIn" : "LoggedOut"
          if loggedIn { parent.view.frame.size.height = 1_200 }

          FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)_\(loggedInString)")
        }
      }
  }

  func testView_UpdateContext_NeedsConversion_IsFalse() {
    let reward = Reward.template
      |> (Reward.lens.shipping .. Reward.Shipping.lens.enabled) .~ true
    let project = Project.template
      |> Project.lens.stats.currency .~ Currency.USD.rawValue
      |> Project.lens.stats.currentCurrency .~ Currency.USD.rawValue
      |> Project.lens.country .~ .us

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(currentUser: .template, language: language) {
        let controller = PledgeViewController.instantiate()
        controller.configureWith(project: project, reward: reward, refTag: nil, context: .update)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.advance(by: .seconds(1))

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_UpdateContext_withConversionLabel() {
    let reward = Reward.template
      |> (Reward.lens.shipping .. Reward.Shipping.lens.enabled) .~ true
    let project = Project.template
      |> Project.lens.stats.currency .~ Currency.HKD.rawValue
      |> Project.lens.stats.currentCurrency .~ Currency.USD.rawValue
      |> Project.lens.country .~ .hk

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(currentUser: .template, language: language) {
        let controller = PledgeViewController.instantiate()
        controller.configureWith(project: project, reward: reward, refTag: nil, context: .update)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.advance(by: .seconds(1))

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_UpdateContext_NeedsConversion_IsTrue() {
    let project = Project.template
      |> Project.lens.stats.currentCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 2.0
    let reward = Reward.template
      |> (Reward.lens.shipping .. Reward.Shipping.lens.enabled) .~ true

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(currentUser: .template, language: language) {
        let controller = PledgeViewController.instantiate()
        controller.configureWith(project: project, reward: reward, refTag: nil, context: .update)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.advance(by: .seconds(1))

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_ChangePaymentMethodContext_NeedsConversion_IsTrue() {
    let userEnvelope = UserEnvelope(me: GraphUserCreditCard.withCards([
      GraphUserCreditCard.visa,
      GraphUserCreditCard.masterCard
    ]))
    let mockService = MockService(fetchGraphCreditCardsResponse: userEnvelope)
    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ true
    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.amex
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 5
          |> Backing.lens.amount .~ 700.0
      )

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(apiService: mockService, currentUser: .template, language: language) {
        let controller = PledgeViewController.instantiate()
        controller.configureWith(
          project: project, reward: reward, refTag: nil, context: .changePaymentMethod
        )
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.advance(by: .seconds(1))

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_ChangePaymentMethodContext_NeedsConversion_IsFalse() {
    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ true

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
          |> Backing.lens.amount .~ 700.0
      )

    let userEnvelope = UserEnvelope(me: GraphUserCreditCard.withCards([
      GraphUserCreditCard.visa,
      GraphUserCreditCard.masterCard
    ]))
    let mockService = MockService(fetchGraphCreditCardsResponse: userEnvelope)

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(apiService: mockService, currentUser: .template, language: language) {
        let controller = PledgeViewController.instantiate()
        controller.configureWith(
          project: project, reward: reward, refTag: nil, context: .changePaymentMethod
        )
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.advance(by: .seconds(1))

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_ChangePaymentMethodContext_UnavailableStoredCards() {
    let userEnvelope = UserEnvelope(me: GraphUserCreditCard.withCards([
      GraphUserCreditCard.visa,
      GraphUserCreditCard.masterCard
    ]))
    let mockService = MockService(fetchGraphCreditCardsResponse: userEnvelope)
    let project = Project.template
      |> Project.lens.personalization.backing .~ (Backing.template
        |> Backing.lens.paymentSource .~
        (.template |> \.id .~ "123")
      )
      |> \.availableCardTypes .~ [CreditCardType.discover.rawValue]

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(apiService: mockService, currentUser: User.template, language: language) {
        let controller = PledgeViewController.instantiate()
        controller.configureWith(
          project: project,
          reward: .template,
          refTag: nil,
          context: .changePaymentMethod
        )
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.advance(by: .seconds(1))

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
          controller.configureWith(project: .template, reward: reward, refTag: nil, context: .pledge)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          self.scheduler.advance(by: .seconds(1))

          let loggedIn = currentUser != nil
          let loggedInString = loggedIn ? "LoggedIn" : "LoggedOut"
          if loggedIn { parent.view.frame.size.height = 1_200 }

          FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)_\(loggedInString)")
        }
      }
  }
}
