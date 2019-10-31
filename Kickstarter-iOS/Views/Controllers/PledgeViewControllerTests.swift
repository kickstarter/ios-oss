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

  func testView_NeedsConversion_IsFalse() {
    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(language: language) {
        let controller = PledgeViewController.instantiate()
        controller.configureWith(project: .template, reward: .template, refTag: nil, context: .pledge)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_NeedsConversion_IsTrue() {
    let project = Project.template
      |> Project.lens.stats.currentCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 2.0

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(language: language) {
        let controller = PledgeViewController.instantiate()
        controller.configureWith(project: project, reward: .template, refTag: nil, context: .pledge)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
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
      withEnvironment(language: language) {
        let controller = PledgeViewController.instantiate()
        controller.configureWith(project: project, reward: reward, refTag: nil, context: .update)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.advance(by: .milliseconds(10))
        self.scheduler.run()

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
      withEnvironment(language: language) {
        let controller = PledgeViewController.instantiate()
        controller.configureWith(project: project, reward: reward, refTag: nil, context: .update)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.advance(by: .milliseconds(10))
        self.scheduler.run()

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
      withEnvironment(language: language) {
        let controller = PledgeViewController.instantiate()
        controller.configureWith(project: project, reward: reward, refTag: nil, context: .update)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.advance(by: .milliseconds(10))
        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_ChangePaymentMethodContext_NeedsConversion_IsTrue() {
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
          |> Backing.lens.amount .~ 700
      )

    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let apiService = MockService(fetchGraphCreditCardsResponse: response)

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(apiService: apiService, currentUser: .template, language: language) {
        let controller = PledgeViewController.instantiate()
        controller.configureWith(
          project: project, reward: reward, refTag: nil, context: .changePaymentMethod
        )
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

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
          |> Backing.lens.amount .~ 700
      )

    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let apiService = MockService(fetchGraphCreditCardsResponse: response)

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(apiService: apiService, currentUser: .template, language: language) {
        let controller = PledgeViewController.instantiate()
        controller.configureWith(
          project: project, reward: reward, refTag: nil, context: .changePaymentMethod
        )
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_ShowsShippingLocationSection() {
    let reward = Reward.template
      |> (Reward.lens.shipping .. Reward.Shipping.lens.enabled) .~ true

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(language: language) {
        let controller = PledgeViewController.instantiate()
        controller.configureWith(project: .template, reward: reward, refTag: nil, context: .pledge)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
