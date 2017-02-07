// swiftlint:disable type_name
import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi

private let tolerance: CGFloat = 0.0001

internal final class RewardPledgeViewControllerTests: TestCase {
  fileprivate let cosmicSurgery = Project.cosmicSurgery
    |> Project.lens.state .~ .live
  fileprivate let cosmicReward = Project.cosmicSurgery.rewards.last!
    |> Reward.lens.shipping.enabled .~ true
    |> Reward.lens.estimatedDeliveryOn .~ 1506031200

  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)

    AppEnvironment.pushEnvironment(
      apiService: MockService(
        fetchShippingRulesResponse: [
          .template |> ShippingRule.lens.location .~ .usa,
          .template |> ShippingRule.lens.location .~ .canada,
          .template |> ShippingRule.lens.location .~ .greatBritain,
          .template |> ShippingRule.lens.location .~ .australia,
        ]
      ),
      mainBundle: Bundle.framework
    )
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testPledge() {
    let project = self.cosmicSurgery
    let reward = self.cosmicReward |> Reward.lens.rewardsItems .~ []

    combos(Language.allLanguages, [false, true]).forEach { language, applePayCapable in
      withEnvironment(language: language) {

        let vc = RewardPledgeViewController.configuredWith(
          project: project, reward: reward, applePayCapable: applePayCapable
        )
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
        parent.view.frame.size.height -= 64

        self.scheduler.run()

        FBSnapshotVerifyView(
          vc.view, identifier: "lang_\(language)_apple_pay_\(applePayCapable)", tolerance: tolerance
        )
      }
    }
  }

  func testPledge_Loading() {
    let project = self.cosmicSurgery
    let reward = self.cosmicReward |> Reward.lens.rewardsItems .~ []

    withEnvironment(currentUser: .template) {
      let vc = RewardPledgeViewController.configuredWith(
        project: project, reward: reward, applePayCapable: false
      )
      let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
      parent.view.frame.size.height -= 64

      self.scheduler.advance()

      vc.viewModel.inputs.continueToPaymentsButtonTapped()

      FBSnapshotVerifyView(vc.view, identifier: "lang_en_apple_pay_false", tolerance: tolerance)
    }
  }

  func testPledge_ApplePayCapable_UnsupportedCountry() {
    let unsupportedCountry = Project.Country(countryCode: "ZZ",
                                             currencyCode: "ZZD",
                                             currencySymbol: "µ",
                                             maxPledge: 10_000,
                                             minPledge: 1,
                                             trailingCode: true)
    let project = self.cosmicSurgery
      |> Project.lens.country .~ unsupportedCountry
    let reward = self.cosmicReward |> Reward.lens.rewardsItems .~ []

    let vc = RewardPledgeViewController.configuredWith(
      project: project, reward: reward, applePayCapable: true
    )
    let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)

    self.scheduler.run()

    FBSnapshotVerifyView(parent.view, tolerance: tolerance)
  }

  func testExpandReward() {
    let project = self.cosmicSurgery
    let reward = self.cosmicReward

    let vc = RewardPledgeViewController.configuredWith(project: project, reward: reward)
    let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
    parent.view.frame.size.height = 870

    vc.viewModel.inputs.expandDescriptionTapped()
    self.scheduler.run()

    FBSnapshotVerifyView(vc.view, tolerance: tolerance)
  }

  func testPledge_NoShipping() {
    let project = self.cosmicSurgery
    let reward = self.cosmicReward
      |> Reward.lens.rewardsItems .~ []
      |> Reward.lens.shipping.enabled .~ false

    let vc = RewardPledgeViewController.configuredWith(project: project, reward: reward)
    let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
    parent.view.frame.size.height -= 64

    self.scheduler.run()

    FBSnapshotVerifyView(vc.view)
  }

  func testDescriptionLabelTruncated() {
    let description: String = "You will be the first to receive a copy of the book at the special price of " +
      "£30. The book will be sold for £35 in shops when released in July.You will be the first to receive a" +
      "copy of the book at the special price of £30. The book will be sold for £35 in shops when released" +
      "in  July. You will be the first  to receive a copy of the book at the special price of £30. The book" +
      "will be sold for £35 in shops when released in July.You will be the first to receive a copy of the"
    let project = self.cosmicSurgery
    let reward = self.cosmicReward |> Reward.lens.description .~ description


    let vc = RewardPledgeViewController.configuredWith(project: project, reward: reward)
    let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
    parent.view.frame.size.height = 870

    self.scheduler.run()

    FBSnapshotVerifyView(vc.view)
  }

  func testPledgeSmallDevice() {
    let project = self.cosmicSurgery
    let reward = self.cosmicReward
      |> Reward.lens.rewardsItems .~ []

    [false, true].forEach { applePayCapable in
      let vc = RewardPledgeViewController.configuredWith(
        project: project, reward: reward, applePayCapable: applePayCapable
      )
      let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
      parent.view.frame.size.height -= 64

      self.scheduler.run()

      FBSnapshotVerifyView(vc.view, identifier: "apple_pay_\(applePayCapable)", tolerance: tolerance)
    }
  }

  func testPledge_NoReward() {
    let reward = Reward.noReward
    let project = self.cosmicSurgery |> Project.lens.country .~ .US

    combos(Language.allLanguages, [false, true]).forEach { language, applePayCapable in
      withEnvironment(language: language) {
        let vc = RewardPledgeViewController.configuredWith(
          project: project, reward: reward, applePayCapable: applePayCapable
        )
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
        parent.view.frame.size.height += 100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_apple_pay_\(applePayCapable)")
      }
    }
  }

  func testManageReward() {
    let reward = self.cosmicReward |> Reward.lens.rewardsItems .~ []
    let project = self.cosmicSurgery
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
          |> Backing.lens.amount .~ (reward.minimum + 10)
          |> Backing.lens.shippingAmount .~ 10
    )

    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let vc = RewardPledgeViewController.configuredWith(
          project: project, reward: reward, applePayCapable: false
        )
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
        parent.view.frame.size.height += 100

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)", tolerance: tolerance)
      }
    }
  }

  func testManagePledge() {
    let reward = Reward.noReward
    let project = self.cosmicSurgery
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
          |> Backing.lens.amount .~ 10
    )

    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let vc = RewardPledgeViewController.configuredWith(
          project: project, reward: reward, applePayCapable: false
        )
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testManagePledge_ApplePayCapable() {
    let reward = Reward.noReward
    let project = self.cosmicSurgery
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
          |> Backing.lens.amount .~ 10
    )

    let vc = RewardPledgeViewController.configuredWith(
      project: project, reward: reward, applePayCapable: true
    )
    let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)

    self.scheduler.run()

    FBSnapshotVerifyView(parent.view)
  }

  func testChangeReward() {
    let newReward = self.cosmicReward
      |> Reward.lens.id .~ 42
      |> Reward.lens.minimum .~ 42
      |> Reward.lens.rewardsItems .~ []
    let oldReward = self.cosmicReward
      |> Reward.lens.rewardsItems .~ []
    let project = self.cosmicSurgery
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ oldReward
          |> Backing.lens.amount .~ (oldReward.minimum + 10)
          |> Backing.lens.shippingAmount .~ 10
    )

    combos(Language.allLanguages, [true, false]).forEach { language, applePayCapable in
      withEnvironment(language: language) {
        let vc = RewardPledgeViewController.configuredWith(
          project: project, reward: newReward, applePayCapable: applePayCapable
        )
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
        parent.view.frame.size.height += 100

        self.scheduler.run()

        FBSnapshotVerifyView(
          parent.view, identifier: "lang_\(language)_apple_pay_\(applePayCapable)", tolerance: tolerance
        )
      }
    }
  }

  func testChangeReward_ApplePayCapable() {
    let newReward = self.cosmicReward
      |> Reward.lens.id .~ 42
      |> Reward.lens.minimum .~ 42
      |> Reward.lens.rewardsItems .~ []
    let oldReward = self.cosmicReward
      |> Reward.lens.rewardsItems .~ []
    let project = self.cosmicSurgery
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ oldReward
          |> Backing.lens.amount .~ (oldReward.minimum + 10)
          |> Backing.lens.shippingAmount .~ 10
    )

    let vc = RewardPledgeViewController.configuredWith(
      project: project, reward: newReward, applePayCapable: true
    )
    let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
    parent.view.frame.size.height += 100

    self.scheduler.run()

    FBSnapshotVerifyView(parent.view, tolerance: tolerance)
  }

  func testAmbigiousCurrencies() {
    let project = self.cosmicSurgery
      |> Project.lens.stats.staticUsdRate .~ 1.2
    let reward = self.cosmicReward
      |> Reward.lens.rewardsItems .~ []

    let launchedCountries = AppEnvironment.current.launchedCountries.countries
    let currentUserCountries = ["US", "GB"]
    combos(launchedCountries, currentUserCountries).forEach { country, currentUserCountry in
      withEnvironment(countryCode: currentUserCountry) {

        let vc = RewardPledgeViewController.configuredWith(
          project: project |> Project.lens.country .~ country, reward: reward, applePayCapable: false
        )
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
        parent.view.frame.size.height -= 64

        self.scheduler.run()

        FBSnapshotVerifyView(
          vc.view,
          identifier: "country_\(country.countryCode)_current_user_country_\(currentUserCountry)",
          tolerance: tolerance
        )
      }
    }
  }
}
