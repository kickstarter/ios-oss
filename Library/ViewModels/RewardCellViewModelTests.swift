import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result
import XCTest
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
@testable import Library

final class RewardCellViewModelTests: TestCase {
  fileprivate let vm: RewardCellViewModelType = RewardCellViewModel()

  fileprivate let allGoneHidden = TestObserver<Bool, NoError>()
  fileprivate let cardViewBackgroundColor = TestObserver<UIColor, NoError>()
  fileprivate let cardViewDropShadowHidden = TestObserver<Bool, NoError>()
  fileprivate let conversionLabelHidden = TestObserver<Bool, NoError>()
  fileprivate let conversionLabelText = TestObserver<String, NoError>()
  fileprivate let descriptionLabelHidden = TestObserver<Bool, NoError>()
  fileprivate let descriptionLabelText = TestObserver<String, NoError>()
  fileprivate let estimatedDeliveryDateLabelText = TestObserver<String, NoError>()
  fileprivate let footerLabelText = TestObserver<String, NoError>()
  fileprivate let footerStackViewHidden = TestObserver<Bool, NoError>()
  fileprivate let items = TestObserver<[String], NoError>()
  fileprivate let itemsContainerHidden = TestObserver<Bool, NoError>()
  fileprivate let manageButtonHidden = TestObserver<Bool, NoError>() // todo
  fileprivate let minimumAndConversionLabelsColor = TestObserver<UIColor, NoError>()
  fileprivate let minimumLabelText = TestObserver<String, NoError>()
  fileprivate let notifyDelegateRewardCellWantsExpansion = TestObserver<(), NoError>()
  fileprivate let pledgeButtonHidden = TestObserver<Bool, NoError>() // todo
  fileprivate let pledgeButtonTitleText = TestObserver<String, NoError>() // todo
  fileprivate let titleLabelHidden = TestObserver<Bool, NoError>()
  fileprivate let titleLabelText = TestObserver<String, NoError>()
  fileprivate let titleLabelTextColor = TestObserver<UIColor, NoError>()
  fileprivate let updateTopMarginsForIsBacking = TestObserver<Bool, NoError>() // todo
  fileprivate let viewPledgeButtonHidden = TestObserver<Bool, NoError>() // todo
  fileprivate let youreABackerViewHidden = TestObserver<Bool, NoError>() // todo

  override func setUp() {
    super.setUp()

    self.vm.outputs.allGoneHidden.observe(self.allGoneHidden.observer)
    self.vm.outputs.cardViewBackgroundColor.observe(self.cardViewBackgroundColor.observer)
    self.vm.outputs.cardViewDropShadowHidden.observe(self.cardViewDropShadowHidden.observer)
    self.vm.outputs.conversionLabelHidden.observe(self.conversionLabelHidden.observer)
    self.vm.outputs.conversionLabelText.observe(self.conversionLabelText.observer)
    self.vm.outputs.descriptionLabelHidden.observe(self.descriptionLabelHidden.observer)
    self.vm.outputs.descriptionLabelText.observe(self.descriptionLabelText.observer)
    self.vm.outputs.estimatedDeliveryDateLabelText.observe(self.estimatedDeliveryDateLabelText.observer)
    self.vm.outputs.footerLabelText.observe(self.footerLabelText.observer)
    self.vm.outputs.footerStackViewHidden.observe(self.footerStackViewHidden.observer)
    self.vm.outputs.items.observe(self.items.observer)
    self.vm.outputs.itemsContainerHidden.observe(self.itemsContainerHidden.observer)
    self.vm.outputs.manageButtonHidden.observe(self.manageButtonHidden.observer)
    self.vm.outputs.minimumAndConversionLabelsColor.observe(self.minimumAndConversionLabelsColor.observer)
    self.vm.outputs.minimumLabelText.observe(self.minimumLabelText.observer)
    self.vm.outputs.notifyDelegateRewardCellWantsExpansion
      .observe(self.notifyDelegateRewardCellWantsExpansion.observer)
    self.vm.outputs.pledgeButtonHidden.observe(self.pledgeButtonHidden.observer)
    self.vm.outputs.pledgeButtonTitleText.observe(self.pledgeButtonTitleText.observer)
    self.vm.outputs.titleLabelHidden.observe(self.titleLabelHidden.observer)
    self.vm.outputs.titleLabelText.observe(self.titleLabelText.observer)
    self.vm.outputs.titleLabelTextColor.observe(self.titleLabelTextColor.observer)
    self.vm.outputs.updateTopMarginsForIsBacking.observe(self.updateTopMarginsForIsBacking.observer)
    self.vm.outputs.viewPledgeButtonHidden.observe(self.viewPledgeButtonHidden.observer)
    self.vm.outputs.youreABackerViewHidden.observe(self.youreABackerViewHidden.observer)
  }

