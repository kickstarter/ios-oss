@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class ProjectPamphletMainCellViewModelTests: TestCase {
  private let vm: ProjectPamphletMainCellViewModelType = ProjectPamphletMainCellViewModel()

  private let statsStackViewAccessibilityLabel = TestObserver<String, Never>()
  private let backersTitleLabelText = TestObserver<String, Never>()
  private let configureProjectSummaryCarouselView
    = TestObserver<[ProjectSummaryEnvelope.ProjectSummaryItem], Never>()
  private let conversionLabelHidden = TestObserver<Bool, Never>()
  private let conversionLabelText = TestObserver<String, Never>()
  private let creatorButtonIsHidden = TestObserver<Bool, Never>()
  private let creatorBylineViewHidden = TestObserver<Bool, Never>()
  private let creatorBylineShimmerViewHidden = TestObserver<Bool, Never>()
  private let creatorImageUrl = TestObserver<String?, Never>()
  private let creatorLabelText = TestObserver<String, Never>()
  private let creatorStackViewHidden = TestObserver<Bool, Never>()
  private let deadlineSubtitleLabelText = TestObserver<String, Never>()
  private let deadlineTitleLabelText = TestObserver<String, Never>()
  private let fundingProgressBarViewBackgroundColor = TestObserver<UIColor, Never>()
  private let notifyDelegateToGoToCampaignWithProject = TestObserver<Project, Never>()
  private let notifyDelegateToGoToCampaignWithRefTag = TestObserver<RefTag?, Never>()
  private let notifyDelegateToGoToCreator = TestObserver<Project, Never>()
  private let notifyDelegateToGoToCreatorFromByline = TestObserver<Project, Never>()
  private let opacityForViews = TestObserver<CGFloat, Never>()
  private let pledgedSubtitleLabelText = TestObserver<String, Never>()
  private let pledgedTitleLabelText = TestObserver<String, Never>()
  private let pledgedTitleLabelTextColor = TestObserver<UIColor, Never>()
  private let progressPercentage = TestObserver<Float, Never>()
  private let projectBlurbLabelText = TestObserver<String, Never>()
  private let projectImageUrl = TestObserver<String?, Never>()
  private let projectNameLabelText = TestObserver<String, Never>()
  private let projectStateLabelText = TestObserver<String, Never>()
  private let projectStateLabelTextColor = TestObserver<UIColor, Never>()
  private let projectSummaryCarouselViewHidden = TestObserver<Bool, Never>()
  private let projectUnsuccessfulLabelTextColor = TestObserver<UIColor, Never>()
  private let readMoreButtonIsHidden = TestObserver<Bool, Never>()
  private let readMoreButtonIsLoading = TestObserver<Bool, Never>()
  private let readMoreButtonLargeIsHidden = TestObserver<Bool, Never>()
  private let stateLabelHidden = TestObserver<Bool, Never>()
  private let youreABackerLabelHidden = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.statsStackViewAccessibilityLabel
      .observe(self.statsStackViewAccessibilityLabel.observer)
    self.vm.outputs.backersTitleLabelText.observe(self.backersTitleLabelText.observer)
    self.vm.outputs.configureProjectSummaryCarouselView
      .observe(self.configureProjectSummaryCarouselView.observer)
    self.vm.outputs.conversionLabelHidden.observe(self.conversionLabelHidden.observer)
    self.vm.outputs.conversionLabelText.observe(self.conversionLabelText.observer)
    self.vm.outputs.creatorButtonIsHidden.observe(self.creatorButtonIsHidden.observer)
    self.vm.outputs.creatorBylineViewHidden.observe(self.creatorBylineViewHidden.observer)
    self.vm.outputs.creatorBylineShimmerViewHidden.observe(self.creatorBylineShimmerViewHidden.observer)
    self.vm.outputs.creatorImageUrl.map { $0?.absoluteString }.observe(self.creatorImageUrl.observer)
    self.vm.outputs.creatorLabelText.observe(self.creatorLabelText.observer)
    self.vm.outputs.creatorStackViewHidden.observe(self.creatorStackViewHidden.observer)
    self.vm.outputs.deadlineSubtitleLabelText.observe(self.deadlineSubtitleLabelText.observer)
    self.vm.outputs.deadlineTitleLabelText.observe(self.deadlineTitleLabelText.observer)
    self.vm.outputs.fundingProgressBarViewBackgroundColor
      .observe(self.fundingProgressBarViewBackgroundColor.observer)
    self.vm.outputs.notifyDelegateToGoToCampaignWithProjectAndRefTag.map(first)
      .observe(self.notifyDelegateToGoToCampaignWithProject.observer)
    self.vm.outputs.notifyDelegateToGoToCampaignWithProjectAndRefTag.map(second)
      .observe(self.notifyDelegateToGoToCampaignWithRefTag.observer)
    self.vm.outputs.notifyDelegateToGoToCreator.observe(self.notifyDelegateToGoToCreator.observer)
    self.vm.outputs.notifyDelegateToGoToCreatorFromByline
      .observe(self.notifyDelegateToGoToCreatorFromByline.observer)
    self.vm.outputs.opacityForViews.observe(self.opacityForViews.observer)
    self.vm.outputs.pledgedSubtitleLabelText.observe(self.pledgedSubtitleLabelText.observer)
    self.vm.outputs.pledgedTitleLabelText.observe(self.pledgedTitleLabelText.observer)
    self.vm.outputs.pledgedTitleLabelTextColor.observe(self.pledgedTitleLabelTextColor.observer)
    self.vm.outputs.progressPercentage.observe(self.progressPercentage.observer)
    self.vm.outputs.projectBlurbLabelText.observe(self.projectBlurbLabelText.observer)
    self.vm.outputs.projectImageUrl.map { $0?.absoluteString }.observe(self.projectImageUrl.observer)
    self.vm.outputs.projectNameLabelText.observe(self.projectNameLabelText.observer)
    self.vm.outputs.projectStateLabelText.observe(self.projectStateLabelText.observer)
    self.vm.outputs.projectStateLabelTextColor.observe(self.projectStateLabelTextColor.observer)
    self.vm.outputs.projectSummaryCarouselViewHidden.observe(self.projectSummaryCarouselViewHidden.observer)
    self.vm.outputs.projectUnsuccessfulLabelTextColor.observe(self.projectUnsuccessfulLabelTextColor.observer)
    self.vm.outputs.readMoreButtonIsLoading.observe(self.readMoreButtonIsLoading.observer)
    self.vm.outputs.readMoreButtonIsHidden.observe(self.readMoreButtonIsHidden.observer)
    self.vm.outputs.readMoreButtonLargeIsHidden.observe(self.readMoreButtonLargeIsHidden.observer)
    self.vm.outputs.stateLabelHidden.observe(self.stateLabelHidden.observer)
    self.vm.outputs.youreABackerLabelHidden.observe(self.youreABackerLabelHidden.observer)
  }

  func testStatsStackViewAccessibilityLabel() {
    let project = .template
      |> Project.lens.dates.deadline .~ (self.dateType.init().timeIntervalSince1970 + 60 * 60 * 24 * 10)
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()

    self.statsStackViewAccessibilityLabel.assertValues(
      ["$1,000 of $2,000 goal, 10 backers so far, 10 days to go to go"]
    )

    let nonUSProject = project
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.currency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 1.2
      |> Project.lens.stats.convertedPledgedAmount .~ 1_200
    self.vm.inputs.configureWith(value: (nonUSProject, nil, (creatorDetails, false), []))

    self.statsStackViewAccessibilityLabel.assertValues(
      [
        "$1,000 of $2,000 goal, 10 backers so far, 10 days to go to go",
        "$1,200 of $2,400 goal, 10 backers so far, 10 days to go to go"
      ]
    )

    let nonUSUserCurrency = project
      |> Project.lens.stats.currentCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 2.0

    self.vm.inputs.configureWith(value: (nonUSUserCurrency, nil, (creatorDetails, false), []))

    self.statsStackViewAccessibilityLabel.assertValues(
      [
        "$1,000 of $2,000 goal, 10 backers so far, 10 days to go to go",
        "$1,200 of $2,400 goal, 10 backers so far, 10 days to go to go",
        "£2,000 of £4,000 goal, 10 backers so far, 10 days to go to go"
      ]
    )
  }

  func testStatsStackViewAccessibilityLabel_defaultCurrency_nonUSUser() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let defaultUserCurrency = Project.template
      |> Project.lens.dates.deadline .~ (self.dateType.init().timeIntervalSince1970 + 60 * 60 * 24 * 10)
      |> Project.lens.stats.currency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.staticUsdRate .~ 2.0

    withEnvironment(countryCode: "CA") {
      self.vm.inputs.configureWith(value: (defaultUserCurrency, nil, (creatorDetails, false), []))
      self.vm.inputs.awakeFromNib()

      self.statsStackViewAccessibilityLabel.assertValues(
        ["US$ 2,000 of US$ 4,000 goal, 10 backers so far, 10 days to go to go"]
      )
    }
  }

  func testYoureABackerLabelHidden_NotABacker() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template |> Project.lens.personalization.isBacking .~ false
    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()

    self.youreABackerLabelHidden.assertValues([true])
  }

  func testYoureABackerLabelHidden_NotABacker_VideoInteraction() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template |> Project.lens.personalization.isBacking .~ false
    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()

    self.youreABackerLabelHidden.assertValues([true])

    self.vm.inputs.videoDidStart()

    self.youreABackerLabelHidden.assertValues([true])

    self.vm.inputs.videoDidFinish()

    self.youreABackerLabelHidden.assertValues([true])
  }

  func testYoureABackerLabelHidden_LoggedOut() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template |> Project.lens.personalization.isBacking .~ nil
    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()

    self.youreABackerLabelHidden.assertValues([true])
  }

  func testYoureABackerLabelHidden_Backer() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template |> Project.lens.personalization.isBacking .~ true
    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()

    self.youreABackerLabelHidden.assertValues([false])
  }

  func testYoureABackerLabelHidden_Backer_VideoInteraction() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template |> Project.lens.personalization.isBacking .~ true
    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()

    self.youreABackerLabelHidden.assertValues([false])

    self.vm.inputs.videoDidStart()

    self.youreABackerLabelHidden.assertValues([false, true])

    self.vm.inputs.videoDidFinish()

    self.youreABackerLabelHidden.assertValues([false, true, false])
  }

  func testCreatorImageUrl() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ "hello.jpg"
    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()
    self.creatorImageUrl.assertValues(["hello.jpg"])
  }

  func testCreatorLabelText() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = Project.template |> Project.lens.creator.name .~ "Creator Blob"
    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()
    self.creatorLabelText.assertValues(["by Creator Blob"])
  }

  func testProjectBlurbLabelText() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = Project.template |> Project.lens.blurb .~ "The elevator pitch"
    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()
    self.projectBlurbLabelText.assertValues(["The elevator pitch"])
  }

  func testProjectImageUrl() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template
      |> Project.lens.photo.full .~ "project.jpg"
    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()
    self.projectImageUrl.assertValues(["project.jpg"])
  }

  func testProjectNameLabelText() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = Project.template |> Project.lens.blurb .~ "The elevator pitch"
    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()
    self.projectBlurbLabelText.assertValues(["The elevator pitch"])
  }

  func testBackersTitleLabel() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template |> Project.lens.stats.backersCount .~ 1_000
    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()

    self.backersTitleLabelText.assertValues([Format.wholeNumber(project.stats.backersCount)])
  }

  // MARK: - Conversion Label

  func testConversionLabel_WhenConversionNotNeeded_US_Project_US_User() {
    let project = Project.template
    let creatorDetails = ProjectCreatorDetailsEnvelope.template

    withEnvironment(countryCode: "US") {
      self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
      self.vm.inputs.awakeFromNib()

      self.conversionLabelText.assertValueCount(0)
      self.conversionLabelHidden.assertValues([true])
    }
  }

  func testConversionLabel_WhenConversionNeeded_US_Project_NonUS_User() {
    let project = .template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.pledged .~ 1_000
      |> Project.lens.stats.goal .~ 2_000
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.ca.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 1.3
    let creatorDetails = ProjectCreatorDetailsEnvelope.template

    withEnvironment(countryCode: "CA") {
      self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
      self.vm.inputs.awakeFromNib()

      self.conversionLabelText.assertValues(["Converted from US$ 1,000 pledged of US$ 2,000 goal."])
      self.conversionLabelHidden.assertValues([false])
    }
  }

  func testConversionLabel_WhenConversionNeeded_NonUS_Project_US_User() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.currency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.goal .~ 2
      |> Project.lens.stats.pledged .~ 1

    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
      self.vm.inputs.awakeFromNib()

      self.conversionLabelText.assertValues(["Converted from £1 pledged of £2 goal."])
      self.conversionLabelHidden.assertValues([false])
    }
  }

  func testDeadlineLabels() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template
      |> Project.lens.dates.deadline .~ (self.dateType.init().timeIntervalSince1970 + 60 * 60 * 24 * 4)

    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()

    self.deadlineTitleLabelText.assertValues(["4"])
    self.deadlineSubtitleLabelText.assertValues(["days to go"])
  }

  func testFundingProgressBarViewBackgroundColor_UnsuccessfulProject() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template
      |> Project.lens.state .~ .failed

    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()

    self.fundingProgressBarViewBackgroundColor.assertValues([UIColor.ksr_dark_grey_400])
  }

  func testFundingProgressBarViewBackgroundColor_SuccessfulProject() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template
      |> Project.lens.state .~ .successful

    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()

    self.fundingProgressBarViewBackgroundColor.assertValues([UIColor.ksr_green_700])
  }

  func testPledgedTitleLabelTextColor_SucessfulProject() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template
      |> Project.lens.state .~ .successful

    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()

    self.pledgedTitleLabelTextColor.assertValues([UIColor.ksr_green_700])
  }

  func testPledgedTitleLabelTextColor_UnsuccessfulProject() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template
      |> Project.lens.state .~ .canceled

    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()

    self.pledgedTitleLabelTextColor.assertValues([UIColor.ksr_text_dark_grey_500])
  }

  // MARK: - Pledged Label

  func testPledgedLabels_WhenConversionNotNeeded() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.pledged .~ 1_000
      |> Project.lens.stats.goal .~ 2_000

    withEnvironment(countryCode: "US") {
      self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
      self.vm.inputs.awakeFromNib()

      self.pledgedTitleLabelText.assertValues(["$1,000"])
      self.pledgedSubtitleLabelText.assertValues(["pledged of $2,000"])
    }
  }

  func testPledgedLabels_WhenConversionNotNeeded_NonUS_Location() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = Project.template

    withEnvironment(countryCode: "CA") {
      self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
      self.vm.inputs.awakeFromNib()

      self.pledgedTitleLabelText.assertValues(
        ["US$ 1,000"]
      )
      self.pledgedSubtitleLabelText.assertValues(
        ["pledged of US$ 2,000"]
      )
    }
  }

  func testPledgedLabels_WhenConversionNeeded() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.currency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 2.0

    withEnvironment(countryCode: "US") {
      self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
      self.vm.inputs.awakeFromNib()

      self.pledgedTitleLabelText.assertValues(["$2,000"])
      self.pledgedSubtitleLabelText.assertValues(["pledged of $4,000"])
    }
  }

  func testPledgedLabels_ConversionNotNeeded_NonUSCountry() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.currency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.pledged .~ 1
      |> Project.lens.stats.goal .~ 2

    withEnvironment(countryCode: "GB") {
      self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
      self.vm.inputs.awakeFromNib()

      self.pledgedTitleLabelText.assertValues(["£1"])
      self.pledgedSubtitleLabelText.assertValues(["pledged of £2"])
    }
  }

  func testProgressPercentage_UnderFunded() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template
      |> Project.lens.stats.pledged .~ 100
      |> Project.lens.stats.goal .~ 200
    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()

    self.progressPercentage.assertValues([0.5])
  }

  func testProgressPercentage_OverFunded() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template
      |> Project.lens.stats.pledged .~ 300
      |> Project.lens.stats.goal .~ 200
    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()

    self.progressPercentage.assertValues([1.0])
  }

  func testProjectStateLabelTextColor_SuccessfulProject() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template
      |> Project.lens.state .~ .successful
    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()

    self.projectStateLabelTextColor.assertValues([UIColor.ksr_green_700])
  }

  func testProjectStateLabelTextColor_UnsuccessfulProject() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template
      |> Project.lens.state .~ .failed
    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()

    self.projectStateLabelTextColor.assertValues([UIColor.ksr_text_dark_grey_400])
  }

  func testProjectUnsuccessfulLabelTextColor_SuccessfulProjects() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template
      |> Project.lens.state .~ .failed
    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()

    self.projectUnsuccessfulLabelTextColor.assertValues([UIColor.ksr_text_dark_grey_500])
  }

  func testProjectUnsuccessfulLabelTextColor_UnsuccessfulProjects() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template
      |> Project.lens.state .~ .failed
    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()

    self.projectUnsuccessfulLabelTextColor.assertValues([UIColor.ksr_text_dark_grey_500])
  }

  func testStateLabelHidden_LiveProject() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template
      |> Project.lens.state .~ .live
    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()

    self.stateLabelHidden.assertValues([true])
  }

  func testStateLabelHidden_NonLiveProject() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template
      |> Project.lens.state .~ .successful
    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()

    self.stateLabelHidden.assertValues([false])
  }

  func testViewTransition() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template

    self.opacityForViews.assertValueCount(0)

    self.vm.inputs.awakeFromNib()

    self.opacityForViews.assertValues([0.0])

    self.vm.inputs.configureWith(value: (.template, nil, (creatorDetails, false), []))

    self.opacityForViews.assertValues([0.0, 1.0], "Fade in views after project comes in.")
  }

  func testProjectCampaignCTA_OptimizelyControl() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeProjectPageCampaignDetails.rawValue:
          OptimizelyExperiment.Variant.control.rawValue
      ]

    self.readMoreButtonIsHidden.assertDidNotEmitValue()
    self.readMoreButtonLargeIsHidden.assertDidNotEmitValue()

    withEnvironment(optimizelyClient: optimizelyClient) {
      self.vm.inputs.configureWith(value: (.template, nil, (creatorDetails, false), []))
      self.vm.inputs.awakeFromNib()

      self.readMoreButtonIsHidden.assertValues([false])
      self.readMoreButtonLargeIsHidden.assertValues([true])
    }
  }

  func testProjectCampaignCTA_OptimizelyControl_OptimizelyClientNotConfigured() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template

    self.readMoreButtonIsHidden.assertDidNotEmitValue()
    self.readMoreButtonLargeIsHidden.assertDidNotEmitValue()

    withEnvironment(optimizelyClient: nil) {
      self.vm.inputs.configureWith(value: (.template, nil, (creatorDetails, false), []))
      self.vm.inputs.awakeFromNib()

      self.readMoreButtonIsHidden.assertValues([false])
      self.readMoreButtonLargeIsHidden.assertValues([true])
    }
  }

  func testProjectCampaignCTA_OptimizelyExperimental_Variant1() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeProjectPageCampaignDetails.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    self.readMoreButtonIsHidden.assertDidNotEmitValue()
    self.readMoreButtonLargeIsHidden.assertDidNotEmitValue()

    withEnvironment(optimizelyClient: optimizelyClient) {
      self.vm.inputs.configureWith(value: (.template, nil, (creatorDetails, false), []))
      self.vm.inputs.awakeFromNib()

      self.readMoreButtonIsHidden.assertValues([true])
      self.readMoreButtonLargeIsHidden.assertValues([false])
    }
  }

  func testProjectCampaignCTA_OptimizelyExperimental_Variant2() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeProjectPageCampaignDetails.rawValue:
          OptimizelyExperiment.Variant.variant2.rawValue
      ]

    withEnvironment(optimizelyClient: optimizelyClient) {
      self.vm.inputs.configureWith(value: (.template, nil, (creatorDetails, false), []))
      self.vm.inputs.awakeFromNib()

      self.readMoreButtonIsHidden.assertValues([true])
      self.readMoreButtonLargeIsHidden.assertValues([false])
    }
  }

  func testNotifyDelegateToGoToCampaign() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = Project.template
    let refTag = RefTag.discovery

    self.notifyDelegateToGoToCampaignWithProject.assertValues([])
    self.notifyDelegateToGoToCampaignWithRefTag.assertValues([])

    self.vm.inputs.configureWith(value: (project, refTag, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()

    self.notifyDelegateToGoToCampaignWithProject.assertValues([])
    self.notifyDelegateToGoToCampaignWithRefTag.assertValues([])

    self.vm.inputs.readMoreButtonTapped()

    self.notifyDelegateToGoToCampaignWithProject.assertValues([project])
    self.notifyDelegateToGoToCampaignWithRefTag.assertValues([refTag])
  }

  func testNotifyDelegateToGoToCreator() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = Project.template

    self.notifyDelegateToGoToCreator.assertValues([])

    self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
    self.vm.inputs.awakeFromNib()

    self.notifyDelegateToGoToCreator.assertValues([])

    self.vm.inputs.creatorButtonTapped()

    self.notifyDelegateToGoToCreator.assertValues([project])
  }

  func testTrackingCampaignDetailsButtonTapped_NonLiveProject_LoggedIn_Backed() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let user = User.template
      |> \.location .~ Location.template
      |> \.stats.backedProjectsCount .~ 50

    let project = Project.template
      |> Project.lens.state .~ .successful
      |> Project.lens.personalization.isBacking .~ true

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(value: (project, .discovery, (creatorDetails, false), []))
      self.vm.inputs.awakeFromNib()

      XCTAssertEqual(self.trackingClient.events, [])

      self.vm.inputs.readMoreButtonTapped()

      XCTAssertEqual(self.trackingClient.events, ["Campaign Details Button Clicked"], "Event is tracked")

      XCTAssertEqual(
        self.trackingClient.properties(forKey: "optimizely_api_key"),
        [nil],
        "Event does not include Optimizely properties"
      )
      XCTAssertEqual(
        self.trackingClient.properties(forKey: "optimizely_environment"),
        [nil],
        "Event does not include Optimizely properties"
      )
      XCTAssertEqual(
        self.trackingClient.properties(forKey: "optimizely_experiments"),
        [nil],
        "Event does not include Optimizely properties"
      )
    }
  }

  func testOptimizelyTrackingCreatorBylineTapped_LiveProject_LoggedIn_NonBacked() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template

    let user = User.template
      |> \.location .~ Location.template
      |> \.stats.backedProjectsCount .~ 50

    let project = Project.template
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ false

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(value: (project, .discovery, (creatorDetails, false), []))
      self.vm.inputs.awakeFromNib()

      XCTAssertEqual(self.optimizelyClient.trackedUserId, nil)
      XCTAssertEqual(self.optimizelyClient.trackedEventKey, nil)
      XCTAssertNil(self.optimizelyClient.trackedAttributes)

      self.vm.inputs.creatorBylineTapped()

      self.notifyDelegateToGoToCreatorFromByline.assertValues([project])

      XCTAssertEqual(self.optimizelyClient.trackedUserId, "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF")
      XCTAssertEqual(self.optimizelyClient.trackedEventKey, "Creator Details Clicked")

      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_backed_projects_count"] as? Int, 50)
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_launched_projects_count"] as? Int, nil)
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_country"] as? String, "us")
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_facebook_account"] as? Bool, nil)
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_display_language"] as? String, "en")

      XCTAssertEqual(
        self.optimizelyClient.trackedAttributes?["session_os_version"] as? String,
        "MockSystemVersion"
      )
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_user_is_logged_in"] as? Bool, true)
      XCTAssertEqual(
        self.optimizelyClient.trackedAttributes?["session_app_release_version"] as? String,
        "1.2.3.4.5.6.7.8.9.0"
      )
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_apple_pay_device"] as? Bool, true)
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_device_format"] as? String, "phone")
    }
  }

  func testOptimizelyTrackingCampaignDetailsButtonTapped_NonLiveProject_LoggedIn_Backed() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let user = User.template
      |> \.location .~ Location.template
      |> \.stats.backedProjectsCount .~ 50

    let project = Project.template
      |> Project.lens.state .~ .successful
      |> Project.lens.personalization.isBacking .~ true

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(value: (project, .discovery, (creatorDetails, false), []))
      self.vm.inputs.awakeFromNib()

      XCTAssertEqual(self.optimizelyClient.trackedUserId, nil)
      XCTAssertEqual(self.optimizelyClient.trackedEventKey, nil)
      XCTAssertNil(self.optimizelyClient.trackedAttributes)

      self.vm.inputs.readMoreButtonTapped()

      XCTAssertEqual(self.optimizelyClient.trackedUserId, "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF")
      XCTAssertEqual(self.optimizelyClient.trackedEventKey, "Campaign Details Button Clicked")

      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_backed_projects_count"] as? Int, 50)
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_launched_projects_count"] as? Int, nil)
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_country"] as? String, "us")
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_facebook_account"] as? Bool, nil)
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_display_language"] as? String, "en")
    }
  }

  func testOptimizelyTrackingCampaignDetailsButtonTapped_LiveProject_LoggedIn_NonBacked() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template

    let user = User.template
      |> \.location .~ Location.template
      |> \.stats.backedProjectsCount .~ 50

    let project = Project.template
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.backing .~ nil

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(value: (project, .discovery, (creatorDetails, false), []))
      self.vm.inputs.awakeFromNib()

      XCTAssertEqual(self.optimizelyClient.trackedUserId, nil)
      XCTAssertEqual(self.optimizelyClient.trackedEventKey, nil)
      XCTAssertNil(self.optimizelyClient.trackedAttributes)

      self.vm.inputs.readMoreButtonTapped()

      self.notifyDelegateToGoToCampaignWithProject.assertValues([project])
      self.notifyDelegateToGoToCampaignWithRefTag.assertValues([.discovery])

      XCTAssertEqual(self.optimizelyClient.trackedUserId, "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF")
      XCTAssertEqual(self.optimizelyClient.trackedEventKey, "Campaign Details Button Clicked")

      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_backed_projects_count"] as? Int, 50)
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_launched_projects_count"] as? Int, nil)
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_country"] as? String, "us")
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_facebook_account"] as? Bool, nil)
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_display_language"] as? String, "en")
      XCTAssertEqual(
        self.optimizelyClient.trackedAttributes?["session_os_version"] as? String,
        "MockSystemVersion"
      )
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_user_is_logged_in"] as? Bool, true)
      XCTAssertEqual(
        self.optimizelyClient.trackedAttributes?["session_app_release_version"] as? String,
        "1.2.3.4.5.6.7.8.9.0"
      )
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_apple_pay_device"] as? Bool, true)
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_device_format"] as? String, "phone")
    }
  }

  func testTrackingCampaignDetailsButtonTapped_LiveProject_LoggedIn_NonBacked() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template

    let user = User.template
      |> \.location .~ Location.template
      |> \.stats.backedProjectsCount .~ 50

    let project = Project.template
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.backing .~ nil

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(value: (project, .discovery, (creatorDetails, false), []))
      self.vm.inputs.awakeFromNib()

      XCTAssertEqual(self.trackingClient.events, [])

      self.vm.inputs.readMoreButtonTapped()

      self.notifyDelegateToGoToCampaignWithProject.assertValues([project])
      self.notifyDelegateToGoToCampaignWithRefTag.assertValues([.discovery])

      XCTAssertEqual(self.trackingClient.events, ["Campaign Details Button Clicked"])

      XCTAssertEqual(self.trackingClient.properties(forKey: "context_location"), ["project_screen"])
      XCTAssertEqual(self.trackingClient.properties(forKey: "session_ref_tag"), ["discovery"])
      XCTAssertEqual(self.trackingClient.properties(forKey: "session_referrer_credit"), ["discovery"])

      XCTAssertEqual(self.trackingClient.properties(forKey: "project_subcategory"), ["Art"])
      XCTAssertEqual(self.trackingClient.properties(forKey: "project_category"), [nil])
      XCTAssertEqual(self.trackingClient.properties(forKey: "project_country"), ["US"])
      XCTAssertEqual(self.trackingClient.properties(forKey: "project_user_has_watched", as: Bool.self), [nil])

      let properties = self.trackingClient.properties.last

      XCTAssertNotNil(
        properties?["optimizely_api_key"],
        "Event includes Optimizely properties"
      )
      XCTAssertNotNil(
        properties?["optimizely_environment"],
        "Event includes Optimizely properties"
      )
      XCTAssertNotNil(
        properties?["optimizely_experiments"],
        "Event includes Optimizely properties"
      )
    }
  }

  func testTrackingCreatorBylineTapped_LiveProject_LoggedIn_NonBacked() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template

    let project = Project.template
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ false

    withEnvironment(config: .template, currentUser: .template) {
      self.vm.inputs.configureWith(value: (project, .discovery, (creatorDetails, false), []))
      self.vm.inputs.awakeFromNib()

      XCTAssertEqual(self.trackingClient.events, [])

      self.vm.inputs.creatorBylineTapped()

      self.notifyDelegateToGoToCreatorFromByline.assertValues([project])

      XCTAssertEqual(self.trackingClient.events, ["Creator Details Clicked"])

      XCTAssertEqual(self.trackingClient.properties(forKey: "context_location"), ["project_screen"])
      XCTAssertEqual(self.trackingClient.properties(forKey: "session_ref_tag"), ["discovery"])
      XCTAssertEqual(self.trackingClient.properties(forKey: "session_referrer_credit"), ["discovery"])

      XCTAssertEqual(self.trackingClient.properties(forKey: "project_subcategory"), ["Art"])
      XCTAssertEqual(self.trackingClient.properties(forKey: "project_category"), [nil])
      XCTAssertEqual(self.trackingClient.properties(forKey: "project_country"), ["US"])
      XCTAssertEqual(self.trackingClient.properties(forKey: "project_user_has_watched", as: Bool.self), [nil])

      let properties = self.trackingClient.properties.last

      XCTAssertNotNil(
        properties?["optimizely_api_key"],
        "Event includes Optimizely properties"
      )
      XCTAssertNotNil(
        properties?["optimizely_environment"],
        "Event includes Optimizely properties"
      )
      XCTAssertNotNil(
        properties?["optimizely_experiments"],
        "Event includes Optimizely properties"
      )
    }
  }

  func testTrackingCreatorBylineTapped_LiveProject_LoggedIn_Backed() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template

    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ Backing.template

    withEnvironment(currentUser: .template) {
      self.vm.inputs.configureWith(value: (project, .discovery, (creatorDetails, false), []))
      self.vm.inputs.awakeFromNib()

      XCTAssertEqual(self.trackingClient.events, [])

      self.vm.inputs.creatorBylineTapped()

      self.notifyDelegateToGoToCreatorFromByline.assertValues([project])

      XCTAssertEqual(self.trackingClient.events, ["Creator Details Clicked"], "Event is tracked")

      XCTAssertEqual(
        self.trackingClient.properties(forKey: "optimizely_api_key"),
        [nil],
        "Event does not include Optimizely properties"
      )
      XCTAssertEqual(
        self.trackingClient.properties(forKey: "optimizely_environment"),
        [nil],
        "Event does not include Optimizely properties"
      )
      XCTAssertEqual(
        self.trackingClient.properties(forKey: "optimizely_experiments"),
        [nil],
        "Event does not include Optimizely properties"
      )
    }
  }

  func testCreatorBylineIsShown_Variant1() {
    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeProjectPageConversionCreatorDetails.rawValue: OptimizelyExperiment
          .Variant.variant1.rawValue
      ]

    withEnvironment(optimizelyClient: optimizelyClient) {
      self.vm.inputs.configureWith(value: (.template, nil, (.template, true), []))
      self.vm.inputs.awakeFromNib()

      self.creatorButtonIsHidden.assertValues([true])
    }
  }

  func testReadMoreButtonIsLoading_Control() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template

    let project = Project.template

    self.readMoreButtonIsLoading.assertDidNotEmitValue()

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeProjectPageCampaignDetails.rawValue: OptimizelyExperiment.Variant
          .control.rawValue
      ]

    withEnvironment(optimizelyClient: optimizelyClient) {
      self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
      self.vm.inputs.awakeFromNib()

      self.readMoreButtonIsLoading.assertValues([false])
    }
  }

  func testReadMoreButtonIsLoading_Variant1() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template

    let project = Project.template

    self.readMoreButtonIsLoading.assertDidNotEmitValue()

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeProjectPageCampaignDetails.rawValue: OptimizelyExperiment.Variant
          .variant1.rawValue
      ]

    withEnvironment(optimizelyClient: optimizelyClient) {
      self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
      self.vm.inputs.awakeFromNib()

      self.readMoreButtonIsLoading.assertValues([false])
    }
  }

  func testReadMoreButtonIsLoading_Variant2_NoRewards() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template

    let project = Project.template

    self.readMoreButtonIsLoading.assertDidNotEmitValue()

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeProjectPageCampaignDetails.rawValue: OptimizelyExperiment.Variant
          .variant2.rawValue
      ]

    withEnvironment(optimizelyClient: optimizelyClient) {
      self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
      self.vm.inputs.awakeFromNib()

      self.readMoreButtonIsLoading.assertValues([true])

      let projectWithRewards = Project.cosmicSurgery

      self.vm.inputs.configureWith(value: (projectWithRewards, nil, (creatorDetails, false), []))

      self.readMoreButtonIsLoading.assertValues([true, false, false])
    }
  }

  func testReadMoreButtonIsLoading_Variant2_HasRewards() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template

    let project = Project.cosmicSurgery

    self.readMoreButtonIsLoading.assertDidNotEmitValue()

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeProjectPageCampaignDetails.rawValue: OptimizelyExperiment.Variant
          .variant2.rawValue
      ]

    withEnvironment(optimizelyClient: optimizelyClient) {
      self.vm.inputs.configureWith(value: (project, nil, (creatorDetails, false), []))
      self.vm.inputs.awakeFromNib()

      self.readMoreButtonIsLoading.assertValues([false])
    }
  }

  func testCreatorDetailsVisibility_NilCreatorDetails() {
    self.creatorBylineViewHidden.assertDidNotEmitValue()
    self.creatorBylineShimmerViewHidden.assertDidNotEmitValue()
    self.creatorStackViewHidden.assertDidNotEmitValue()
    self.creatorButtonIsHidden.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: (.template, .discovery, (nil, true), []))
    self.vm.inputs.awakeFromNib()

    self.creatorBylineViewHidden.assertValues([true])
    self.creatorBylineShimmerViewHidden.assertValues([false])
    self.creatorStackViewHidden.assertValues([true])
    self.creatorButtonIsHidden.assertValues([true])

    self.vm.inputs.configureWith(value: (.template, .discovery, (nil, false), []))

    self.creatorBylineViewHidden.assertValues([true, true])
    self.creatorBylineShimmerViewHidden.assertValues([false, true])
    self.creatorStackViewHidden.assertValues([true, true, false])
    self.creatorButtonIsHidden.assertValues([true, true, false])
  }

  func testCreatorDetailsVisibility_NonNilCreatorDetails() {
    self.creatorBylineViewHidden.assertDidNotEmitValue()
    self.creatorBylineShimmerViewHidden.assertDidNotEmitValue()
    self.creatorStackViewHidden.assertDidNotEmitValue()
    self.creatorButtonIsHidden.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: (.template, .discovery, (.template, true), []))
    self.vm.inputs.awakeFromNib()

    self.creatorBylineViewHidden.assertValues([true])
    self.creatorBylineShimmerViewHidden.assertValues([false])
    self.creatorStackViewHidden.assertValues([true])
    self.creatorButtonIsHidden.assertValues([true])

    self.vm.inputs.configureWith(value: (.template, .discovery, (.template, false), []))

    self.creatorBylineViewHidden.assertValues([true, false])
    self.creatorBylineShimmerViewHidden.assertValues([false, true])
    self.creatorStackViewHidden.assertValues([true, true, true])
    self.creatorButtonIsHidden.assertValues([true, true, true])
  }

  func testProjectSummaryCarousel_Visible() {
    self.configureProjectSummaryCarouselView.assertDidNotEmitValue()
    self.projectSummaryCarouselViewHidden.assertDidNotEmitValue()

    let items = [
      ProjectSummaryEnvelope.ProjectSummaryItem(
        question: .whatIsTheProject,
        response: "Test copy 1"
      ),
      ProjectSummaryEnvelope.ProjectSummaryItem(
        question: .whatWillYouDoWithTheMoney,
        response: "Test copy 2"
      ),
      ProjectSummaryEnvelope.ProjectSummaryItem(
        question: .whoAreYou,
        response: "Test copy 3"
      )
    ]

    self.vm.inputs.configureWith(value: (.template, .discovery, (.template, true), items))
    self.vm.inputs.awakeFromNib()

    self.configureProjectSummaryCarouselView.assertValues([items])
    self.projectSummaryCarouselViewHidden.assertValues([false])
  }

  func testProjectSummaryCarousel_Hidden() {
    self.configureProjectSummaryCarouselView.assertDidNotEmitValue()
    self.projectSummaryCarouselViewHidden.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: (.template, .discovery, (.template, true), []))
    self.vm.inputs.awakeFromNib()

    self.configureProjectSummaryCarouselView.assertValues([[]])
    self.projectSummaryCarouselViewHidden.assertValues([true])
  }
}
