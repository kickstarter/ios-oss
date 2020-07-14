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

  private let cardUserInteractionIsEnabled = TestObserver<Bool, Never>()
  private let amountConversionLabelHidden = TestObserver<Bool, Never>()
  private let amountConversionLabelText = TestObserver<String, Never>()
  private let amountLabelAttributedText = TestObserver<String, Never>()
  private let descriptionLabelText = TestObserver<String, Never>()
  private let estimatedDeliveryDateLabelHidden = TestObserver<Bool, Never>()
  private let estimatedDeliveryDateLabelText = TestObserver<String, Never>()
  private let includedItemsLabelAttributedText = TestObserver<String, Never>()
  private let includedItemsStackViewHidden = TestObserver<Bool, Never>()
  private let pillsViewHidden = TestObserver<Bool, Never>()
  private let reloadPills = TestObserver<[String], Never>()
  private let rewardSelected = TestObserver<Int, Never>()
  private let rewardTitleLabelText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.amountLabelAttributedText.map(\.string)
      .observe(self.amountLabelAttributedText.observer)
    self.vm.outputs.amountConversionLabelHidden.observe(self.amountConversionLabelHidden.observer)
    self.vm.outputs.amountConversionLabelText.observe(self.amountConversionLabelText.observer)
    self.vm.outputs.cardUserInteractionIsEnabled.observe(self.cardUserInteractionIsEnabled.observer)
    self.vm.outputs.descriptionLabelText.observe(self.descriptionLabelText.observer)
    self.vm.outputs.includedItemsLabelAttributedText.map(\.string)
      .observe(self.includedItemsLabelAttributedText.observer)
    self.vm.outputs.includedItemsStackViewHidden.observe(self.includedItemsStackViewHidden.observer)
    self.vm.outputs.pillsViewHidden.observe(self.pillsViewHidden.observer)
    self.vm.outputs.reloadPills.observe(self.reloadPills.observer)
    self.vm.outputs.rewardSelected.observe(self.rewardSelected.observer)
    self.vm.outputs.rewardTitleLabelText.observe(self.rewardTitleLabelText.observer)
  }

  // MARK: - Reward Title

  func testTitleLabel() {
    let reward = .template
      |> Reward.lens.title .~ "The thing"
      |> Reward.lens.remaining .~ nil

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

    self.rewardTitleLabelText.assertValues(["The thing"])
  }

  func testTitleLabel_NoTitle() {
    let reward = .template
      |> Reward.lens.title .~ nil
      |> Reward.lens.remaining .~ nil

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

    self.rewardTitleLabelText.assertValues([])
  }

  func testTitleLabel_Backed_AddOn() {
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true

    let reward = .template
      |> \.addOnData .~ AddOnData(isAddOn: true, selectedQuantity: 2, limitPerBacker: 2)
      |> Reward.lens.title .~ "The thing"
      |> Reward.lens.remaining .~ nil

    self.vm.inputs.configure(with: (project, reward, .pledge, nil))

    self.rewardTitleLabelText.assertValues(["The thing"])
  }

  // MARK: - Reward Minimum

  func testMinimumLabel_US_Project_US_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ .us
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(countryCode: "US") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.amountLabelAttributedText.assertValues(
        ["$1,000"],
        "Reward minimum appears in project's currency, without a currency symbol."
      )
    }
  }

  func testMinimumLabel_US_Project_NonUS_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ .us
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(countryCode: "MX") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.amountLabelAttributedText.assertValues(
        ["US$ 1,000"],
        "Reward minimum appears in project's currency, with a currency symbol."
      )
    }
  }

  func testMinimumLabel_NonUS_Project_US_User_Currency_US_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.currency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 0.5
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(countryCode: "US") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.amountLabelAttributedText.assertValues(
        ["£1,000"],
        "Reward minimum always appears in the project's currency."
      )
    }
  }

  func testMinimumLabel_NonUs_Project_US_UserCurrency_NonUS_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.currency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 0.5
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(countryCode: "MX") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.amountLabelAttributedText.assertValues(
        ["£1,000"],
        "Reward minimum always appears in the project's currency."
      )
    }
  }

  func testMinimumLabel_NoReward_US_Project_US_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ .us
    let reward = Reward.noReward

    withEnvironment(countryCode: "US") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.amountLabelAttributedText.assertValues(
        ["$1"],
        "No-reward min appears in the project's currency without a currency symbol"
      )
    }
  }

  func testMinimumLabel_NoReward_US_Project_NonUS_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ .us
    let reward = Reward.noReward

    withEnvironment(countryCode: "MX") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.amountLabelAttributedText.assertValues(
        ["US$ 1"],
        "No-reward min appears in the project's currency with a currency symbol"
      )
    }
  }

  func testMinimumLabel_NoReward_NonUS_Project_US_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ Project.Country.mx
    let reward = Reward.noReward

    withEnvironment(countryCode: "US") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.amountLabelAttributedText.assertValues(
        ["MX$ 10"],
        """
        No-reward min always appears in the project's currency,
        with the amount depending on the project's country
        """
      )
    }
  }

  func testMinimumLabel_NoReward_NonUS_Project_NonUS_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ Project.Country.mx
    let reward = Reward.noReward

    withEnvironment(countryCode: "CA") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.amountLabelAttributedText.assertValues(
        ["MX$ 10"],
        """
        No-reward min always appears in the project's currency,
        with the amount depending on the project's country
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

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

    self.includedItemsLabelAttributedText.assertValues(["•  The thing•  1,000 x The other thing"])
    self.includedItemsStackViewHidden.assertValues([false])
  }

  func testItemsContainerHidden_WithNoItems() {
    self.vm.inputs.configure(with: (
      project: .template,
      reward: .template |> Reward.lens.rewardsItems .~ [],
      context: .pledge,
      nil
    ))

    self.includedItemsStackViewHidden.assertValues([true])
  }

  // MARK: Description Label

  func testDescriptionLabel() {
    let project = Project.template
    let reward = Reward.template

    self.vm.inputs.configure(with: (project, reward, .pledge, nil))

    self.descriptionLabelText.assertValues([reward.description])
  }

  // MARK: - Conversion Label

  func testConversionLabel_US_UserCurrency_US_Location_US_Project_ConfiguredWithReward() {
    let project = .template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ "USD"
      |> Project.lens.stats.currentCurrency .~ "USD"
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(countryCode: "US") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.amountConversionLabelHidden.assertValues(
        [true],
        "US user with US currency preferences, viewing US project does not see conversion."
      )
      self.amountConversionLabelText.assertValueCount(0)
    }
  }

  func testConversionLabel_US_UserCurrency_US_Location_NonUS_Project_ConfiguredWithReward() {
    let project = .template
      |> Project.lens.country .~ .ca
      |> Project.lens.stats.currency .~ Project.Country.ca.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 2
    let reward = .template |> Reward.lens.minimum .~ 1

    withEnvironment(countryCode: "US") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.amountConversionLabelHidden.assertValues(
        [false],
        """
        US user with US currency preferences, viewing non-US project sees conversion.
        """
      )
      self.amountConversionLabelText.assertValues(["About $2"], "Conversion without a currency symbol")
    }
  }

  func testConversionLabel_US_Currency_NonUS_Location_NonUS_Project_ConfiguredWithReward() {
    let project = .template
      |> Project.lens.country .~ .ca
      |> Project.lens.stats.currency .~ Project.Country.ca.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 2
    let reward = .template |> Reward.lens.minimum .~ 1

    withEnvironment(countryCode: "MX") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.amountConversionLabelHidden.assertValues(
        [false],
        """
        User with US currency preferences, non-US location, viewing non-US project sees conversion.
        """
      )
      self.amountConversionLabelText.assertValues(["About US$ 2"], "Conversion label shows US symbol.")
    }
  }

  func testConversionLabel_Unknown_Location_US_Project_ConfiguredWithReward_WithoutUserCurrency() {
    let project = .template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrency .~ nil
      |> Project.lens.stats.currentCurrencyRate .~ nil
    let reward = .template |> Reward.lens.minimum .~ 1

    withEnvironment(countryCode: "XX") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.amountConversionLabelHidden.assertValues(
        [true],
        "Unknown-location, unknown-currency user viewing US project does not see conversion."
      )
    }
  }

  func testConversionLabel_Unknown_Location_NonUS_Project_ConfiguredWithReward_WithoutUserCurrency() {
    let project = .template
      |> Project.lens.country .~ .ca
      |> Project.lens.stats.currency .~ Project.Country.ca.currencyCode
      |> Project.lens.stats.currentCurrency .~ nil
      |> Project.lens.stats.currentCurrencyRate .~ nil
    let reward = .template
      |> Reward.lens.minimum .~ 2

    withEnvironment(countryCode: "XX") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

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

  func testConversionLabel_NonUS_Location_NonUS_Locale_US_Project_ConfiguredWithReward() {
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
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

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

  func testConversionLabel_NonUS_Location_NonUS_Locale_US_Project_ConfiguredWithReward_WithShippingRule() {
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
      self.vm.inputs.configure(with: (project, reward, .pledge, .template))

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

  func testConversionLabel_NonUS_Location_US_UserCurrency_US_Project_ConfiguredWithReward() {
    let project = .template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.us.currencyCode
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(countryCode: "GB") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.amountConversionLabelHidden.assertValues(
        [true],
        "Non-US user location with USD user preferences viewing US project does not see conversion."
      )
      self.amountConversionLabelText.assertValueCount(0)
    }
  }

  // MARK: - Card View

  func testCardUserInteractionIsEnabled_NotLimitedReward() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.minimum .~ 1_000

    self.vm.inputs.configure(with: (project, reward, .pledge, nil))

    self.cardUserInteractionIsEnabled.assertValues([true])
  }

  func testCardUserInteractionIsEnabled_NotAllGone() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.remaining .~ 10
      |> Reward.lens.minimum .~ 1_000.0

    self.vm.inputs.configure(with: (project, reward, .pledge, nil))

    self.cardUserInteractionIsEnabled.assertValues([true])
  }

  func testCardUserInteractionIsEnabled_AllGone() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.minimum .~ 1_000.0

    self.vm.inputs.configure(with: (project, reward, .pledge, nil))

    self.cardUserInteractionIsEnabled.assertValues([false])
  }

  // MARK: - Pills

  func testPillsLimitedReward() {
    self.pillsViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.remaining .~ 25

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

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

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

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

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

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

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

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

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

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
      |> Reward.lens.addOnData .~ AddOnData(isAddOn: true, selectedQuantity: 0, limitPerBacker: 2)
      |> Reward.lens.limit .~ 100
      |> Reward.lens.backersCount .~ nil
      |> Reward.lens.remaining .~ 75
      |> Reward.lens.endsAt .~ date?.timeIntervalSince1970

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

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

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

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

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

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

    self.vm.inputs.configure(with: (project, reward, .pledge, nil))

    self.pillsViewHidden.assertValues([false])
    self.reloadPills.assertValues([["50 left of 100"]])
  }
}