  func testAllGoneHidden() {
    self.vm.inputs.configureWith(
      project: .template,
      rewardOrBacking: .left(.template |> Reward.lens.remaining .~ 10)
    )

    self.allGoneHidden.assertValues([true], "All gone indicator is hidden when there are remaining rewards.")

    self.vm.inputs.configureWith(
      project: .template,
      rewardOrBacking: .left(.template |> Reward.lens.remaining .~ 0)
    )

    self.allGoneHidden.assertValues([true, false], "All gone indicator is displayed when none remaining.")

    self.vm.inputs.configureWith(
      project: .template,
      rewardOrBacking: .left(.template |> Reward.lens.remaining .~ nil)
    )

    self.allGoneHidden.assertValues([true, false, true], "All gone indicator hidden when not limited reward.")

    self.vm.inputs.configureWith(
      project: .template |> Project.lens.state .~ .successful,
      rewardOrBacking: .left(.template |> Reward.lens.remaining .~ 0)
    )

    self.allGoneHidden.assertValues([true, false, true, false],
                                    "All gone indicator visible when none remaining and project over.")
  }

  func testCardViewBackgroundColor() {
    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(.template))
    self.vm.inputs.boundStyles()

    self.cardViewBackgroundColor.assertValues([UIColor.white])

    self.vm.inputs.configureWith(project: .template,
                                 rewardOrBacking: .left(.template |> Reward.lens.remaining .~ 0))
    self.cardViewBackgroundColor.assertValues([UIColor.white, UIColor.ksr_grey_100])
  }

  func testCardViewDropShadowHidden_LiveProject_NonBacker_NotAllGone() {
    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(.template))
    self.vm.inputs.boundStyles()

    self.cardViewDropShadowHidden.assertValues([false])
  }

  func testCardViewDropShadowHidden_SuccessfulProject_NonBacker_NotAllGone() {
    self.vm.inputs.configureWith(project: .template |> Project.lens.state .~ .successful,
                                 rewardOrBacking: .left(.template))
    self.vm.inputs.boundStyles()

    self.cardViewDropShadowHidden.assertValues([true])
  }

  func testCardViewDropShadowHidden_LiveProject_Backer_NotAllGone() {
    let reward = Reward.template
    let project = .template
      |> Project.lens.rewards .~ [reward]
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
    )

    self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))
    self.vm.inputs.boundStyles()

    self.cardViewDropShadowHidden.assertValues([false])
  }

  func testCardViewDropShadowHidden_LiveProject_NonBacker_AllGone() {
    self.vm.inputs.configureWith(project: .template,
                                 rewardOrBacking: .left(.template |> Reward.lens.remaining .~ 0))
    self.vm.inputs.boundStyles()

    self.cardViewDropShadowHidden.assertValues([true])
  }

  func testCardViewDropShadowHidden_SuccessfulProject_Backer_NotAllGone() {
    let reward = Reward.template
    let project = .template
      |> Project.lens.state .~ .successful
      |> Project.lens.rewards .~ [reward]
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
    )

    self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))
    self.vm.inputs.boundStyles()

    self.cardViewDropShadowHidden.assertValues([false])
  }

  func testCardViewDropShadowHidden_LiveProject_Backer_AllGone() {
    let reward = Reward.template
      |> Reward.lens.remaining .~ 0
    let project = .template
      |> Project.lens.rewards .~ [reward]
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
    )

    self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))
    self.vm.inputs.boundStyles()

    self.cardViewDropShadowHidden.assertValues([false])
  }

  func testConfiguredWithBacking() {
    let backing = .template
      |> Backing.lens.amount .~ 42
      |> Backing.lens.reward .~ (
        .template
          |> Reward.lens.minimum .~ 30
          |> Reward.lens.title .~ "The goods"
    )

    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .right(backing))
    self.vm.inputs.boundStyles()

    self.minimumLabelText.assertValues(["$42"])
    self.titleLabelText.assertValues(["The goods"])
  }

  func testConfiguredWithBacking_MissingReward() {
    let reward = .template
      |> Reward.lens.minimum .~ 30
      |> Reward.lens.title .~ "The goods"
    let backing = .template
      |> Backing.lens.amount .~ 42
      |> Backing.lens.rewardId .~ reward.id
      |> Backing.lens.reward .~ nil
    let project = .template
      |> Project.lens.rewards .~ [Reward.noReward, reward]
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ backing

    self.vm.inputs.configureWith(project: project, rewardOrBacking: .right(backing))
    self.vm.inputs.boundStyles()

    self.minimumLabelText.assertValues(["$42"])
    self.titleLabelText.assertValues(["The goods"])
  }

  func testConversionLabel_US_User_US_Project_ConfiguredWithReward() {
    let project = .template |> Project.lens.country .~ .US
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

      self.conversionLabelHidden.assertValues([true], "US user viewing US project does not see conversion.")
      self.conversionLabelText.assertValues([])
    }
  }

  func testConversionLabel_US_User_US_Project_ConfiguredWithBacking() {
    let project = .template |> Project.lens.country .~ .US
    let reward = .template |> Reward.lens.minimum .~ 30
    let backing = .template
      |> Backing.lens.amount .~ 42
      |> Backing.lens.reward .~ reward

    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      self.vm.inputs.configureWith(project: project, rewardOrBacking: .right(backing))

      self.conversionLabelHidden.assertValues([true],
                                              "US user viewing US project does not see conversion.")
      self.conversionLabelText.assertValues([])
    }
  }

  func testConversionLabel_US_User_NonUS_Project_ConfiguredWithReward() {
    let project = .template
      |> Project.lens.country .~ .CA
      |> Project.lens.stats.staticUsdRate .~ 0.76
    let reward = .template |> Reward.lens.minimum .~ 1

    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

      self.conversionLabelHidden.assertValues([false], "US user viewing non-US project sees conversion.")
      self.conversionLabelText.assertValues(["About $1"], "Conversion label rounds up.")
    }
  }

  func testConversionLabel_US_User_NonUS_Project_ConfiguredWithBacking() {
    let project = .template
      |> Project.lens.country .~ .CA
      |> Project.lens.stats.staticUsdRate .~ 0.76
    let reward = .template |> Reward.lens.minimum .~ 1
    let backing = .template
      |> Backing.lens.amount .~ 2
      |> Backing.lens.reward .~ reward

    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      self.vm.inputs.configureWith(project: project, rewardOrBacking: .right(backing))

      self.conversionLabelHidden.assertValues([false],
                                              "US user viewing non-US project sees conversion.")
      self.conversionLabelText.assertValues(["About $2"], "Conversion label rounds up.")
    }
  }

  func testConversionLabel_NonUS_User_US_Project() {
    let project = .template |> Project.lens.country .~ .US
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(config: .template |> Config.lens.countryCode .~ "GB") {
      self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

      self.conversionLabelHidden.assertValues([true],
                                              "Non-US user viewing US project does not see conversion.")
      self.conversionLabelText.assertValues([])
    }
  }

  func testConversionLabel_NonUS_User_NonUS_Project() {
    let project = .template |> Project.lens.country .~ .GB |> Project.lens.stats.staticUsdRate .~ 2
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(config: .template |> Config.lens.countryCode .~ "GB") {
      self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

      self.conversionLabelHidden.assertValues([true],
                                              "Non-US user viewing non-US project does not see conversion.")
      self.conversionLabelText.assertValues([])
    }
  }

  func testDescriptionLabelHidden() {
    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(.template))

    self.descriptionLabelHidden.assertValues([false])
  }

  func testDescriptionLabelHidden_SoldOutReward_NonBacker() {
    self.vm.inputs.configureWith(project: .template,
                                 rewardOrBacking: .left(.template |> Reward.lens.remaining .~ 0))

    self.descriptionLabelHidden.assertValues([true])

    self.vm.inputs.tapped()

    self.descriptionLabelHidden.assertValues([true, false])
  }

  func testDescriptionLabelHidden_SoldOutReward_Backer() {

    let reward = .template |> Reward.lens.remaining .~ 0
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.personalization.backing .~ (.template |> Backing.lens.reward .~ reward),
      rewardOrBacking: .left(reward)
    )

    self.descriptionLabelHidden.assertValues([false])
  }

  func testDescriptionLabelText() {
    let reward = Reward.template
    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(reward))
    self.descriptionLabelText.assertValues([reward.description])
  }

  func testEstimatedDeliveryDateLabelText() {
    let estimatedDelivery = 1468527587.32843

    let reward = .template
      |> Reward.lens.estimatedDeliveryOn .~ estimatedDelivery

    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(reward))
    self.estimatedDeliveryDateLabelText.assertValues([Format.date(
      secondsInUTC: estimatedDelivery,
      dateFormat: "MMMM yyyy",
      timeZone: UTCTimeZone)], "Emits the estimated delivery date")
  }

  func testFooterLabelText_NotLimited_NotScheduled_Live() {
    let reward = .template
      |> Reward.lens.backersCount .~ 42
      |> Reward.lens.limit .~ nil
    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(reward))

    self.footerLabelText.assertValues(["42\u{00a0}backers"])
  }

  func testFooterLabelText_Limited_NotScheduled_Live() {
    let reward = .template
      |> Reward.lens.backersCount .~ 42
      |> Reward.lens.limit .~ 100
      |> Reward.lens.remaining .~ 20
    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(reward))

    self.footerLabelText.assertValues(["20\u{00a0}left • 42\u{00a0}backers"])
  }

  func testFooterLabelText_Limited_Scheduled_Live() {
    let reward = .template
      |> Reward.lens.backersCount .~ 42
      |> Reward.lens.limit .~ 100
      |> Reward.lens.remaining .~ 20
      |> Reward.lens.endsAt
      .~ self.dateType.init().addingTimeInterval(60 * 60 * 24 * 3).timeIntervalSince1970

    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(reward))

    self.footerLabelText.assertValues(["3\u{00a0}days\u{00a0}left • 20\u{00a0}left • 42\u{00a0}backers"])
  }

  func testFooterLabelText_NotLimited_Scheduled_Live() {
    let reward = .template
      |> Reward.lens.backersCount .~ 42
      |> Reward.lens.limit .~ nil
      |> Reward.lens.endsAt
      .~ self.dateType.init().addingTimeInterval(60 * 60 * 24 * 3).timeIntervalSince1970

    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(reward))

    self.footerLabelText.assertValues(["3\u{00a0}days\u{00a0}left • 42\u{00a0}backers"])
  }

  func testFooterLabelText_NotLimited_BadScheduledData_Live() {
    let reward = .template
      |> Reward.lens.backersCount .~ 42
      |> Reward.lens.limit .~ nil
      |> Reward.lens.endsAt .~ 0

    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(reward))

    self.footerLabelText.assertValues(["42\u{00a0}backers"])
  }

  func testFooterLabelText_NotLimited_Expired_Live() {
    let reward = .template
      |> Reward.lens.backersCount .~ 42
      |> Reward.lens.limit .~ nil
      |> Reward.lens.endsAt
        .~ self.dateType.init().addingTimeInterval(-60 * 60 * 24 * 3).timeIntervalSince1970

    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(reward))

    self.footerLabelText.assertValues(["42\u{00a0}backers"])
  }

  func testFooterViewHidden() {
    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(.template))

    self.footerStackViewHidden.assertValues([false])

    self.vm.inputs.configureWith(project: .template,
                                 rewardOrBacking: .left(.template |> Reward.lens.remaining .~ 0))

    self.footerStackViewHidden.assertValues([false, true])

    let reward = .template |> Reward.lens.remaining .~ 0
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.personalization.backing .~ (.template |> Backing.lens.reward .~ reward),
      rewardOrBacking: .left(reward)
    )

    self.footerStackViewHidden.assertValues([false, true, false])
  }

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
        ),
    ]

    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(reward))

    self.items.assertValues([["The thing", "(1,000) The other thing"]])
    self.itemsContainerHidden.assertValues([false])
  }

  func testItemsContainerHidden_WithItems() {
    let reward = .template
      |> Reward.lens.rewardsItems .~ [.template]

    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(reward))

    self.itemsContainerHidden.assertValues([false])
  }

  func testItemsContainerHidden_WithNoItems() {
    self.vm.inputs.configureWith(project: .template,
                                 rewardOrBacking: .left(.template |> Reward.lens.rewardsItems .~ []))

    self.itemsContainerHidden.assertValues([true])
  }

  func testItemsContainerHidden_SoldOut_WithItems_OnTap() {
    let reward = .template
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.rewardsItems .~ [.template]

    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(reward))

    self.itemsContainerHidden.assertValues([true])

    self.vm.inputs.tapped()

    self.itemsContainerHidden.assertValues([true, false])
  }

  func testItemsContainerHidden_SoldOut_WithNoItems_OnTap() {
    let reward = .template
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.rewardsItems .~ []

    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(reward))

    self.itemsContainerHidden.assertValues([true])

    self.vm.inputs.tapped()

    self.itemsContainerHidden.assertValues([true])
  }

  func testManageButtonHidden_LiveProject_NonBacker() {
    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(.template))
    self.manageButtonHidden.assertValues([true])
  }

  func testManageButtonHidden_SuccessfulProject_NonBacker() {
    self.vm.inputs.configureWith(project: .template |> Project.lens.state .~ .successful,
                                 rewardOrBacking: .left(.template))
    self.manageButtonHidden.assertValues([true])
  }

  func testManageButtonHidden_LiveProject_Backer() {
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.personalization.backing .~ (.template |> Backing.lens.reward .~ .template),
      rewardOrBacking: .left(.template)
    )
    self.manageButtonHidden.assertValues([false])
  }

  func testManageButtonHidden_SuccessfulProject_Backer() {
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.backing .~ (.template |> Backing.lens.reward .~ .template),
      rewardOrBacking: .left(.template)
    )
    self.manageButtonHidden.assertValues([true])
  }

  func testMinimumLabel_NotAllGone() {
    let project = Project.template
    let reward = .template |> Reward.lens.minimum .~ 1_000

    self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

    self.minimumLabelText.assertValues([Format.currency(reward.minimum, country: project.country)])
    self.minimumAndConversionLabelsColor.assertValues([.ksr_text_green_700])
  }

  func testMinimumLabel_AllGone() {
    let project = Project.template
    let reward = .template
      |> Reward.lens.minimum .~ 1_000
      |> Reward.lens.remaining .~ 0

    self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

    self.minimumLabelText.assertValues([Format.currency(reward.minimum, country: project.country)])
    self.minimumAndConversionLabelsColor.assertValues([.ksr_text_dark_grey_400])
  }

  func testMinimumLabel_NoReward() {
    let project = Project.template
    let reward = Reward.noReward

    self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

    self.minimumLabelText.assertValues(["Pledge $1 or more"])
  }

  func testNotifyDelegateRewardCellWantsExpansion_NotSoldOut() {
    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(.template))

    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.tapped()

    self.notifyDelegateRewardCellWantsExpansion.assertValueCount(0)
    XCTAssertEqual([], self.trackingClient.events)
  }

  func testNotifyDelegateRewardCellWantsExpansion_SoldOut() {
    let reward = .template |> Reward.lens.remaining .~ 0

    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(reward))

    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.tapped()

    self.notifyDelegateRewardCellWantsExpansion.assertValueCount(1)
    XCTAssertEqual(["Expanded Unavailable Reward"], self.trackingClient.events)
  }

  func testTitleLabel_NoTitle() {
    let reward = .template
      |> Reward.lens.title .~ nil
      |> Reward.lens.remaining .~ nil

    self.vm.inputs.configureWith(
      project: .template,
      rewardOrBacking: .left(reward)
    )

    self.titleLabelHidden.assertValues([true])
    self.titleLabelText.assertValues([""])
    self.titleLabelTextColor.assertValues([.ksr_text_dark_grey_900])
  }

  func testTitleLabel_WithTitle_NotAllGone() {
    let reward = .template
      |> Reward.lens.title .~ "The thing"
      |> Reward.lens.remaining .~ nil

    self.vm.inputs.configureWith(
      project: .template,
      rewardOrBacking: .left(reward)
    )

    self.titleLabelHidden.assertValues([false])
    self.titleLabelText.assertValues(["The thing"])
    self.titleLabelTextColor.assertValues([.ksr_text_dark_grey_900])
  }

  func testTitleLabel_WithTitle_AllGone() {
    let reward = .template
      |> Reward.lens.title .~ "The thing"
      |> Reward.lens.remaining .~ 0

    self.vm.inputs.configureWith(
      project: .template,
      rewardOrBacking: .left(reward)
    )

    self.titleLabelHidden.assertValues([false])
    self.titleLabelText.assertValues(["The thing"])
    self.titleLabelTextColor.assertValues([.ksr_text_dark_grey_500])
  }

  func testTitleLabelColor_WithTitle_AllGone_NonLive() {
    let reward = .template
      |> Reward.lens.title .~ "The thing"
      |> Reward.lens.remaining .~ 0

    self.vm.inputs.configureWith(
      project: .template |> Project.lens.state .~ .successful,
      rewardOrBacking: .left(reward)
    )

    self.titleLabelTextColor.assertValues([.ksr_text_dark_grey_900])
  }

  func testYoureABacker_WhenYoureABacker() {
    let reward = .template |> Reward.lens.id .~ 1

    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.personalization.backing .~ (
          .template
            |> Backing.lens.rewardId .~ reward.id
            |> Backing.lens.reward .~ reward
      ),
      rewardOrBacking: .left(reward)
    )

    self.youreABackerViewHidden.assertValues([false])
  }

  func testYoureABacker_WhenYoureNotABacker() {
    self.vm.inputs.configureWith(
      project: .template,
      rewardOrBacking: .left(.template |> Reward.lens.id .~ 1)
    )

    self.youreABackerViewHidden.assertValues([true])
  }

  func testYoureABacker_WhenYoureBackingADifferentReward() {
    let reward = .template |> Reward.lens.id .~ 1
    let backingReward = .template |> Reward.lens.id .~ 2

    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.personalization.backing .~ (
          .template
            |> Backing.lens.rewardId .~ backingReward.id
            |> Backing.lens.reward .~ backingReward
      ),
      rewardOrBacking: .left(reward)
    )

    self.youreABackerViewHidden.assertValues([true])
  }

  func testMinimumLabel_AllGoneUserIsNonBackerLiveProject() {
    let reward = .template
      |> Reward.lens.minimum .~ 1_000
      |> Reward.lens.remaining .~ 0
    let project = .template
      |> Project.lens.state .~ .live

    withEnvironment(currentUser: .template) {
      self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

      self.minimumLabelText.assertValues([Format.currency(reward.minimum, country: project.country)])

      self.minimumAndConversionLabelsColor.assertValues([.ksr_text_dark_grey_400])
    }
  }

  func testMinimumLabel_AllGoneUserIsNonBackerNonLiveProject() {
    let reward = .template
      |> Reward.lens.minimum .~ 1_000
      |> Reward.lens.remaining .~ 0
    let project = .template
      |> Project.lens.state .~ .successful

    withEnvironment(currentUser: .template) {
      self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

      self.minimumLabelText.assertValues([Format.currency(reward.minimum, country: project.country)])

      self.minimumAndConversionLabelsColor.assertValues([.ksr_text_dark_grey_400])
    }
  }

  func testMinimumLabel_AllGoneUserIsBackerLiveProject() {
    let reward = .template
      |> Reward.lens.minimum .~ 1_000
      |> Reward.lens.remaining .~ 0
    let project = .template
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
    )

    withEnvironment(currentUser: .template) {
      self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

      self.minimumLabelText.assertValues([Format.currency(reward.minimum, country: project.country)])

      self.minimumAndConversionLabelsColor.assertValues([.ksr_text_green_700])
    }
  }

  func testMinimumLabel_AllGoneUserIsBackerNonLiveProject() {
    let reward = .template
      |> Reward.lens.minimum .~ 1_000
      |> Reward.lens.remaining .~ 0
    let project = .template
      |> Project.lens.state .~ .successful
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
    )

    withEnvironment(currentUser: .template) {
      self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

      self.minimumLabelText.assertValues([Format.currency(reward.minimum, country: project.country)])

      self.minimumAndConversionLabelsColor.assertValues([.ksr_text_dark_grey_500])
    }
  }

  func testMinimumLabel_LiveProject() {
    let project = .template
      |> Project.lens.state .~ .live
    let reward = Reward.template

    self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

    self.minimumLabelText.assertValues([Format.currency(reward.minimum, country: project.country)])

    self.minimumAndConversionLabelsColor.assertValues([.ksr_text_green_700])
  }

  func testMinimumLabel_NonLiveProject() {
    let project = .template
      |> Project.lens.state .~ .successful
    let reward = Reward.template

    self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

    self.minimumLabelText.assertValues([Format.currency(reward.minimum, country: project.country)])

    self.minimumAndConversionLabelsColor.assertValues([.ksr_text_dark_grey_900])
  }
}
