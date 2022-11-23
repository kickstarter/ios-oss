import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class RewardAddOnCardViewModelTests: TestCase {
  fileprivate let vm: RewardAddOnCardViewModelType = RewardAddOnCardViewModel()

  private let addButtonHidden = TestObserver<Bool, Never>()
  private let amountConversionLabelHidden = TestObserver<Bool, Never>()
  private let amountConversionLabelText = TestObserver<String, Never>()
  private let amountLabelAttributedText = TestObserver<String, Never>()
  private let descriptionLabelText = TestObserver<String, Never>()
  private let estimatedDeliveryDateLabelHidden = TestObserver<Bool, Never>()
  private let estimatedDeliveryDateLabelText = TestObserver<String, Never>()
  private let generateSelectionFeedback = TestObserver<Void, Never>()
  private let generateNotificationWarningFeedback = TestObserver<Void, Never>()
  private let includedItemsLabelAttributedText = TestObserver<String, Never>()
  private let includedItemsStackViewHidden = TestObserver<Bool, Never>()
  private let notifiyDelegateDidSelectQuantityQuantity = TestObserver<Int, Never>()
  private let notifiyDelegateDidSelectQuantityRewardId = TestObserver<Int, Never>()
  private let pillsViewHidden = TestObserver<Bool, Never>()
  private let quantityLabelText = TestObserver<String, Never>()
  private let reloadPills = TestObserver<[String], Never>()
  private let rewardSelected = TestObserver<Int, Never>()
  private let rewardTitleLabelText = TestObserver<String, Never>()
  private let rewardLocationPickupLabelText = TestObserver<String, Never>()
  private let rewardLocationStackViewHidden = TestObserver<Bool, Never>()
  private let stepperMaxValue = TestObserver<Double, Never>()
  private let stepperStackViewHidden = TestObserver<Bool, Never>()
  private let stepperValue = TestObserver<Double, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.addButtonHidden.observe(self.addButtonHidden.observer)
    self.vm.outputs.amountLabelAttributedText.map(\.string)
      .observe(self.amountLabelAttributedText.observer)
    self.vm.outputs.amountConversionLabelHidden.observe(self.amountConversionLabelHidden.observer)
    self.vm.outputs.amountConversionLabelText.observe(self.amountConversionLabelText.observer)
    self.vm.outputs.descriptionLabelText.observe(self.descriptionLabelText.observer)
    self.vm.outputs.generateSelectionFeedback.observe(self.generateSelectionFeedback.observer)
    self.vm.outputs.generateNotificationWarningFeedback.observe(
      self.generateNotificationWarningFeedback.observer
    )
    self.vm.outputs.includedItemsLabelAttributedText.map(\.string)
      .observe(self.includedItemsLabelAttributedText.observer)
    self.vm.outputs.includedItemsStackViewHidden.observe(self.includedItemsStackViewHidden.observer)
    self.vm.outputs.notifiyDelegateDidSelectQuantity.map(first)
      .observe(self.notifiyDelegateDidSelectQuantityQuantity.observer)
    self.vm.outputs.notifiyDelegateDidSelectQuantity.map(second)
      .observe(self.notifiyDelegateDidSelectQuantityRewardId.observer)
    self.vm.outputs.pillsViewHidden.observe(self.pillsViewHidden.observer)
    self.vm.outputs.quantityLabelText.observe(self.quantityLabelText.observer)
    self.vm.outputs.reloadPills.observe(self.reloadPills.observer)
    self.vm.outputs.rewardSelected.observe(self.rewardSelected.observer)
    self.vm.outputs.rewardTitleLabelText.observe(self.rewardTitleLabelText.observer)
    self.vm.outputs.rewardLocationStackViewHidden.observe(self.rewardLocationStackViewHidden.observer)
    self.vm.outputs.rewardLocationPickupLabelText.observe(self.rewardLocationPickupLabelText.observer)
    self.vm.outputs.stepperMaxValue.observe(self.stepperMaxValue.observer)
    self.vm.outputs.stepperStackViewHidden.observe(self.stepperStackViewHidden.observer)
    self.vm.outputs.stepperValue.observe(self.stepperValue.observer)
  }

  // MARK: - Reward Title

  func testTitleLabel() {
    let reward = .template
      |> Reward.lens.title .~ "The thing"
      |> Reward.lens.remaining .~ nil

    self.vm.inputs
      .configure(with: .init(
        project: .template,
        reward: reward,
        context: .pledge,
        shippingRule: nil,
        selectedQuantities: [:]
      ))

    self.rewardTitleLabelText.assertValues(["The thing"])
  }

  func testTitleLabel_NoTitle() {
    let reward = .template
      |> Reward.lens.title .~ nil
      |> Reward.lens.remaining .~ nil

    self.vm.inputs
      .configure(with: .init(
        project: .template,
        reward: reward,
        context: .pledge,
        shippingRule: nil,
        selectedQuantities: [:]
      ))

    self.rewardTitleLabelText.assertValues([])
  }

  func testTitleLabel_Backed_AddOn() {
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true

    let reward = .template
      |> Reward.lens.title .~ "The thing"
      |> Reward.lens.remaining .~ nil

    self.vm.inputs
      .configure(with: .init(
        project: project,
        reward: reward,
        context: .pledge,
        shippingRule: nil,
        selectedQuantities: [reward.id: 2]
      ))

    self.rewardTitleLabelText.assertValues(["The thing"])
  }

  // MARK: - Reward Minimum

  func testMinimumLabel_US_Project_US_ProjectCurrency_US_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(countryCode: "US") {
      self.vm.inputs
        .configure(with: .init(
          project: project,
          reward: reward,
          context: .pledge,
          shippingRule: nil,
          selectedQuantities: [:]
        ))

      self.amountLabelAttributedText.assertValues(
        ["$1,000"],
        "Reward minimum appears in project's currency, without a currency symbol."
      )
    }
  }

  func testMinimumLabel_US_Project_US_ProjectCurrency_NonUS_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(countryCode: "MX") {
      self.vm.inputs
        .configure(with: .init(
          project: project,
          reward: reward,
          context: .pledge,
          shippingRule: nil,
          selectedQuantities: [:]
        ))

      self.amountLabelAttributedText.assertValues(
        ["US$ 1,000"],
        "Reward minimum appears in project's currency, with a currency symbol."
      )
    }
  }

  func testMinimumLabel_NonUS_Project_NonUs_ProjectCurrency_US_User_Currency_US_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.currency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 0.5
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(countryCode: "US") {
      self.vm.inputs
        .configure(with: .init(
          project: project,
          reward: reward,
          context: .pledge,
          shippingRule: nil,
          selectedQuantities: [:]
        ))

      self.amountLabelAttributedText.assertValues(
        ["£1,000"],
        "Reward minimum always appears in the project's currency."
      )
    }
  }

  func testMinimumLabel_US_Project_NonUS_ProjectCurrency_US_User_Currency_US_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 0.5
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(countryCode: "US") {
      self.vm.inputs
        .configure(with: .init(
          project: project,
          reward: reward,
          context: .pledge,
          shippingRule: nil,
          selectedQuantities: [:]
        ))

      self.amountLabelAttributedText.assertValues(
        ["£1,000"],
        "Reward minimum always appears in the project's currency not the project's country."
      )
    }
  }

  func testMinimumLabel_NonUs_Project_NonUS_Currency_US_UserCurrency_NonUS_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.currency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 0.5
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(countryCode: "MX") {
      self.vm.inputs
        .configure(with: .init(
          project: project,
          reward: reward,
          context: .pledge,
          shippingRule: nil,
          selectedQuantities: [:]
        ))

      self.amountLabelAttributedText.assertValues(
        ["£1,000"],
        "Reward minimum always appears in the project's currency."
      )
    }
  }

  func testMinimumLabel_NoReward_US_Project_US_ProjectCurrency_US_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode
    let reward = Reward.noReward

    withEnvironment(countryCode: "US") {
      self.vm.inputs
        .configure(with: .init(
          project: project,
          reward: reward,
          context: .pledge,
          shippingRule: nil,
          selectedQuantities: [:]
        ))

      self.amountLabelAttributedText.assertValues(
        ["$1"],
        "No-reward min appears in the project's currency without a currency symbol"
      )
    }
  }

  func testMinimumLabel_NoReward_US_Project_US_ProjectCurrency_NonUS_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode
    let reward = Reward.noReward

    withEnvironment(countryCode: "MX") {
      self.vm.inputs
        .configure(with: .init(
          project: project,
          reward: reward,
          context: .pledge,
          shippingRule: nil,
          selectedQuantities: [:]
        ))

      self.amountLabelAttributedText.assertValues(
        ["US$ 1"],
        "No-reward min appears in the project's currency with a currency symbol"
      )
    }
  }

  func testMinimumLabel_NoReward_NonUS_ProjectCurrency_US_ProjectCountry_US_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode
    let reward = Reward.noReward

    withEnvironment(countryCode: "US") {
      self.vm.inputs
        .configure(with: .init(
          project: project,
          reward: reward,
          context: .pledge,
          shippingRule: nil,
          selectedQuantities: [:]
        ))

      self.amountLabelAttributedText.assertValues(
        ["MX$ 10"],
        """
        No-reward min always appears in the project's currency,
        with the amount depending on the project's currency's country
        """
      )
    }
  }

  func testMinimumLabel_NoReward_NonUS_ProjectCurrency_US_ProjectCountry_NonUS_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode
    let reward = Reward.noReward

    withEnvironment(countryCode: "CA") {
      self.vm.inputs
        .configure(with: .init(
          project: project,
          reward: reward,
          context: .pledge,
          shippingRule: nil,
          selectedQuantities: [:]
        ))

      self.amountLabelAttributedText.assertValues(
        ["MX$ 10"],
        """
        No-reward min always appears in the project's currency,
        with the amount depending on the project's currency's country.
        """
      )
    }
  }

  // MARK: - Included Items

  func testItems() {
    let reward = .template
      |> Reward.lens.rewardsItems .~ [
        .template
          |> RewardsItem.lens.item .~ (
            .template
              |> Item.lens.name .~ "The thing"
          ),
        .template
          |> RewardsItem.lens.quantity .~ 1_000
          |> RewardsItem.lens.item .~ (
            .template
              |> Item.lens.name .~ "The other thing"
          )
      ]

    self.vm.inputs
      .configure(with: .init(
        project: .template,
        reward: reward,
        context: .pledge,
        shippingRule: nil,
        selectedQuantities: [:]
      ))

    self.includedItemsLabelAttributedText.assertValues(["•  The thing•  1,000 x The other thing"])
    self.includedItemsStackViewHidden.assertValues([false])
  }

  func testItemsContainerHidden_WithNoItems() {
    self.vm.inputs.configure(with: .init(
      project: .template,
      reward: .template |> Reward.lens.rewardsItems .~ [],
      context: .pledge,
      shippingRule: nil,
      selectedQuantities: [:]
    ))

    self.includedItemsStackViewHidden.assertValues([true])
  }

  func testRewardLocalPickup_WithNoLocation() {
    self.rewardLocationStackViewHidden.assertDidNotEmitValue()
    self.rewardLocationPickupLabelText.assertDidNotEmitValue()

    let reward = .template
      |> Reward.lens.localPickup .~ nil
      |> Reward.lens.shipping.preference .~ .local

    self.vm.inputs.configure(with: .init(
      project: .template,
      reward: reward,
      context: .pledge,
      shippingRule: nil,
      selectedQuantities: [:]
    ))

    self.rewardLocationStackViewHidden.assertValues([true])
    self.rewardLocationPickupLabelText.assertDidNotEmitValue()
  }

  func testRewardLocalPickup_WithLocation() {
    self.rewardLocationStackViewHidden.assertDidNotEmitValue()
    self.rewardLocationPickupLabelText.assertDidNotEmitValue()

    let reward = .template
      |> Reward.lens.localPickup .~ .brooklyn
      |> Reward.lens.shipping.preference .~ .local

    self.vm.inputs.configure(with: .init(
      project: .template,
      reward: reward,
      context: .pledge,
      shippingRule: nil,
      selectedQuantities: [:]
    ))

    self.rewardLocationStackViewHidden.assertValues([false])
    self.rewardLocationPickupLabelText.assertValue("Brooklyn, NY")
  }

  func testRewardLocalPickup_WithLocationAndNoShippingPreference() {
    self.rewardLocationStackViewHidden.assertDidNotEmitValue()
    self.rewardLocationPickupLabelText.assertDidNotEmitValue()

    let reward = .template
      |> Reward.lens.localPickup .~ .brooklyn
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.none

    self.vm.inputs.configure(with: .init(
      project: .template,
      reward: reward,
      context: .pledge,
      shippingRule: nil,
      selectedQuantities: [:]
    ))

    self.rewardLocationStackViewHidden.assertValues([true])
    self.rewardLocationPickupLabelText.assertValue("Brooklyn, NY")
  }

  // MARK: Description Label

  func testDescriptionLabel() {
    let project = Project.template
    let reward = Reward.template

    self.vm.inputs
      .configure(with: .init(
        project: project,
        reward: reward,
        context: .pledge,
        shippingRule: nil,
        selectedQuantities: [:]
      ))

    self.descriptionLabelText.assertValues([reward.description])
  }

  // MARK: - Conversion Label

  func testConversionLabel_US_UserCurrency_US_Location_US_Project_US_ProjectCurrency_ConfiguredWithReward() {
    let project = .template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ "USD"
      |> Project.lens.stats.currentCurrency .~ "USD"
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(countryCode: "US") {
      self.vm.inputs
        .configure(with: .init(
          project: project,
          reward: reward,
          context: .pledge,
          shippingRule: nil,
          selectedQuantities: [:]
        ))

      self.amountConversionLabelHidden.assertValues(
        [true],
        "US user with US currency preferences, viewing US project does not see conversion."
      )
      self.amountConversionLabelText.assertValueCount(0)
    }
  }

  func testConversionLabel_US_UserCurrency_US_Location_NonUS_Project_NonUS_ProjectCurrency_ConfiguredWithReward() {
    let project = .template
      |> Project.lens.country .~ .ca
      |> Project.lens.stats.currency .~ Project.Country.ca.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 2
    let reward = .template |> Reward.lens.minimum .~ 1

    withEnvironment(countryCode: "US") {
      self.vm.inputs
        .configure(with: .init(
          project: project,
          reward: reward,
          context: .pledge,
          shippingRule: nil,
          selectedQuantities: [:]
        ))

      self.amountConversionLabelHidden.assertValues(
        [false],
        """
        US user with US currency preferences, viewing non-US project sees conversion.
        """
      )
      self.amountConversionLabelText.assertValues(["About $2"], "Conversion without a currency symbol")
    }
  }

  func testConversionLabel_US_Currency_NonUS_Location_NonUS_ProjectCurrency_ConfiguredWithReward() {
    let project = .template
      |> Project.lens.country .~ .ca
      |> Project.lens.stats.currency .~ Project.Country.ca.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 2
    let reward = .template |> Reward.lens.minimum .~ 1

    withEnvironment(countryCode: "MX") {
      self.vm.inputs
        .configure(with: .init(
          project: project,
          reward: reward,
          context: .pledge,
          shippingRule: nil,
          selectedQuantities: [:]
        ))

      self.amountConversionLabelHidden.assertValues(
        [false],
        """
        User with US currency preferences, non-US location, viewing non-US project sees conversion.
        """
      )
      self.amountConversionLabelText.assertValues(["About US$ 2"], "Conversion label shows US symbol.")
    }
  }

  func testConversionLabel_US_Currency_NonUS_Location_NonUS_Project_NonUSProjectCurrency_ConversionRoundedUp() {
    let project = .template
      |> Project.lens.country .~ .mx
      |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 0.05
    let reward = .template |> Reward.lens.minimum .~ 10

    withEnvironment(countryCode: "CA") {
      self.vm.inputs
        .configure(with: .init(
          project: project,
          reward: reward,
          context: .pledge,
          shippingRule: nil,
          selectedQuantities: [:]
        ))

      self.amountConversionLabelHidden.assertValues(
        [false],
        """
        User with US currency preferences, non-US location, viewing non-US project sees conversion rounded up.
        """
      )
      self.amountConversionLabelText.assertValues(["About US$ 1"], "Conversion label shows US symbol.")
    }
  }

  func testConversionLabel_US_Currency_NonUS_Location_NonUS_Project_NonUS_ProjectCurrency_ConversionRoundedUp() {
    let project = .template
      |> Project.lens.country .~ .hk
      |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 0.05
    let reward = .template |> Reward.lens.minimum .~ 10

    withEnvironment(countryCode: "CA") {
      self.vm.inputs
        .configure(with: .init(
          project: project,
          reward: reward,
          context: .pledge,
          shippingRule: nil,
          selectedQuantities: [:]
        ))

      self.amountConversionLabelHidden.assertValues(
        [false],
        """
        User with US currency preferences, non-US location, viewing non-US project sees conversion rounded up.
        """
      )
      self.amountConversionLabelText.assertValues(["About US$ 1"], "Conversion label shows US symbol.")
    }
  }

  func testConversionLabel_Unknown_Location_US_Project_US_ProjectCurrency_ConfiguredWithReward_WithoutUserCurrency() {
    let project = .template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrency .~ nil
      |> Project.lens.stats.currentCurrencyRate .~ nil
    let reward = .template |> Reward.lens.minimum .~ 1

    withEnvironment(countryCode: "XX") {
      self.vm.inputs
        .configure(with: .init(
          project: project,
          reward: reward,
          context: .pledge,
          shippingRule: nil,
          selectedQuantities: [:]
        ))

      self.amountConversionLabelHidden.assertValues(
        [true],
        "Unknown-location, unknown-currency user viewing US project does not see conversion."
      )
    }
  }

  func testConversionLabel_Unknown_Location_NonUS_Project_NonUS_ProjectCurrency_ConfiguredWithReward_WithoutUserCurrency() {
    let project = .template
      |> Project.lens.country .~ .ca
      |> Project.lens.stats.currency .~ Project.Country.ca.currencyCode
      |> Project.lens.stats.currentCurrency .~ nil
      |> Project.lens.stats.currentCurrencyRate .~ nil
    let reward = .template
      |> Reward.lens.minimum .~ 2

    withEnvironment(countryCode: "XX") {
      self.vm.inputs
        .configure(with: .init(
          project: project,
          reward: reward,
          context: .pledge,
          shippingRule: nil,
          selectedQuantities: [:]
        ))

      self.amountConversionLabelHidden.assertValues(
        [false],
        "Unknown-location, unknown-currency user viewing non-US project sees conversion to USD."
      )
      self.amountConversionLabelText.assertValues(
        ["About US$ 2"],
        "Conversion label shows convertedMinimum value."
      )
    }
  }

  func testConversionLabel_NonUS_Location_NonUS_Locale_US_Project_US_ProjectCurrency_ConfiguredWithReward() {
    let project = .template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.mx.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 2
    let reward = .template
      |> Reward.lens.minimum .~ 1

    withEnvironment(
      apiService: MockService(currency: "MXN"), countryCode: "MX"
    ) {
      self.vm.inputs
        .configure(with: .init(
          project: project,
          reward: reward,
          context: .pledge,
          shippingRule: nil,
          selectedQuantities: [:]
        ))

      self.amountConversionLabelHidden.assertValues(
        [false],
        "Mexican user viewing US project sees conversion."
      )
      self.amountConversionLabelText.assertValues(
        ["About MX$ 2"],
        "Conversion label shows convertedMinimum value."
      )
    }
  }

  func testConversionLabel_NonUS_Location_NonUS_Locale_US_Project_US_ProjectCurrency_ConfiguredWithReward_WithShippingRule() {
    let project = .template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.mx.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 2
    let reward = .template
      |> Reward.lens.minimum .~ 1
      |> Reward.lens.shipping.enabled .~ true

    withEnvironment(
      apiService: MockService(currency: "MXN"), countryCode: "MX"
    ) {
      self.vm.inputs
        .configure(with: .init(
          project: project,
          reward: reward,
          context: .pledge,
          shippingRule: .template,
          selectedQuantities: [:]
        ))

      self.amountConversionLabelHidden.assertValues(
        [false],
        "Mexican user viewing US project sees conversion."
      )
      self.amountConversionLabelText.assertValues(
        ["About MX$ 12"],
        "Conversion label shows convertedMinimum value including shipping amount."
      )
    }
  }

  func testConversionLabel_NonUS_Location_NonUS_Locale_US_Project_NonUS_ProjectCurrency_ConfiguredWithReward_WithShippingRule() {
    let project = .template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ Project.Country.es.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.mx.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 2
    let reward = .template
      |> Reward.lens.minimum .~ 1
      |> Reward.lens.shipping.enabled .~ true

    withEnvironment(
      apiService: MockService(currency: "MXN"), countryCode: "MX"
    ) {
      self.vm.inputs
        .configure(with: .init(
          project: project,
          reward: reward,
          context: .pledge,
          shippingRule: .template,
          selectedQuantities: [:]
        ))

      self.amountConversionLabelHidden.assertValues(
        [false],
        "Mexican user viewing US project sees conversion, even if project currency is different from project currency."
      )
      self.amountConversionLabelText.assertValues(
        ["About MX$ 12"],
        "Conversion label shows convertedMinimum value including shipping amount."
      )
    }
  }

  func testConversionLabel_NonUS_Location_US_UserCurrency_US_Project_US_ProjectCurrency_ConfiguredWithReward() {
    let project = .template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.us.currencyCode
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(countryCode: "GB") {
      self.vm.inputs
        .configure(with: .init(
          project: project,
          reward: reward,
          context: .pledge,
          shippingRule: nil,
          selectedQuantities: [:]
        ))

      self.amountConversionLabelHidden.assertValues(
        [true],
        "Non-US user location with USD user preferences viewing US project does not see conversion."
      )
      self.amountConversionLabelText.assertValueCount(0)
    }
  }

  // MARK: - Pills

  func testPillsLimitedReward() {
    self.pillsViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.remaining .~ 25

    self.vm.inputs
      .configure(with: .init(
        project: .template,
        reward: reward,
        context: .pledge,
        shippingRule: nil,
        selectedQuantities: [:]
      ))

    self.pillsViewHidden.assertValues([false])
    self.reloadPills.assertValues([
      ["25 left of 100"]
    ])
  }

  func testPillsLimitedReward_HasBackers() {
    self.pillsViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.backersCount .~ 25
      |> Reward.lens.remaining .~ 25

    self.vm.inputs
      .configure(with: .init(
        project: .template,
        reward: reward,
        context: .pledge,
        shippingRule: nil,
        selectedQuantities: [:]
      ))

    self.pillsViewHidden.assertValues([false])
    self.reloadPills.assertValues([
      ["25 left of 100"]
    ])
  }

  func testPillsTimebasedReward_24hrs() {
    self.pillsViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ nil
      |> Reward.lens.backersCount .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 + 60.0 * 60.0 * 24.0)

    self.vm.inputs
      .configure(with: .init(
        project: .template,
        reward: reward,
        context: .pledge,
        shippingRule: nil,
        selectedQuantities: [:]
      ))

    self.pillsViewHidden.assertValues([false])
    self.reloadPills.assertValues([
      ["24 hrs left"]
    ])
  }

  func testPillsTimebasedReward_4days() {
    self.pillsViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let date = AppEnvironment.current.calendar.date(byAdding: DateComponents(day: 4), to: MockDate().date)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ nil
      |> Reward.lens.backersCount .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.endsAt .~ date?.timeIntervalSince1970

    self.vm.inputs
      .configure(with: .init(
        project: .template,
        reward: reward,
        context: .pledge,
        shippingRule: nil,
        selectedQuantities: [:]
      ))

    self.pillsViewHidden.assertValues([false])
    self.reloadPills.assertValues([
      ["4 days left"]
    ])
  }

  func testPillsTimebasedAndLimitedReward() {
    self.pillsViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let date = AppEnvironment.current.calendar.date(byAdding: DateComponents(day: 4), to: MockDate().date)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.backersCount .~ nil
      |> Reward.lens.remaining .~ 75
      |> Reward.lens.endsAt .~ date?.timeIntervalSince1970

    self.vm.inputs
      .configure(with: .init(
        project: .template,
        reward: reward,
        context: .pledge,
        shippingRule: nil,
        selectedQuantities: [:]
      ))

    self.pillsViewHidden.assertValues([false])
    self.reloadPills.assertValues([
      ["4 days left", "75 left of 100"]
    ])
  }

  func testPillsTimebasedAndLimitedRewardLimitPerBacker() {
    self.pillsViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let date = AppEnvironment.current.calendar.date(byAdding: DateComponents(day: 4), to: MockDate().date)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.limitPerBacker .~ 2
      |> Reward.lens.backersCount .~ nil
      |> Reward.lens.remaining .~ 75
      |> Reward.lens.endsAt .~ date?.timeIntervalSince1970

    self.vm.inputs
      .configure(with: .init(
        project: .template,
        reward: reward,
        context: .pledge,
        shippingRule: nil,
        selectedQuantities: [:]
      ))

    self.pillsViewHidden.assertValues([false])
    self.reloadPills.assertValues([
      ["4 days left", "75 left of 100", "Limit 2"]
    ])
  }

  func testPillsTimebasedAndLimitedReward_Unavailable_NoBackers() {
    self.pillsViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.backersCount .~ nil
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.endsAt .~ (MockDate().date.timeIntervalSince1970 - 1)

    self.vm.inputs
      .configure(with: .init(
        project: .template,
        reward: reward,
        context: .pledge,
        shippingRule: nil,
        selectedQuantities: [:]
      ))

    self.pillsViewHidden.assertValues([true])
    self.reloadPills.assertValues([[]])
  }

  func testPillsNonLimitedReward() {
    self.pillsViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ nil
      |> Reward.lens.backersCount .~ nil
      |> Reward.lens.endsAt .~ nil

    self.vm.inputs
      .configure(with: .init(
        project: .template,
        reward: reward,
        context: .pledge,
        shippingRule: nil,
        selectedQuantities: [:]
      ))

    self.pillsViewHidden.assertValues([true])
    self.reloadPills.assertValues([[]])
  }

  func testPillsLimitedReward_LiveProject_HasBackers() {
    self.pillsViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.remaining .~ 50
      |> Reward.lens.backersCount .~ 50

    let project = Project.template
      |> Project.lens.state .~ .live

    self.vm.inputs
      .configure(with: .init(
        project: project,
        reward: reward,
        context: .pledge,
        shippingRule: nil,
        selectedQuantities: [:]
      ))

    self.pillsViewHidden.assertValues([false])
    self.reloadPills.assertValues([["50 left of 100"]])
  }

  func testAddButtonAndStepper() {
    self.addButtonHidden.assertDidNotEmitValue()
    self.quantityLabelText.assertDidNotEmitValue()
    self.stepperMaxValue.assertDidNotEmitValue()
    self.stepperStackViewHidden.assertDidNotEmitValue()
    self.stepperValue.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.limitPerBacker .~ 10

    self.vm.inputs
      .configure(with: .init(
        project: .template,
        reward: reward,
        context: .pledge,
        shippingRule: nil,
        selectedQuantities: [:]
      ))

    self.addButtonHidden.assertValues([false])
    self.quantityLabelText.assertValues(["0"])
    self.stepperMaxValue.assertValues([10])
    self.stepperStackViewHidden.assertValues([true])
    self.stepperValue.assertValues([0])

    self.vm.inputs.addButtonTapped()

    self.addButtonHidden.assertValues([false, true])
    self.quantityLabelText.assertValues(["0", "1"])
    self.stepperMaxValue.assertValues([10])
    self.stepperStackViewHidden.assertValues([true, false])
    self.stepperValue.assertValues([0, 1])

    self.vm.inputs.stepperValueChanged(0)

    self.addButtonHidden.assertValues([false, true, false])
    self.quantityLabelText.assertValues(["0", "1", "0"])
    self.stepperMaxValue.assertValues([10])
    self.stepperStackViewHidden.assertValues([true, false, true])
    self.stepperValue.assertValues([0, 1, 0])
  }

  func testNotifiyDelegateDidSelectQuantity_NoPreviousSelection() {
    self.notifiyDelegateDidSelectQuantityRewardId.assertDidNotEmitValue()
    self.notifiyDelegateDidSelectQuantityQuantity.assertDidNotEmitValue()
    self.quantityLabelText.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.limitPerBacker .~ 10

    self.vm.inputs
      .configure(with: .init(
        project: .template,
        reward: reward,
        context: .pledge,
        shippingRule: nil,
        selectedQuantities: [:]
      ))

    self.quantityLabelText.assertValues(["0"])
    self.notifiyDelegateDidSelectQuantityRewardId.assertDidNotEmitValue()
    self.notifiyDelegateDidSelectQuantityQuantity.assertDidNotEmitValue()

    self.vm.inputs.addButtonTapped()

    self.quantityLabelText.assertValues(["0", "1"])
    self.notifiyDelegateDidSelectQuantityRewardId.assertValues([1])
    self.notifiyDelegateDidSelectQuantityQuantity.assertValues([1])

    self.vm.inputs.stepperValueChanged(2)

    self.quantityLabelText.assertValues(["0", "1", "2"])
    self.notifiyDelegateDidSelectQuantityRewardId.assertValues([1, 1])
    self.notifiyDelegateDidSelectQuantityQuantity.assertValues([1, 2])
  }

  func testNotifiyDelegateDidSelectQuantity_HasPreviousSelection() {
    self.notifiyDelegateDidSelectQuantityRewardId.assertDidNotEmitValue()
    self.notifiyDelegateDidSelectQuantityQuantity.assertDidNotEmitValue()
    self.quantityLabelText.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.limitPerBacker .~ 10

    self.vm.inputs
      .configure(with: .init(
        project: .template,
        reward: reward,
        context: .pledge,
        shippingRule: nil,
        selectedQuantities: [reward.id: 5]
      ))

    self.quantityLabelText.assertValues(["5"])
    self.notifiyDelegateDidSelectQuantityRewardId.assertDidNotEmitValue()
    self.notifiyDelegateDidSelectQuantityQuantity.assertDidNotEmitValue()

    self.vm.inputs.stepperValueChanged(4)

    self.quantityLabelText.assertValues(["5", "4"])
    self.notifiyDelegateDidSelectQuantityRewardId.assertValues([1])
    self.notifiyDelegateDidSelectQuantityQuantity.assertValues([4])

    self.vm.inputs.stepperValueChanged(3)

    self.quantityLabelText.assertValues(["5", "4", "3"])
    self.notifiyDelegateDidSelectQuantityRewardId.assertValues([1, 1])
    self.notifiyDelegateDidSelectQuantityQuantity.assertValues([4, 3])
  }

  func testGenerateFeedback() {
    let reward = Reward.template
      |> Reward.lens.limitPerBacker .~ 10

    self.vm.inputs
      .configure(with: .init(
        project: .template,
        reward: reward,
        context: .pledge,
        shippingRule: nil,
        selectedQuantities: [:]
      ))

    self.generateSelectionFeedback.assertDidNotEmitValue()
    self.generateNotificationWarningFeedback.assertDidNotEmitValue()

    self.vm.inputs.stepperValueChanged(1)
    self.generateSelectionFeedback.assertValueCount(1)
    self.generateNotificationWarningFeedback.assertValueCount(0)

    self.vm.inputs.stepperValueChanged(5)
    self.generateSelectionFeedback.assertValueCount(2)
    self.generateNotificationWarningFeedback.assertValueCount(0)

    self.vm.inputs.stepperValueChanged(10)
    self.generateSelectionFeedback.assertValueCount(2)
    self.generateNotificationWarningFeedback.assertValueCount(1)

    self.vm.inputs.stepperValueChanged(4)
    self.generateSelectionFeedback.assertValueCount(3)
    self.generateNotificationWarningFeedback.assertValueCount(1)

    self.vm.inputs.stepperValueChanged(0)
    self.generateSelectionFeedback.assertValueCount(3)
    self.generateNotificationWarningFeedback.assertValueCount(2)

    self.vm.inputs
      .configure(with: .init(
        project: .template,
        reward: reward,
        context: .pledge,
        shippingRule: nil,
        selectedQuantities: [:]
      ))

    // Does not generate feedback when reconfigured for cell re-use.
    self.generateSelectionFeedback.assertValueCount(3)
    self.generateNotificationWarningFeedback.assertValueCount(2)
  }
}
