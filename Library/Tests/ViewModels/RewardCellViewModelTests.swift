import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result
import XCTest
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
@testable import Library

final class RewardCellViewModelTests: TestCase {
  private let vm: RewardCellViewModelType = RewardCellViewModel()

  private let allGoneHidden = TestObserver<Bool, NoError>()
  private let backersCountLabelText = TestObserver<String, NoError>()
  private let cardViewBackgroundColor = TestObserver<UIColor, NoError>()
  private let cardViewDropShadowHidden = TestObserver<Bool, NoError>()
  private let contentViewBackgroundColor = TestObserver<UIColor, NoError>()
  private let conversionLabelHidden = TestObserver<Bool, NoError>()
  private let conversionLabelText = TestObserver<String, NoError>()
  private let descriptionLabelHidden = TestObserver<Bool, NoError>()
  private let descriptionLabelText = TestObserver<String, NoError>()
  private let footerStackViewAlignment = TestObserver<UIStackViewAlignment, NoError>()
  private let footerStackViewAxis = TestObserver<UILayoutConstraintAxis, NoError>()
  private let footerStackViewHidden = TestObserver<Bool, NoError>()
  private let items = TestObserver<[String], NoError>()
  private let itemsContainerHidden = TestObserver<Bool, NoError>()
  private let manageButtonHidden = TestObserver<Bool, NoError>() // todo
  private let minimumAndConversionLabelsColor = TestObserver<UIColor, NoError>()
  private let minimumLabelText = TestObserver<String, NoError>()
  private let pledgeButtonHidden = TestObserver<Bool, NoError>() // todo
  private let pledgeButtonTitleText = TestObserver<String, NoError>() // todo
  private let remainingStackViewHidden = TestObserver<Bool, NoError>()
  private let remainingLabelText = TestObserver<String, NoError>()
  private let titleLabelHidden = TestObserver<Bool, NoError>()
  private let titleLabelText = TestObserver<String, NoError>()
  private let titleLabelTextColor = TestObserver<UIColor, NoError>()
  private let updateTopMarginsForIsBacking = TestObserver<Bool, NoError>() // todo
  private let viewPledgeButtonHidden = TestObserver<Bool, NoError>() // todo
  private let youreABackerViewHidden = TestObserver<Bool, NoError>() // todo

  override func setUp() {
    super.setUp()

    self.vm.outputs.allGoneHidden.observe(self.allGoneHidden.observer)
    self.vm.outputs.backersCountLabelText.observe(self.backersCountLabelText.observer)
    self.vm.outputs.cardViewBackgroundColor.observe(self.cardViewBackgroundColor.observer)
    self.vm.outputs.cardViewDropShadowHidden.observe(self.cardViewDropShadowHidden.observer)
    self.vm.outputs.contentViewBackgroundColor.observe(self.contentViewBackgroundColor.observer)
    self.vm.outputs.conversionLabelHidden.observe(self.conversionLabelHidden.observer)
    self.vm.outputs.conversionLabelText.observe(self.conversionLabelText.observer)
    self.vm.outputs.descriptionLabelHidden.observe(self.descriptionLabelHidden.observer)
    self.vm.outputs.descriptionLabelText.observe(self.descriptionLabelText.observer)
    self.vm.outputs.footerStackViewAlignment.observe(self.footerStackViewAlignment.observer)
    self.vm.outputs.footerStackViewAxis.observe(self.footerStackViewAxis.observer)
    self.vm.outputs.footerStackViewHidden.observe(self.footerStackViewHidden.observer)
    self.vm.outputs.items.observe(self.items.observer)
    self.vm.outputs.itemsContainerHidden.observe(self.itemsContainerHidden.observer)
    self.vm.outputs.manageButtonHidden.observe(self.manageButtonHidden.observer)
    self.vm.outputs.minimumAndConversionLabelsColor.observe(self.minimumAndConversionLabelsColor.observer)
    self.vm.outputs.minimumLabelText.observe(self.minimumLabelText.observer)
    self.vm.outputs.pledgeButtonHidden.observe(self.pledgeButtonHidden.observer)
    self.vm.outputs.pledgeButtonTitleText.observe(self.pledgeButtonTitleText.observer)
    self.vm.outputs.remainingStackViewHidden.observe(self.remainingStackViewHidden.observer)
    self.vm.outputs.remainingLabelText.observe(self.remainingLabelText.observer)
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
      reward: .template |> Reward.lens.remaining .~ 10
    )

