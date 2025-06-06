import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class RewardCardViewModelTests: TestCase {
  fileprivate let vm: RewardCardViewModelType = RewardCardViewModel()

  private let cardUserInteractionIsEnabled = TestObserver<Bool, Never>()
  private let conversionLabelHidden = TestObserver<Bool, Never>()
  private let conversionLabelText = TestObserver<String, Never>()
  private let descriptionLabelText = TestObserver<String, Never>()
  private let estimatedDeliveryDateLabelHidden = TestObserver<Bool, Never>()
  private let estimatedDeliveryDateLabelText = TestObserver<String, Never>()
  private let includedItemsStackViewHidden = TestObserver<Bool, Never>()
  private let items = TestObserver<[String], Never>()
  private let pillCollectionViewHidden = TestObserver<Bool, Never>()
  private let reloadPills = TestObserver<[RewardCardPillData], Never>()
  private let rewardMinimumLabelText = TestObserver<String, Never>()
  private let rewardSelected = TestObserver<Int, Never>()
  private let rewardTitleLabelHidden = TestObserver<Bool, Never>()
  private let rewardTitleLabelAttributedText = TestObserver<NSAttributedString, Never>()
  private let rewardLocationPickupLabelText = TestObserver<String, Never>()
  private let rewardLocationStackViewHidden = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.cardUserInteractionIsEnabled.observe(self.cardUserInteractionIsEnabled.observer)
    self.vm.outputs.conversionLabelHidden.observe(self.conversionLabelHidden.observer)
    self.vm.outputs.conversionLabelText.observe(self.conversionLabelText.observer)
    self.vm.outputs.descriptionLabelText.observe(self.descriptionLabelText.observer)
    self.vm.outputs.estimatedDeliveryStackViewHidden.observe(self.estimatedDeliveryDateLabelHidden.observer)
    self.vm.outputs.estimatedDeliveryDateLabelText.observe(self.estimatedDeliveryDateLabelText.observer)
    self.vm.outputs.includedItemsStackViewHidden.observe(self.includedItemsStackViewHidden.observer)
    self.vm.outputs.items.observe(self.items.observer)
    self.vm.outputs.pillCollectionViewHidden.observe(self.pillCollectionViewHidden.observer)
    self.vm.outputs.reloadPills.observe(self.reloadPills.observer)
    self.vm.outputs.rewardMinimumLabelText.observe(self.rewardMinimumLabelText.observer)
    self.vm.outputs.rewardSelected.observe(self.rewardSelected.observer)
    self.vm.outputs.rewardTitleLabelHidden.observe(self.rewardTitleLabelHidden.observer)
    self.vm.outputs.rewardTitleLabelAttributedText.observe(self.rewardTitleLabelAttributedText.observer)
    self.vm.outputs.rewardLocationStackViewHidden.observe(self.rewardLocationStackViewHidden.observer)
    self.vm.outputs.rewardLocationPickupLabelText.observe(self.rewardLocationPickupLabelText.observer)
  }

  // MARK: - Reward Title

  func testTitleLabel() {
    let reward = .template
      |> Reward.lens.title .~ "The thing"
      |> Reward.lens.remaining .~ nil

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

    self.rewardTitleLabelHidden.assertValues([false])
    XCTAssertEqual(self.rewardTitleLabelAttributedText.values.map { $0.string }, ["The thing"])
  }

  func testTitleLabel_NoTitle() {
    let reward = .template
      |> Reward.lens.title .~ nil
      |> Reward.lens.remaining .~ nil

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

    self.rewardTitleLabelHidden.assertValues([true])
    XCTAssertEqual(self.rewardTitleLabelAttributedText.values.map { $0.string }, [""])
  }

  func testTitleLabel_NoTitle_NoReward() {
    let reward = Reward.noReward

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

    self.rewardTitleLabelHidden.assertValues([false])
    XCTAssertEqual(self.rewardTitleLabelAttributedText.values.map { $0.string }, ["Pledge without a reward"])
  }

  func testTitleLabel_BackedNoReward() {
    let reward = Reward.noReward

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.amount .~ 700
      )

    self.vm.inputs.configure(with: (project, reward, .pledge, nil))

    self.rewardTitleLabelHidden.assertValues([false])
    XCTAssertEqual(
      self.rewardTitleLabelAttributedText.values.map { $0.string },
      ["You pledged without a reward"]
    )
  }

  func testTitleLabel_Backed_AddOn() {
    let reward = .template
      |> Reward.lens.id .~ 99
      |> Reward.lens.title .~ "The thing"
      |> Reward.lens.remaining .~ nil

    let backing = Backing.template
      |> Backing.lens.addOns .~ [reward, reward]

    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ backing

    self.vm.inputs.configure(with: (project, reward, .pledge, nil))

    self.rewardTitleLabelHidden.assertValues([false])
    XCTAssertEqual(self.rewardTitleLabelAttributedText.values.map { $0.string }, ["2 x The thing"])
  }

  func testTitleLabel_Backed_AddOn_Single() {
    let reward = .template
      |> Reward.lens.id .~ 99
      |> Reward.lens.title .~ "The thing"
      |> Reward.lens.remaining .~ nil

    let backing = Backing.template
      |> Backing.lens.addOns .~ [reward]

    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ backing

    self.vm.inputs.configure(with: (project, reward, .pledge, nil))

    XCTAssertEqual(self.rewardTitleLabelAttributedText.values.map { $0.string }, ["The thing"])
  }

  // MARK: - Reward Minimum

  func testMinimumLabel_US_Project_US_ProjectCurrency_US_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ Project.Country.us
      |> Project.lens.stats.projectCurrency .~ Project.Country.us.currencyCode
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(countryCode: "US") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.rewardMinimumLabelText.assertValues(
        ["$1,000"],
        "Reward minimum appears in project's currency, without a currency symbol."
      )
    }
  }

  func testMinimumLabel_US_Project_US_ProjectCurrency_NonUS_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ Project.Country.us
      |> Project.lens.stats.projectCurrency .~ Project.Country.us.currencyCode
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(countryCode: "MX") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.rewardMinimumLabelText.assertValues(
        ["US$ 1,000"],
        "Reward minimum appears in project's currency, with a currency symbol."
      )
    }
  }

  func testMinimumLabel_NonUS_Project_NonUS_ProjectCurrency_US_User_Currency_US_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.projectCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.userCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.userCurrencyRate .~ 0.5
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(countryCode: "US") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.rewardMinimumLabelText.assertValues(
        ["£1,000"],
        "Reward minimum always appears in the project's currency."
      )
    }
  }

  func testMinimumLabel_NonUs_Project_NonUs_ProjectCurrency_US_UserCurrency_NonUS_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.projectCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.userCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.userCurrencyRate .~ 0.5
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(countryCode: "MX") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.rewardMinimumLabelText.assertValues(
        ["£1,000"],
        "Reward minimum always appears in the project's currency."
      )
    }
  }

  func testMinimumLabel_Us_Project_NonUs_ProjectCurrency_US_UserCurrency_NonUS_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.projectCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.userCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.userCurrencyRate .~ 0.5
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(countryCode: "MX") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.rewardMinimumLabelText.assertValues(
        ["£1,000"],
        "Reward minimum always appears in the project's currency."
      )
    }
  }

  func testMinimumLabel_NoReward_US_Project_US_ProjectCurrency_US_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.projectCurrency .~ Project.Country.us.currencyCode
    let reward = Reward.noReward

    withEnvironment(countryCode: "US") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.rewardMinimumLabelText.assertValues(
        ["$1"],
        "No-reward min appears in the project's currency without a currency symbol"
      )
    }
  }

  func testMinimumLabel_NoReward_US_Project_US_ProjectCurrency_NonUS_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.projectCurrency .~ Project.Country.us.currencyCode
    let reward = Reward.noReward

    withEnvironment(countryCode: "MX") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.rewardMinimumLabelText.assertValues(
        ["US$ 1"],
        "No-reward min appears in the project's currency with a currency symbol"
      )
    }
  }

  func testMinimumLabel_NoReward_NonUS_ProjectCurrency_US_Project_US_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.projectCurrency .~ Project.Country.mx.currencyCode
    let reward = Reward.noReward

    withEnvironment(countryCode: "US") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.rewardMinimumLabelText.assertValues(
        ["MX$ 10"],
        """
        No-reward min always appears in the project's currency,
        with the amount depending on the project's country
        """
      )
    }
  }

  func testMinimumLabel_NoReward_NonUS_ProjectCurrency_US_Project_NonUS_UserLocation() {
    let project = Project.template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.projectCurrency .~ Project.Country.mx.currencyCode
    let reward = Reward.noReward

    withEnvironment(countryCode: "CA") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.rewardMinimumLabelText.assertValues(
        ["MX$ 10"],
        """
        No-reward min always appears in the project's currency,
        with the amount depending on the project's country
        """
      )
    }
  }

  func testConversionLabel() {
    let project = Project.template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.projectCurrency .~ Project.Country.mx.currencyCode
    let reward = Reward.noReward
      |> Reward.lens.convertedMinimum .~ 0.6

    withEnvironment(countryCode: "US") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.conversionLabelText.assertValues(
        ["About $1"],
        "No-reward min is rounded up."
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

    self.items.assertValues([["The thing", "(1,000) The other thing"]])
    self.includedItemsStackViewHidden.assertValues([false])
  }

  func testItemsContainerHidden_WithNoItems() {
    self.vm.inputs.configure(with: (
      project: .template,
      reward: .template |> Reward.lens.rewardsItems .~ [],
      context: .pledge, nil
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

  func testDescriptionLabel_NoReward() {
    let project = Project.template
    let reward = Reward.noReward

    self.vm.inputs.configure(with: (project, reward, .pledge, nil))

    self.descriptionLabelText.assertValues(["Back it because you believe in it."])
  }

  // MARK: - Conversion Label

  func testConversionLabel_US_UserCurrency_US_Location_US_Project_US_ProjectCurrency_ConfiguredWithReward() {
    let project = .template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.projectCurrency .~ "USD"
      |> Project.lens.stats.userCurrency .~ "USD"
    let reward = .template |> Reward.lens.convertedMinimum .~ 1_000

    withEnvironment(countryCode: "US") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.conversionLabelHidden.assertValues(
        [true],
        "US user with US currency preferences, viewing US project does not see conversion."
      )
      self.conversionLabelText.assertValueCount(0)
    }
  }

  func testConversionLabel_US_UserCurrency_US_Location_NonUS_Project_ConfiguredWithReward() {
    let project = .template
      |> Project.lens.country .~ .ca
      |> Project.lens.stats.projectCurrency .~ Project.Country.ca.currencyCode
      |> Project.lens.stats.userCurrency .~ Project.Country.us.currencyCode
    let reward = .template |> Reward.lens.convertedMinimum .~ 2

    withEnvironment(countryCode: "US") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.conversionLabelHidden.assertValues(
        [false],
        """
        US user with US currency preferences, viewing non-US project
        sees conversion.
        """
      )
      self.conversionLabelText.assertValues(["About $2"], "Conversion without a currency symbol")
    }
  }

  func testConversionLabel_US_Currency_NonUS_Location_NonUS_Project_ConfiguredWithReward() {
    let project = .template
      |> Project.lens.country .~ .ca
      |> Project.lens.stats.projectCurrency .~ Project.Country.ca.currencyCode
      |> Project.lens.stats.userCurrency .~ Project.Country.us.currencyCode
    let reward = .template |> Reward.lens.convertedMinimum .~ 2

    withEnvironment(countryCode: "MX") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.conversionLabelHidden.assertValues(
        [false],
        """
        User with US currency preferences, non-US location, viewing non-US project
        sees conversion.
        """
      )
      self.conversionLabelText.assertValues(["About US$ 2"], "Conversion label shows US symbol.")
    }
  }

  func testConversionLabel_Unknown_Location_US_Project_ConfiguredWithReward_WithoutUserCurrency() {
    let project = .template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.projectCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.userCurrency .~ nil
      |> Project.lens.stats.userCurrencyRate .~ nil
    let reward = .template |> Reward.lens.convertedMinimum .~ 1

    withEnvironment(countryCode: "XX") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.conversionLabelHidden.assertValues(
        [true],
        "Unknown-location, unknown-currency user viewing US project does not see conversion."
      )
    }
  }

  func testConversionLabel_Unknown_Location_NonUS_Project_ConfiguredWithReward_WithoutUserCurrency() {
    let project = .template
      |> Project.lens.country .~ .ca
      |> Project.lens.stats.projectCurrency .~ Project.Country.ca.currencyCode
      |> Project.lens.stats.userCurrency .~ nil
      |> Project.lens.stats.userCurrencyRate .~ nil
    let reward = .template |> Reward.lens.convertedMinimum .~ 2

    withEnvironment(countryCode: "XX") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.conversionLabelHidden.assertValues(
        [false],
        "Unknown-location, unknown-currency user viewing non-US project sees conversion to USD."
      )
      self.conversionLabelText.assertValues(["About US$ 2"], "Conversion label shows convertedMinimum value.")
    }
  }

  func testConversionLabel_NonUS_Location_NonUS_Locale_US_Project_ConfiguredWithReward() {
    let project = .template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.projectCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.userCurrency .~ Project.Country.mx.currencyCode
    let reward = .template |> Reward.lens.convertedMinimum .~ 2

    withEnvironment(
      apiService: MockService(currency: "MXN"), countryCode: "MX"
    ) {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.conversionLabelHidden.assertValues(
        [false],
        "Mexican user viewing US project sees conversion."
      )
      self.conversionLabelText.assertValues(["About MX$ 2"], "Conversion label shows convertedMinimum value.")
    }
  }

  func testConversionLabel_NonUS_Location_US_UserCurrency_US_Project_ConfiguredWithReward() {
    let project = .template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.projectCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.userCurrency .~ Project.Country.us.currencyCode
    let reward = .template |> Reward.lens.convertedMinimum .~ 1_000

    withEnvironment(countryCode: "GB") {
      self.vm.inputs.configure(with: (project, reward, .pledge, nil))

      self.conversionLabelHidden.assertValues(
        [true],
        "Non-US user location with USD user preferences viewing US project does not see conversion."
      )
      self.conversionLabelText.assertValueCount(0)
    }
  }

  // MARK: - Card View

  func testRewardCardTapped() {
    self.vm.inputs.configure(with: (project: .template, reward: .template, context: .pledge, nil))

    self.vm.inputs.rewardCardTapped()

    self.rewardSelected.assertValues([Reward.template.id])
  }

  func testCardUserInteractionIsEnabled_NotLimitedReward() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.minimum .~ 1_000
      |> Reward.lens.isAvailable .~ true

    self.vm.inputs.configure(with: (project, reward, .pledge, nil))

    self.cardUserInteractionIsEnabled.assertValues([true])
  }

  func testCardUserInteractionIsEnabled_NotAllGone() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.remaining .~ 10
      |> Reward.lens.minimum .~ 1_000.0
      |> Reward.lens.isAvailable .~ true

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

  func testPillsRewardHasAddOns() {
    self.pillCollectionViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let reward = Reward.postcards
      |> Reward.lens.backersCount .~ nil
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.hasAddOns .~ true

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

    self.pillCollectionViewHidden.assertValues([false])
    self.reloadPills.assertValues([
      [RewardCardPillData(
        backgroundColor: LegacyColors.Tags.Success.background.uiColor(),
        text: "Add-ons",
        textColor: LegacyColors.Tags.Success.foreground.uiColor()
      )]
    ])
  }

  func testPillsLimitedReward() {
    self.pillCollectionViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.remaining .~ 25

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

    self.pillCollectionViewHidden.assertValues([false])
    self.reloadPills.assertValues([
      [RewardCardPillData(
        backgroundColor: LegacyColors.Tags.Warn.background.uiColor(),
        text: "25 left of 100",
        textColor: LegacyColors.Tags.Warn.foreground.uiColor()
      )]
    ])
  }

  func testPillsLimitedReward_HasBackers() {
    self.pillCollectionViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.backersCount .~ 25
      |> Reward.lens.remaining .~ 25

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

    self.pillCollectionViewHidden.assertValues([false])
    self.reloadPills.assertValues([
      [RewardCardPillData(
        backgroundColor: LegacyColors.Tags.Warn.background.uiColor(),
        text: "25 left of 100",
        textColor: LegacyColors.Tags.Warn.foreground.uiColor()
      )]
    ])
  }

  func testPillsUnlimitedReward_HasBackers() {
    self.pillCollectionViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ nil
      |> Reward.lens.backersCount .~ 25

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

    self.pillCollectionViewHidden.assertValues([false])
    self.reloadPills.assertValues([
      [RewardCardPillData(
        backgroundColor: LegacyColors.Tags.Success.background.uiColor(),
        text: "25 backers",
        textColor: LegacyColors.Tags.Success.foreground.uiColor()
      )]
    ])
  }

  func testPillsTimebasedReward_24hrs() {
    self.pillCollectionViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ nil
      |> Reward.lens.backersCount .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 + 60.0 * 60.0 * 24.0)

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

    self.pillCollectionViewHidden.assertValues([false])
    self.reloadPills.assertValues([
      [RewardCardPillData(
        backgroundColor: LegacyColors.Tags.Warn.background.uiColor(),
        text: "24 hrs left",
        textColor: LegacyColors.Tags.Warn.foreground.uiColor()
      )]
    ])
  }

  func testPillsTimebasedReward_4days() {
    self.pillCollectionViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let date = AppEnvironment.current.calendar.date(byAdding: DateComponents(day: 4), to: MockDate().date)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ nil
      |> Reward.lens.backersCount .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.endsAt .~ date?.timeIntervalSince1970

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

    self.pillCollectionViewHidden.assertValues([false])
    self.reloadPills.assertValues([
      [RewardCardPillData(
        backgroundColor: LegacyColors.Tags.Warn.background.uiColor(),
        text: "4 days left",
        textColor: LegacyColors.Tags.Warn.foreground.uiColor()
      )]
    ])
  }

  func testPillsTimebasedAndLimitedReward() {
    self.pillCollectionViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let date = AppEnvironment.current.calendar.date(byAdding: DateComponents(day: 4), to: MockDate().date)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.backersCount .~ nil
      |> Reward.lens.remaining .~ 75
      |> Reward.lens.endsAt .~ date?.timeIntervalSince1970

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

    self.pillCollectionViewHidden.assertValues([false])
    self.reloadPills.assertValues([
      [
        RewardCardPillData(
          backgroundColor: LegacyColors.Tags.Warn.background.uiColor(),
          text: "4 days left",
          textColor: LegacyColors.Tags.Warn.foreground.uiColor()
        ),
        RewardCardPillData(
          backgroundColor: LegacyColors.Tags.Warn.background.uiColor(),
          text: "75 left of 100",
          textColor: LegacyColors.Tags.Warn.foreground.uiColor()
        )
      ]
    ])
  }

  func testPillsTimebasedAndLimitedReward_ShippingEnabled_Worldwide() {
    self.pillCollectionViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let date = AppEnvironment.current.calendar.date(byAdding: DateComponents(day: 4), to: MockDate().date)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.backersCount .~ nil
      |> Reward.lens.remaining .~ 75
      |> Reward.lens.endsAt .~ date?.timeIntervalSince1970
      |> Reward.lens.shipping .~ (
        .template
          |> Reward.Shipping.lens.enabled .~ true
          |> Reward.Shipping.lens.summary .~ "Ships worldwide"
      )

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

    self.pillCollectionViewHidden.assertValues([false])
    self.reloadPills.assertValues([
      [
        RewardCardPillData(
          backgroundColor: LegacyColors.Tags.Warn.background.uiColor(),
          text: "4 days left",
          textColor: LegacyColors.Tags.Warn.foreground.uiColor()
        ),
        RewardCardPillData(
          backgroundColor: LegacyColors.Tags.Warn.background.uiColor(),
          text: "75 left of 100",
          textColor: LegacyColors.Tags.Warn.foreground.uiColor()
        ),
        RewardCardPillData(
          backgroundColor: LegacyColors.Tags.Success.background.uiColor(),
          text: "Ships worldwide",
          textColor: LegacyColors.Tags.Success.foreground.uiColor()
        )
      ]
    ])
  }

  func testPillsTimebasedAndLimitedReward_ShippingEnabled_SingleLocation() {
    self.pillCollectionViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let date = AppEnvironment.current.calendar.date(byAdding: DateComponents(day: 4), to: MockDate().date)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.backersCount .~ nil
      |> Reward.lens.remaining .~ 75
      |> Reward.lens.endsAt .~ date?.timeIntervalSince1970
      |> Reward.lens.shipping .~ (
        .template
          |> Reward.Shipping.lens.enabled .~ true
          |> Reward.Shipping.lens.type .~ .singleLocation
          |> Reward.Shipping.lens.summary .~ "United States only"
      )

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

    self.pillCollectionViewHidden.assertValues([false])
    self.reloadPills.assertValues([
      [
        RewardCardPillData(
          backgroundColor: LegacyColors.Tags.Warn.background.uiColor(),
          text: "4 days left",
          textColor: LegacyColors.Tags.Warn.foreground.uiColor()
        ),
        RewardCardPillData(
          backgroundColor: LegacyColors.Tags.Warn.background.uiColor(),
          text: "75 left of 100",
          textColor: LegacyColors.Tags.Warn.foreground.uiColor()
        ),
        RewardCardPillData(
          backgroundColor: LegacyColors.Tags.Success.background.uiColor(),
          text: "United States only",
          textColor: LegacyColors.Tags.Success.foreground.uiColor()
        )
      ]
    ])
  }

  func testPillsTimebasedAndLimitedReward_ShippingEnabled_MultipleLocations() {
    self.pillCollectionViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let date = AppEnvironment.current.calendar.date(byAdding: DateComponents(day: 4), to: MockDate().date)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.backersCount .~ nil
      |> Reward.lens.remaining .~ 75
      |> Reward.lens.endsAt .~ date?.timeIntervalSince1970
      |> Reward.lens.shipping .~ (
        .template
          |> Reward.Shipping.lens.enabled .~ true
          |> Reward.Shipping.lens.summary .~ "Limited shipping"
      )

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

    self.pillCollectionViewHidden.assertValues([false])
    self.reloadPills.assertValues([
      [
        RewardCardPillData(
          backgroundColor: LegacyColors.Tags.Warn.background.uiColor(),
          text: "4 days left",
          textColor: LegacyColors.Tags.Warn.foreground.uiColor()
        ),
        RewardCardPillData(
          backgroundColor: LegacyColors.Tags.Warn.background.uiColor(),
          text: "75 left of 100",
          textColor: LegacyColors.Tags.Warn.foreground.uiColor()
        ),
        RewardCardPillData(
          backgroundColor: LegacyColors.Tags.Success.background.uiColor(),
          text: "Limited shipping",
          textColor: LegacyColors.Tags.Success.foreground.uiColor()
        )
      ]
    ])
  }

  func testPillsTimebasedAndLimitedReward_ShippingEnabled_Available_HasBackers() {
    self.pillCollectionViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let date = AppEnvironment.current.calendar.date(byAdding: DateComponents(day: 4), to: MockDate().date)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.backersCount .~ 50
      |> Reward.lens.remaining .~ 25
      |> Reward.lens.endsAt .~ date?.timeIntervalSince1970
      |> Reward.lens.shipping .~ (
        .template
          |> Reward.Shipping.lens.enabled .~ true
          |> Reward.Shipping.lens.summary .~ "Ships worldwide"
      )

    let project = Project.template
      |> Project.lens.state .~ .live

    self.vm.inputs.configure(with: (project, reward, .pledge, nil))

    self.pillCollectionViewHidden.assertValues([false])
    self.reloadPills.assertValues([
      [
        RewardCardPillData(
          backgroundColor: LegacyColors.Tags.Warn.background.uiColor(),
          text: "4 days left",
          textColor: LegacyColors.Tags.Warn.foreground.uiColor()
        ),
        RewardCardPillData(
          backgroundColor: LegacyColors.Tags.Warn.background.uiColor(),
          text: "25 left of 100",
          textColor: LegacyColors.Tags.Warn.foreground.uiColor()
        ),
        RewardCardPillData(
          backgroundColor: LegacyColors.Tags.Success.background.uiColor(),
          text: "Ships worldwide",
          textColor: LegacyColors.Tags.Success.foreground.uiColor()
        )
      ]
    ])
  }

  func testPillsTimebasedAndLimitedReward_ShippingEnabled_Unavailable_HasBackers() {
    self.pillCollectionViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let date = AppEnvironment.current.calendar.date(byAdding: DateComponents(day: 4), to: MockDate().date)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.backersCount .~ 50
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.endsAt .~ date?.timeIntervalSince1970
      |> Reward.lens.shipping .~ (
        .template
          |> Reward.Shipping.lens.enabled .~ true
          |> Reward.Shipping.lens.summary .~ "Ships worldwide"
      )

    let project = Project.template
      |> Project.lens.state .~ .live

    self.vm.inputs.configure(with: (project, reward, .pledge, nil))

    self.pillCollectionViewHidden.assertValues([false])
    self.reloadPills.assertValues([
      [
        RewardCardPillData(
          backgroundColor: LegacyColors.Tags.Success.background.uiColor(),
          text: "50 backers",
          textColor: LegacyColors.Tags.Success.foreground.uiColor()
        ),
        RewardCardPillData(
          backgroundColor: LegacyColors.Tags.Success.background.uiColor(),
          text: "Ships worldwide",
          textColor: LegacyColors.Tags.Success.foreground.uiColor()
        )
      ]
    ])
  }

  func testPillsTimebasedAndLimitedReward_ShippingEnabled_NonLive() {
    self.pillCollectionViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let date = AppEnvironment.current.calendar.date(byAdding: DateComponents(day: 4), to: MockDate().date)

    let project = .template
      |> Project.lens.state .~ .successful

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.backersCount .~ nil
      |> Reward.lens.remaining .~ 75
      |> Reward.lens.endsAt .~ date?.timeIntervalSince1970
      |> Reward.lens.shipping .~ (
        .template
          |> Reward.Shipping.lens.enabled .~ true
          |> Reward.Shipping.lens.type .~ .anywhere
      )

    self.vm.inputs.configure(with: (project, reward, .pledge, nil))

    self.pillCollectionViewHidden.assertValues([true])
    self.reloadPills.assertValues([[]])
  }

  func testPillsTimebasedAndLimitedReward_NonLiveProject() {
    self.pillCollectionViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let date = AppEnvironment.current.calendar.date(byAdding: DateComponents(day: 4), to: MockDate().date)

    let project = Project.template
      |> Project.lens.state .~ .successful

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.backersCount .~ nil
      |> Reward.lens.remaining .~ 75
      |> Reward.lens.endsAt .~ date?.timeIntervalSince1970

    self.vm.inputs.configure(with: (project, reward, .pledge, nil))

    self.pillCollectionViewHidden.assertValues([true])
    self.reloadPills.assertValues([[]])
  }

  func testPillsTimebasedAndLimitedReward_Unavailable_NoBackers() {
    self.pillCollectionViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.backersCount .~ nil
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.endsAt .~ (MockDate().date.timeIntervalSince1970 - 1)

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

    self.pillCollectionViewHidden.assertValues([true])
    self.reloadPills.assertValues([[]])
  }

  func testPillsNonLimitedReward() {
    self.pillCollectionViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ nil
      |> Reward.lens.backersCount .~ nil
      |> Reward.lens.endsAt .~ nil

    self.vm.inputs.configure(with: (.template, reward, .pledge, nil))

    self.pillCollectionViewHidden.assertValues([true])
    self.reloadPills.assertValues([[]])
  }

  func testPillsLimitedReward_LiveProject_HasBackers() {
    self.pillCollectionViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.remaining .~ 50
      |> Reward.lens.backersCount .~ 50

    let project = Project.template
      |> Project.lens.state .~ .live

    self.vm.inputs.configure(with: (project, reward, .pledge, nil))

    self.pillCollectionViewHidden.assertValues([false])
    self.reloadPills
      .assertValues([[RewardCardPillData(
        backgroundColor: LegacyColors.Tags.Warn.background.uiColor(),
        text: "50 left of 100",
        textColor: LegacyColors.Tags.Warn.foreground.uiColor()
      )]])
  }

  func testPillsLimitedReward_NonLiveProject_HasBackers() {
    self.pillCollectionViewHidden.assertValueCount(0)
    self.reloadPills.assertValueCount(0)

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.remaining .~ 50
      |> Reward.lens.backersCount .~ 50

    let project = Project.template
      |> Project.lens.state .~ .successful

    self.vm.inputs.configure(with: (project, reward, .pledge, nil))

    self.pillCollectionViewHidden.assertValues([false])
    self.reloadPills
      .assertValues([[RewardCardPillData(
        backgroundColor: LegacyColors.Tags.Success.background.uiColor(),
        text: "50 backers",
        textColor: LegacyColors.Tags.Success.foreground.uiColor()
      )]])
  }

  func testEstimatedDeliveryDate_IsShown_PledgeContext() {
    self.estimatedDeliveryDateLabelText.assertDidNotEmitValue()
    self.estimatedDeliveryDateLabelHidden.assertDidNotEmitValue()

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.remaining .~ 50
      |> Reward.lens.backersCount .~ 50

    let project = Project.template
      |> Project.lens.state .~ .successful

    self.vm.inputs.configure(with: (project, reward, .pledge, nil))

    self.estimatedDeliveryDateLabelText.assertValues(["October 2017"])
    self.estimatedDeliveryDateLabelHidden.assertValues([false])
  }

  func testEstimatedDeliveryDate_IsNotShown_ManageContext() {
    self.estimatedDeliveryDateLabelText.assertDidNotEmitValue()
    self.estimatedDeliveryDateLabelHidden.assertDidNotEmitValue()

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.remaining .~ 50
      |> Reward.lens.backersCount .~ 50

    let project = Project.template
      |> Project.lens.state .~ .successful

    self.vm.inputs.configure(with: (project, reward, .manage, nil))

    self.estimatedDeliveryDateLabelText.assertValues(["October 2017"])
    self.estimatedDeliveryDateLabelHidden.assertValues([true])
  }

  func testEstimatedDeliveryDate_IsNotShown_EstimatedDeliveryOnIsNil() {
    self.estimatedDeliveryDateLabelText.assertDidNotEmitValue()
    self.estimatedDeliveryDateLabelHidden.assertDidNotEmitValue()

    let reward = Reward.postcards
      |> Reward.lens.estimatedDeliveryOn .~ nil
      |> Reward.lens.limit .~ 100
      |> Reward.lens.remaining .~ 50
      |> Reward.lens.backersCount .~ 50

    let project = Project.template
      |> Project.lens.state .~ .successful

    self.vm.inputs.configure(with: (project, reward, .manage, nil))

    self.estimatedDeliveryDateLabelText.assertValues([])
    self.estimatedDeliveryDateLabelHidden.assertValues([true])
  }

  func testRewardLocalPickup_WithNoLocation() {
    self.rewardLocationStackViewHidden.assertDidNotEmitValue()
    self.rewardLocationPickupLabelText.assertDidNotEmitValue()

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.remaining .~ 50
      |> Reward.lens.backersCount .~ 50
      |> Reward.lens.localPickup .~ nil

    let project = Project.template
      |> Project.lens.state .~ .successful

    self.vm.inputs.configure(with: (project, reward, .manage, nil))

    self.rewardLocationStackViewHidden.assertValues([true])
    self.rewardLocationPickupLabelText.assertDidNotEmitValue()
  }

  func testRewardLocalPickup_WithLocation() {
    self.rewardLocationStackViewHidden.assertDidNotEmitValue()
    self.rewardLocationPickupLabelText.assertDidNotEmitValue()

    let reward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.remaining .~ 50
      |> Reward.lens.backersCount .~ 50
      |> Reward.lens.localPickup .~ .losAngeles
      |> Reward.lens.shipping.preference .~ .local

    let project = Project.template
      |> Project.lens.state .~ .successful

    self.vm.inputs.configure(with: (project, reward, .manage, nil))

    self.rewardLocationStackViewHidden.assertValues([false])
    self.rewardLocationPickupLabelText.assertValue("Los Angeles, CA")
  }
}
