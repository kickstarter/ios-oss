@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class RewardCellViewModelTests: TestCase {
  fileprivate let vm: RewardCellViewModelType = RewardCellViewModel()

  private let cardUserInteractionIsEnabled = TestObserver<Bool, Never>()
  private let conversionLabelHidden = TestObserver<Bool, Never>()
  private let conversionLabelText = TestObserver<String, Never>()
  private let descriptionLabelText = TestObserver<String, Never>()
  private let items = TestObserver<[String], Never>()
  private let includedItemsStackViewHidden = TestObserver<Bool, Never>()
  private let pledgeButtonEnabled = TestObserver<Bool, Never>()
  private let pledgeButtonTitleText = TestObserver<String, Never>()
  private let rewardMinimumLabelText = TestObserver<String, Never>()
  private let rewardSelected = TestObserver<Int, Never>()
  private let rewardTitleLabelHidden = TestObserver<Bool, Never>()
  private let rewardTitleLabelText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.cardUserInteractionIsEnabled.observe(self.cardUserInteractionIsEnabled.observer)
    self.vm.outputs.conversionLabelHidden.observe(self.conversionLabelHidden.observer)
    self.vm.outputs.conversionLabelText.observe(self.conversionLabelText.observer)
    self.vm.outputs.descriptionLabelText.observe(self.descriptionLabelText.observer)
    self.vm.outputs.items.observe(self.items.observer)
    self.vm.outputs.includedItemsStackViewHidden.observe(self.includedItemsStackViewHidden.observer)
    self.vm.outputs.pledgeButtonEnabled.observe(self.pledgeButtonEnabled.observer)
    self.vm.outputs.pledgeButtonTitleText.observe(self.pledgeButtonTitleText.observer)
    self.vm.outputs.rewardMinimumLabelText.observe(self.rewardMinimumLabelText.observer)
    self.vm.outputs.rewardSelected.observe(self.rewardSelected.observer)
    self.vm.outputs.rewardTitleLabelHidden.observe(self.rewardTitleLabelHidden.observer)
    self.vm.outputs.rewardTitleLabelText.observe(self.rewardTitleLabelText.observer)
  }

  // MARK: - Reward Title

  func testTitleLabel() {
    print("**HERE 2**")

    let reward = .template
      |> Reward.lens.title .~ "The thing"
      |> Reward.lens.remaining .~ nil

    self.vm.inputs.configureWith(
      project: .template,
      rewardOrBacking: .left(reward)
    )

    self.rewardTitleLabelHidden.assertValues([false])
    self.rewardTitleLabelText.assertValues(["The thing"])
  }

  func testTitleLabel_NoTitle() {
    let reward = .template
      |> Reward.lens.title .~ nil
      |> Reward.lens.remaining .~ nil

    self.vm.inputs.configureWith(
      project: .template,
      rewardOrBacking: .left(reward)
    )

    self.rewardTitleLabelHidden.assertValues([true])
    self.rewardTitleLabelText.assertValues([""])
  }

  func testTitleLabel_EmptyTitle() {
    let reward = .template
      |> Reward.lens.title .~ nil
      |> Reward.lens.remaining .~ nil

    self.vm.inputs.configureWith(
      project: .template,
      rewardOrBacking: .left(reward)
    )

    self.rewardTitleLabelHidden.assertValues([true])
    self.rewardTitleLabelText.assertValues([""])
  }

  // MARK: - Reward Minimum

  func testMinimumLabel() {
    let project = Project.template
    let reward = .template |> Reward.lens.minimum .~ 1_000

    self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

    self.rewardMinimumLabelText.assertValues([Format.currency(reward.minimum, country: project.country)])
  }

  func testMinimumLabel_NoReward() {
    let project = Project.template
    let reward = Reward.noReward

    self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

    self.rewardMinimumLabelText.assertValues(["$1"])
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

    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(reward))

    self.items.assertValues([["The thing", "(1,000) The other thing"]])
    self.includedItemsStackViewHidden.assertValues([false])
  }

  func testItemsContainerHidden_WithNoItems() {
    self.vm.inputs.configureWith(
      project: .template,
      rewardOrBacking: .left(.template |> Reward.lens.rewardsItems .~ [])
    )

    self.includedItemsStackViewHidden.assertValues([true])
  }

  // MARK: Description Label

  func testDescriptionLabel() {
    let project = Project.template
    let reward = Reward.template

    self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

    self.descriptionLabelText.assertValues([reward.description])
  }

  func testDescriptionLabel_NoReward() {
    let project = Project.template
    let reward = Reward.noReward

    self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

    self.descriptionLabelText.assertValues(["Pledge any amount to help bring this project to life."])
  }

  // MARK: Conversion Label

  func testConversionLabel_US_User_US_Project_ConfiguredWithReward() {
    let project = .template |> Project.lens.country .~ .us
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

      self.conversionLabelHidden.assertValues([true], "US user viewing US project does not see conversion.")
      self.conversionLabelText.assertValueCount(0)
    }
  }

  func testConversionLabel_US_User_US_Project_ConfiguredWithBacking() {
    let project = .template |> Project.lens.country .~ .us
    let reward = .template |> Reward.lens.minimum .~ 30
    let backing = .template
      |> Backing.lens.amount .~ 42
      |> Backing.lens.reward .~ reward

    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      self.vm.inputs.configureWith(project: project, rewardOrBacking: .right(backing))

      self.conversionLabelHidden.assertValues(
        [true],
        "US user viewing US project does not see conversion."
      )
      self.conversionLabelText.assertValueCount(0)
    }
  }

  func testConversionLabel_US_User_NonUS_Project_ConfiguredWithReward() {
    let project = .template
      |> Project.lens.country .~ .ca
      |> Project.lens.stats.staticUsdRate .~ 0.76
      |> Project.lens.stats.currentCurrency .~ "MXN"
      |> Project.lens.stats.currentCurrencyRate .~ 2.0
    let reward = .template |> Reward.lens.minimum .~ 1

    withEnvironment(
      apiService: MockService(currency: "MXN"),
      config: .template |> Config.lens.countryCode .~ "MX"
    ) {
      self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

      self.conversionLabelHidden.assertValues(
        [false],
        "Mexican user viewing non-Mexican project sees conversion."
      )
      self.conversionLabelText.assertValues(["About MX$ 2"], "Conversion label rounds up.")
    }
  }

  func testConversionLabel_US_User_NonUS_Project_ConfiguredWithReward_WithoutCurrentCurrency() {
    let project = .template
      |> Project.lens.country .~ .ca
      |> Project.lens.stats.currency .~ Project.Country.ca.currencyCode
      |> Project.lens.stats.staticUsdRate .~ 0.76
      |> Project.lens.stats.currentCurrencyRate .~ nil
    let reward = .template |> Reward.lens.minimum .~ 1

    withEnvironment(countryCode: "US") {
      self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

      self.conversionLabelHidden.assertValues([false], "US user viewing non-US project sees conversion.")
      self.conversionLabelText.assertValues(["About $1"], "Conversion label rounds up.")
    }
  }

  func testConversionLabel_US_User_NonUS_Project_ConfiguredWithBacking() {
    let project = .template
      |> Project.lens.country .~ .ca
      |> Project.lens.stats.staticUsdRate .~ 0.76
      |> Project.lens.stats.currentCurrency .~ "MXN"
      |> Project.lens.stats.currentCurrencyRate .~ 2.0
    let reward = .template |> Reward.lens.minimum .~ 1
    let backing = .template
      |> Backing.lens.amount .~ 2
      |> Backing.lens.reward .~ reward

    withEnvironment(
      apiService: MockService(currency: "MXN"),
      config: .template |> Config.lens.countryCode .~ "MX"
    ) {
      self.vm.inputs.configureWith(project: project, rewardOrBacking: .right(backing))

      self.conversionLabelHidden.assertValues(
        [false],
        "Mexican user viewing non-Mexican project sees conversion."
      )
      self.conversionLabelText.assertValues(["About MX$ 4"], "Conversion label rounds up.")
    }
  }

  func testConversionLabel_US_User_NonUS_Project_ConfiguredWithBacking_WithoutCurrentCurrency() {
    let project = .template
      |> Project.lens.country .~ .ca
      |> Project.lens.stats.currency .~ Project.Country.ca.currencyCode
      |> Project.lens.stats.staticUsdRate .~ 0.76
      |> Project.lens.stats.currentCurrencyRate .~ nil
    let reward = .template |> Reward.lens.minimum .~ 1
    let backing = .template
      |> Backing.lens.amount .~ 2
      |> Backing.lens.reward .~ reward

    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      self.vm.inputs.configureWith(project: project, rewardOrBacking: .right(backing))

      self.conversionLabelHidden.assertValues(
        [false],
        "US user viewing non-US project sees conversion."
      )
      self.conversionLabelText.assertValues(["About $2"], "Conversion label rounds up.")
    }
  }

  func testConversionLabel_NonUS_User_US_Project() {
    let project = .template |> Project.lens.country .~ .us
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(config: .template |> Config.lens.countryCode .~ "GB") {
      self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

      self.conversionLabelHidden.assertValues(
        [true],
        "Non-US user viewing US project does not see conversion."
      )
      self.conversionLabelText.assertValueCount(0)
    }
  }

  func testConversionLabel_NonUS_User_NonUS_Project() {
    let project = .template
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.staticUsdRate .~ 2
      |> Project.lens.stats.currentCurrencyRate .~ nil
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(config: .template |> Config.lens.countryCode .~ "GB") {
      self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

      self.conversionLabelHidden.assertValues(
        [true],
        "Non-US user viewing non-US project does not see conversion."
      )
      self.conversionLabelText.assertValueCount(0)
    }
  }

  // MARK: - Pledge Button

  func testPledgeButtonTitle_Reward_NotAllGone() {
    let project = Project.template
      |> Project.lens.country .~ .us

    let reward = Reward.template
      |> Reward.lens.remaining .~ 10
      |> Reward.lens.minimum .~ 1_000

    withEnvironment(locale: Locale(identifier: "en")) {
      self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

      self.pledgeButtonTitleText.assertValues(["Pledge $1,000 or more"])
    }
  }

  func testPledgeButtonEnabled_Reward_NotAllGone() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.remaining .~ 10
      |> Reward.lens.minimum .~ 1_000

    self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

    self.pledgeButtonEnabled.assertValues([true])
  }

  func testPledgeButtonEnabled_Reward_AllGone() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.minimum .~ 1_000

    self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

    self.pledgeButtonEnabled.assertValues([false])
  }

  func testPledgeButtonTapped() {
    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(.template))

    self.vm.inputs.pledgeButtonTapped()

    self.rewardSelected.assertValues([Reward.template.id])
  }

  // MARK: - Card View

  func testRewardCardTapped() {
    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(.template))

    self.vm.inputs.rewardCardTapped()

    self.rewardSelected.assertValues([Reward.template.id])
  }

  func testCardUserInteractionIsEnabled_NotLimitedReward() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.minimum .~ 1_000

    self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

    self.cardUserInteractionIsEnabled.assertValues([true])
  }

  func testCardUserInteractionIsEnabled_NotAllGone() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.remaining .~ 10
      |> Reward.lens.minimum .~ 1_000

    self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

    self.cardUserInteractionIsEnabled.assertValues([true])
  }

  func testCardUserInteractionIsEnabled_AllGone() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.minimum .~ 1_000

    self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

    self.cardUserInteractionIsEnabled.assertValues([false])
  }
}