    self.allGoneHidden.assertValues([true], "All gone indicator is hidden when there are remaining rewards.")

    self.vm.inputs.configureWith(
      project: .template,
      reward: .template |> Reward.lens.remaining .~ 0
    )

    self.allGoneHidden.assertValues([true, false], "All gone indicator is displayed when none remaining.")

    self.vm.inputs.configureWith(
      project: .template,
      reward: .template |> Reward.lens.remaining .~ nil
    )

    self.allGoneHidden.assertValues([true, false, true], "All gone indicator hidden when not limited reward.")
  }

  func testBackersCountLabelText() {
    self.vm.inputs.configureWith(
      project: .template,
      reward: .template |> Reward.lens.backersCount .~ 1_000
    )

    self.backersCountLabelText.assertValues([Strings.general_backer_count_backers(backer_count: 1_000)])
  }

  func testBackersCountLabelText_WithBadData() {
    self.vm.inputs.configureWith(
      project: .template,
      reward: .template |> Reward.lens.backersCount .~ nil
    )

    self.backersCountLabelText.assertValues([Strings.general_backer_count_backers(backer_count: 0)])
  }

  func testCardViewBackgroundColor() {
    self.vm.inputs.configureWith(project: .template, reward: .template)
    self.vm.inputs.boundStyles()

    self.cardViewBackgroundColor.assertValues([UIColor.whiteColor()])

    self.vm.inputs.configureWith(project: .template, reward: .template |> Reward.lens.remaining .~ 0)
    self.cardViewBackgroundColor.assertValues([UIColor.whiteColor(), UIColor.ksr_grey_100])
  }

  func testCardViewDropShadowHidden_LiveProject_NonBacker_NotAllGone() {
    self.vm.inputs.configureWith(project: .template, reward: .template)
    self.vm.inputs.boundStyles()

    self.cardViewDropShadowHidden.assertValues([false])
  }

  func testCardViewDropShadowHidden_SuccessfulProject_NonBacker_NotAllGone() {
    self.vm.inputs.configureWith(project: .template |> Project.lens.state .~ .successful, reward: .template)
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

    self.vm.inputs.configureWith(project: project, reward: reward)
    self.vm.inputs.boundStyles()

    self.cardViewDropShadowHidden.assertValues([false])
  }

  func testCardViewDropShadowHidden_LiveProject_NonBacker_AllGone() {
    self.vm.inputs.configureWith(project: .template, reward: .template |> Reward.lens.remaining .~ 0)
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

    self.vm.inputs.configureWith(project: project, reward: reward)
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

    self.vm.inputs.configureWith(project: project, reward: reward)
    self.vm.inputs.boundStyles()

    self.cardViewDropShadowHidden.assertValues([false])
  }

  func testContentViewBackgroundColor() {
    self.vm.inputs.configureWith(
      project: .template |> Project.lens.category .~ .art,
      reward: .template
    )

    self.contentViewBackgroundColor.assertValues([UIColor.ksr_red_100.colorWithAlphaComponent(0.65)])

    self.vm.inputs.configureWith(
      project: .template |> Project.lens.category .~ .filmAndVideo,
      reward: .template
    )

    self.contentViewBackgroundColor.assertValues([
      UIColor.ksr_red_100.colorWithAlphaComponent(0.65),
      UIColor.ksr_beige_400.colorWithAlphaComponent(0.65),
      ])

    self.vm.inputs.configureWith(
      project: .template |> Project.lens.category .~ .games,
      reward: .template
    )

    self.contentViewBackgroundColor.assertValues([
      UIColor.ksr_red_100.colorWithAlphaComponent(0.65),
      UIColor.ksr_beige_400.colorWithAlphaComponent(0.65),
      UIColor.ksr_violet_200.colorWithAlphaComponent(0.65),
      ])
  }

  func testConversionLabel_US_User_US_Project() {
    let project = .template |> Project.lens.country .~ .US
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      self.vm.inputs.configureWith(project: project, reward: reward)

      self.conversionLabelHidden.assertValues([true], "US user viewing US project does not see conversion.")
      self.conversionLabelText.assertValues([])
    }
  }

  func testConversionLabel_US_User_NonUS_Project() {
    let project = .template |> Project.lens.country .~ .GB |> Project.lens.stats.staticUsdRate .~ 1.0026
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      self.vm.inputs.configureWith(project: project, reward: reward)

      self.conversionLabelHidden.assertValues([false], "US user viewing non-US project sees conversion.")
      self.conversionLabelText.assertValues([
        Strings.rewards_title_about_amount_usd(reward_amount: Format.currency(1_003, country: .US))
        ], "Conversion label rounds up.")
    }
  }

  func testConversionLabel_NonUS_User_US_Project() {
    let project = .template |> Project.lens.country .~ .US
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(config: .template |> Config.lens.countryCode .~ "GB") {
      self.vm.inputs.configureWith(project: project, reward: reward)

      self.conversionLabelHidden.assertValues([true],
                                              "Non-US user viewing US project does not see conversion.")
      self.conversionLabelText.assertValues([])
    }
  }

  func testConversionLabel_NonUS_User_NonUS_Project() {
    let project = .template |> Project.lens.country .~ .GB |> Project.lens.stats.staticUsdRate .~ 2
    let reward = .template |> Reward.lens.minimum .~ 1_000

    withEnvironment(config: .template |> Config.lens.countryCode .~ "GB") {
      self.vm.inputs.configureWith(project: project, reward: reward)

      self.conversionLabelHidden.assertValues([true],
                                              "Non-US user viewing non-US project does not see conversion.")
      self.conversionLabelText.assertValues([])
    }
  }

  func testDescriptionLabelHidden() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.descriptionLabelHidden.assertValues([false])

    self.vm.inputs.configureWith(project: .template, reward: .template |> Reward.lens.remaining .~ 0)

    self.descriptionLabelHidden.assertValues([false, true])

    let reward = .template |> Reward.lens.remaining .~ 0
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.personalization.backing .~ (.template |> Backing.lens.reward .~ reward),
      reward: reward
    )

    self.descriptionLabelHidden.assertValues([false, true, false])
  }

  func testDescriptionLabelText() {
    let reward = Reward.template
    self.vm.inputs.configureWith(project: .template, reward: reward)
    self.descriptionLabelText.assertValues([reward.description])
  }

  func testFooterStackView_LanguageEn() {
    withEnvironment(language: .en) {
      self.vm.inputs.configureWith(project: .template, reward: .template)

      self.footerStackViewAxis.assertValues([.Horizontal],
                                            "Footer stack view is horizontal in english.")
      self.footerStackViewAlignment.assertValues([.Center],
                                                 "Footer stack view is center aligned in english.")
    }
  }

  func testFooterStackView_LanguageNonEn() {
    withEnvironment(language: .es) {
      self.vm.inputs.configureWith(project: .template, reward: .template)

      self.footerStackViewAxis.assertValues([.Vertical],
                                            "Footer stack view is vertical in non-english languages.")
      self.footerStackViewAlignment.assertValues([.Leading],
                                                 "Footer stack view is leading aligned in english.")
    }
  }

  func testFooterStackViewHidden() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.footerStackViewHidden.assertValues([false])

    self.vm.inputs.configureWith(project: .template, reward: .template |> Reward.lens.remaining .~ 0)

    self.footerStackViewHidden.assertValues([false, true])

    let reward = .template |> Reward.lens.remaining .~ 0
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.personalization.backing .~ (.template |> Backing.lens.reward .~ reward),
      reward: reward
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

    self.vm.inputs.configureWith(project: .template, reward: reward)

    self.items.assertValues([["The thing", "(1,000) The other thing"]])
    self.itemsContainerHidden.assertValues([false])
  }

  func testItemsContainerHidden() {
    self.vm.inputs.configureWith(project: .template, reward: .template |> Reward.lens.rewardsItems .~ [])

    self.itemsContainerHidden.assertValues([true])
  }

  func testManageButtonHidden_LiveProject_NonBacker() {
    self.vm.inputs.configureWith(project: .template, reward: .template)
    self.manageButtonHidden.assertValues([true])
  }

  func testManageButtonHidden_SuccessfulProject_NonBacker() {
    self.vm.inputs.configureWith(project: .template |> Project.lens.state .~ .successful, reward: .template)
    self.manageButtonHidden.assertValues([true])
  }

  func testManageButtonHidden_LiveProject_Backer() {
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.personalization.backing .~ (.template |> Backing.lens.reward .~ .template),
      reward: .template
    )
    self.manageButtonHidden.assertValues([false])
  }

  func testManageButtonHidden_SuccessfulProject_Backer() {
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.backing .~ (.template |> Backing.lens.reward .~ .template),
      reward: .template
    )
    self.manageButtonHidden.assertValues([true])
  }

  func testMinimumLabel_NotAllGone() {
    let project = Project.template
    let reward = .template |> Reward.lens.minimum .~ 1_000

    self.vm.inputs.configureWith(project: project, reward: reward)

    self.minimumLabelText.assertValues([Format.currency(reward.minimum, country: project.country)])
    self.minimumAndConversionLabelsColor.assertValues([.ksr_text_green_700])
  }

  func testMinimumLabel_AllGone() {
    let project = Project.template
    let reward = .template
      |> Reward.lens.minimum .~ 1_000
      |> Reward.lens.remaining .~ 0

    self.vm.inputs.configureWith(project: project, reward: reward)

    self.minimumLabelText.assertValues([Format.currency(reward.minimum, country: project.country)])
    self.minimumAndConversionLabelsColor.assertValues([.ksr_text_navy_500])
  }

  func testRemainingStackView() {
    self.vm.inputs.configureWith(
      project: .template,
      reward: .template |> Reward.lens.limit .~ nil
    )

    self.remainingStackViewHidden.assertValues([true])

    self.vm.inputs.configureWith(
      project: .template,
      reward: .template |> Reward.lens.limit .~ 100
    )

    self.remainingStackViewHidden.assertValues([true, false])

    self.vm.inputs.configureWith(
      project: .template |> Project.lens.state .~ .successful,
      reward: .template |> Reward.lens.limit .~ 100
    )

    self.remainingStackViewHidden.assertValues([true, false, true])
  }

  func testRemainingLabel() {
    self.vm.inputs.configureWith(
      project: .template,
      reward: .template
        |> Reward.lens.limit .~ 1_000
        |> Reward.lens.remaining .~ 1_000
    )

    self.remainingLabelText.assertValues(["1,000 left"])
  }

  func testTitleLabel_NoTitle() {
    self.vm.inputs.configureWith(
      project: .template,
      reward: .template
        |> Reward.lens.title .~ nil
        |> Reward.lens.remaining .~ nil
    )

    self.titleLabelHidden.assertValues([true])
    self.titleLabelText.assertValues([""])
    self.titleLabelTextColor.assertValues([.ksr_text_navy_700])
  }

  func testTitleLabel_WithTitle_NotAllGone() {
    self.vm.inputs.configureWith(
      project: .template,
      reward: .template
        |> Reward.lens.title .~ "The thing"
        |> Reward.lens.remaining .~ nil
    )

    self.titleLabelHidden.assertValues([false])
    self.titleLabelText.assertValues(["The thing"])
    self.titleLabelTextColor.assertValues([.ksr_text_navy_700])
  }

  func testTitleLabel_WithTitle_AllGone() {
    self.vm.inputs.configureWith(
      project: .template,
      reward: .template
        |> Reward.lens.title .~ "The thing"
        |> Reward.lens.remaining .~ 0
    )

    self.titleLabelHidden.assertValues([false])
    self.titleLabelText.assertValues(["The thing"])
    self.titleLabelTextColor.assertValues([.ksr_text_navy_500])
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
      reward: reward
    )

    self.youreABackerViewHidden.assertValues([false])
  }

  func testYoureABacker_WhenYoureNotABacker() {
    self.vm.inputs.configureWith(
      project: .template,
      reward: .template |> Reward.lens.id .~ 1
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
      reward: reward
    )

    self.youreABackerViewHidden.assertValues([true])
  }
}
