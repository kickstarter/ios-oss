import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result
import XCTest
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
@testable import Library

final class ProjectHeaderViewModelTests: TestCase {
  private let vm: ProjectHeaderViewModelType = ProjectHeaderViewModel()

  private let allStatsStackViewAccessibilityValue = TestObserver<String, NoError>()
  private let youreABackerLabelHidden = TestObserver<Bool, NoError>()
  private let backersTitleLabelText = TestObserver<String, NoError>()
  private let campaignButtonSelected = TestObserver<Bool, NoError>()
  private let campaignSelectedViewHidden = TestObserver<Bool, NoError>()
  private let commentsButtonAccessibilityLabel = TestObserver<String, NoError>()
  private let commentsLabelText = TestObserver<String, NoError>()
  private let configureVideoViewControllerWithProject = TestObserver<Project, NoError>()
  private let conversionLabelHidden = TestObserver<Bool, NoError>()
  private let conversionLabelText = TestObserver<String, NoError>()
  private let deadlineSubtitleLabelText = TestObserver<String, NoError>()
  private let deadlineTitleLabelText = TestObserver<String, NoError>()
  private let goToComments = TestObserver<Project, NoError>()
  private let notifyDelegateToShowCampaignTab = TestObserver<(), NoError>()
  private let notifyDelegateToShowRewardsTab = TestObserver<(), NoError>()
  private let pledgedSubtitleLabelText = TestObserver<String, NoError>()
  private let pledgedTitleLabelText = TestObserver<String, NoError>()
  private let projectNameAndBlurbLabelText = TestObserver<String, NoError>()
  private let rewardsButtonAccessibilityLabel = TestObserver<String, NoError>()
  private let rewardsTabButtonSelected = TestObserver<Bool, NoError>()
  private let rewardsTabButtonTitleText = TestObserver<String, NoError>()
  private let rewardsLabelText = TestObserver<String, NoError>()
  private let rewardsSelectedViewHidden = TestObserver<Bool, NoError>()
  private let updatesButtonAccessibilityLabel = TestObserver<String, NoError>()
  private let updatesLabelText = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.allStatsStackViewAccessibilityValue
      .observe(self.allStatsStackViewAccessibilityValue.observer)
    self.vm.outputs.youreABackerLabelHidden.observe(self.youreABackerLabelHidden.observer)
    self.vm.outputs.backersTitleLabelText.observe(self.backersTitleLabelText.observer)
    self.vm.outputs.campaignButtonSelected.observe(self.campaignButtonSelected.observer)
    self.vm.outputs.campaignSelectedViewHidden.observe(self.campaignSelectedViewHidden.observer)
    self.vm.outputs.configureVideoViewControllerWithProject
      .observe(self.configureVideoViewControllerWithProject.observer)
    self.vm.outputs.commentsButtonAccessibilityLabel.observe(self.commentsButtonAccessibilityLabel.observer)
    self.vm.outputs.commentsLabelText.observe(self.commentsLabelText.observer)
    self.vm.outputs.conversionLabelHidden.observe(self.conversionLabelHidden.observer)
    self.vm.outputs.conversionLabelText.observe(self.conversionLabelText.observer)
    self.vm.outputs.deadlineSubtitleLabelText.observe(self.deadlineSubtitleLabelText.observer)
    self.vm.outputs.deadlineTitleLabelText.observe(self.deadlineTitleLabelText.observer)
    self.vm.outputs.goToComments.observe(self.goToComments.observer)
    self.vm.outputs.notifyDelegateToShowCampaignTab.observe(self.notifyDelegateToShowCampaignTab.observer)
    self.vm.outputs.notifyDelegateToShowRewardsTab.observe(self.notifyDelegateToShowRewardsTab.observer)
    self.vm.outputs.pledgedSubtitleLabelText.observe(self.pledgedSubtitleLabelText.observer)
    self.vm.outputs.pledgedTitleLabelText.observe(self.pledgedTitleLabelText.observer)
    self.vm.outputs.projectNameAndBlurbLabelText.observe(self.projectNameAndBlurbLabelText.observer)
    self.vm.outputs.rewardsButtonAccessibilityLabel.observe(self.rewardsButtonAccessibilityLabel.observer)
    self.vm.outputs.rewardsTabButtonSelected.observe(self.rewardsTabButtonSelected.observer)
    self.vm.outputs.rewardsTabButtonTitleText.observe(self.rewardsTabButtonTitleText.observer)
    self.vm.outputs.rewardsLabelText.observe(self.rewardsLabelText.observer)
    self.vm.outputs.rewardsSelectedViewHidden.observe(self.rewardsSelectedViewHidden.observer)
    self.vm.outputs.updatesButtonAccessibilityLabel.observe(self.updatesButtonAccessibilityLabel.observer)
    self.vm.outputs.updatesLabelText.observe(self.updatesLabelText.observer)
  }

  func testAllStatsStackViewAccessibilityValue() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.allStatsStackViewAccessibilityValue.assertValueCount(1)
  }

  func testConfigureVideoViewControllerWithProject() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.configureVideoViewControllerWithProject.assertValues([project])
  }

  func testYoureABackerLabelHidden_NotABacker() {
    let project = .template |> Project.lens.personalization.isBacking .~ false
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.youreABackerLabelHidden.assertValues([true])
  }

  func testYoureABackerLabelHidden_LoggedOut() {
    let project = .template |> Project.lens.personalization.isBacking .~ nil
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.youreABackerLabelHidden.assertValues([true])
  }

  func testYoureABackerLabelHidden_Backer() {
    let project = .template |> Project.lens.personalization.isBacking .~ true
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.youreABackerLabelHidden.assertValues([false])
  }

  func testBackersTitleLabel() {
    let project = .template |> Project.lens.stats.backersCount .~ 1_000
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.backersTitleLabelText.assertValues([Format.wholeNumber(project.stats.backersCount)])
  }

  func testCampaignRewardTabs() {
    self.vm.inputs.configureWith(project: .template)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.campaignButtonSelected.assertValues([true])
    self.campaignSelectedViewHidden.assertValues([false])
    self.rewardsTabButtonSelected.assertValues([false])
    self.rewardsSelectedViewHidden.assertValues([true])
    self.notifyDelegateToShowCampaignTab.assertValueCount(1)
    self.notifyDelegateToShowRewardsTab.assertValueCount(0)

    self.vm.inputs.rewardsTabButtonTapped()

    self.campaignButtonSelected.assertValues([true, false])
    self.campaignSelectedViewHidden.assertValues([false, true])
    self.rewardsTabButtonSelected.assertValues([false, true])
    self.rewardsSelectedViewHidden.assertValues([true, false])
    self.notifyDelegateToShowCampaignTab.assertValueCount(1)
    self.notifyDelegateToShowRewardsTab.assertValueCount(1)

    self.vm.inputs.rewardsTabButtonTapped()

    self.campaignButtonSelected.assertValues([true, false])
    self.campaignSelectedViewHidden.assertValues([false, true])
    self.rewardsTabButtonSelected.assertValues([false, true])
    self.rewardsSelectedViewHidden.assertValues([true, false])
    self.notifyDelegateToShowCampaignTab.assertValueCount(1)
    self.notifyDelegateToShowRewardsTab.assertValueCount(1)

    self.vm.inputs.campaignTabButtonTapped()

    self.campaignButtonSelected.assertValues([true, false, true])
    self.campaignSelectedViewHidden.assertValues([false, true, false])
    self.rewardsTabButtonSelected.assertValues([false, true, false])
    self.rewardsSelectedViewHidden.assertValues([true, false, true])
    self.notifyDelegateToShowCampaignTab.assertValueCount(2)
    self.notifyDelegateToShowRewardsTab.assertValueCount(1)

    self.vm.inputs.rewardsButtonTapped()

    self.campaignButtonSelected.assertValues([true, false, true, false])
    self.campaignSelectedViewHidden.assertValues([false, true, false, true])
    self.rewardsTabButtonSelected.assertValues([false, true, false, true])
    self.rewardsSelectedViewHidden.assertValues([true, false, true, false])
    self.notifyDelegateToShowCampaignTab.assertValueCount(2)
    self.notifyDelegateToShowRewardsTab.assertValueCount(2)
  }

  func testCommentsButtonAccessibilityLabel() {
    self.vm.inputs.configureWith(project: .template |> Project.lens.stats.commentsCount .~ 1_000)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.commentsButtonAccessibilityLabel.assertValues(["1,000 comments"])
  }

  func testCommentsLabel() {
    let project = Project.template |> Project.lens.stats.commentsCount .~ 1_000
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.commentsLabelText.assertValues([Format.wholeNumber(1_000)])
  }

  func testCommentsLabelWithBadData() {
    let project = Project.template |> Project.lens.stats.commentsCount .~ nil
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.commentsLabelText.assertValues([Format.wholeNumber(0)])
  }

  func testConversionLabel_WhenConversionNotNeeded_US_Project_US_User() {
    let project = .template
      |> Project.lens.country .~ .US
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      self.conversionLabelText.assertValueCount(0)
      self.conversionLabelHidden.assertValues([true])
    }
  }

  func testConversionLabel_WhenConversionNotNeeded_US_Project_NonUS_User() {
    let project = .template
      |> Project.lens.country .~ .US
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    withEnvironment(config: .template |> Config.lens.countryCode .~ "FR") {
      self.conversionLabelText.assertValueCount(0)
      self.conversionLabelHidden.assertValues([true])
    }
  }

  func testConversionLabel_WhenConversionNeeded_NonUS_Project_US_User() {
    let project = .template
      |> Project.lens.country .~ .GB
      |> Project.lens.stats.goal .~ 2
      |> Project.lens.stats.pledged .~ 1
      |> Project.lens.stats.staticUsdRate .~ 2.0
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      self.conversionLabelText.assertValues(
        [Strings.discovery_baseball_card_stats_convert_from_pledged_of_goal(pledged: "£1", goal: "£2")]
      )
      self.conversionLabelHidden.assertValues([false])
    }
  }

  func testDeadlineLabels() {
    let project = .template
      |> Project.lens.dates.deadline .~ NSDate().timeIntervalSince1970 + 60*60*24*4

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.deadlineTitleLabelText.assertValues(["3"])
    self.deadlineSubtitleLabelText.assertValues(["days to go"])
  }

  func testGoToComments() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.commentsButtonTapped()

    self.goToComments.assertValues([project])
  }

  func testPledgedLabels_WhenConversionNotNeeded() {
    let project = .template
      |> Project.lens.country .~ .US
      |> Project.lens.stats.pledged .~ 1_000
      |> Project.lens.stats.goal .~ 2_000

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      self.pledgedTitleLabelText.assertValues(
        [Format.currency(project.stats.pledged, country: project.country)]
      )
      self.pledgedSubtitleLabelText.assertValues(
        [
          Strings.discovery_baseball_card_stats_pledged_of_goal(
            goal: Format.currency(project.stats.goal, country: project.country)
          )
        ]
      )
    }
  }

  func testPledgedLabels_WhenConversionNeeded() {
    let project = .template
      |> Project.lens.country .~ .GB
      |> Project.lens.stats.pledged .~ 1
      |> Project.lens.stats.goal .~ 2
      |> Project.lens.stats.staticUsdRate .~ 2.0

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      self.pledgedTitleLabelText.assertValues(["$2"])
      self.pledgedSubtitleLabelText.assertValues(
        [Strings.discovery_baseball_card_stats_pledged_of_goal(goal: "$4")]
      )
    }
  }

  func testNameAndBlurbLabel() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.projectNameAndBlurbLabelText.assertValues(
      ["<b>\(project.name).</b> \(project.blurb)"]
    )
  }

  func testRewardsButtonAccessibilityLabel() {
    let project = Project.template
    let rewardsCount = project.rewards.count
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.rewardsButtonAccessibilityLabel.assertValues(["\(rewardsCount) rewards"])
  }

  func testrewardsTabButton() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.rewardsTabButtonTitleText.assertValues(
      ["\(Strings.project_subpages_menu_buttons_rewards()) (\(Format.wholeNumber(project.rewards.count)))"]
    )
  }

  func testRewardsLabel() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.rewardsLabelText.assertValues(
      [Format.wholeNumber(project.rewards.count)]
    )
  }

  func testUpdatesButtonAccessibilityLabel() {
    let project = Project.template |> Project.lens.stats.updatesCount .~ 10
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.updatesButtonAccessibilityLabel.assertValues(["10 updates"])
  }

  func testUpdatesLabel() {
    let project = Project.template |> Project.lens.stats.updatesCount .~ 10
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.updatesLabelText.assertValues(["10"])
  }

  func testUpdatesLabelWithBadData() {
    let project = Project.template |> Project.lens.stats.updatesCount .~ nil
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.updatesLabelText.assertValues(["0"])
  }
}
