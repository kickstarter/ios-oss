import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result
import XCTest
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
@testable import Library

final class ProjectPamphletMainCellViewModelTests: TestCase {
  private let vm: ProjectPamphletMainCellViewModelType = ProjectPamphletMainCellViewModel()

  private let allStatsStackViewAccessibilityValue = TestObserver<String, NoError>()
  private let backersTitleLabelText = TestObserver<String, NoError>()
  private let conversionLabelHidden = TestObserver<Bool, NoError>()
  private let conversionLabelText = TestObserver<String, NoError>()
  private let creatorImageUrl = TestObserver<String?, NoError>()
  private let creatorLabelText = TestObserver<String, NoError>()
  private let deadlineSubtitleLabelText = TestObserver<String, NoError>()
  private let deadlineTitleLabelText = TestObserver<String, NoError>()
  private let pledgedSubtitleLabelText = TestObserver<String, NoError>()
  private let pledgedTitleLabelText = TestObserver<String, NoError>()
  private let progressPercentage = TestObserver<Float, NoError>()
  private let projectBlurbLabelText = TestObserver<String, NoError>()
  private let projectImageUrl = TestObserver<String?, NoError>()
  private let projectNameLabelText = TestObserver<String, NoError>()
  private let projectStateLabelHidden = TestObserver<Bool, NoError>()
  private let projectStateLabelText = TestObserver<String, NoError>()
  private let youreABackerLabelHidden = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.allStatsStackViewAccessibilityValue
      .observe(self.allStatsStackViewAccessibilityValue.observer)
    self.vm.outputs.backersTitleLabelText.observe(self.backersTitleLabelText.observer)
    self.vm.outputs.conversionLabelHidden.observe(self.conversionLabelHidden.observer)
    self.vm.outputs.conversionLabelText.observe(self.conversionLabelText.observer)
    self.vm.outputs.creatorImageUrl.map { $0?.absoluteString }.observe(self.creatorImageUrl.observer)
    self.vm.outputs.creatorLabelText.observe(self.creatorLabelText.observer)
    self.vm.outputs.deadlineSubtitleLabelText.observe(self.deadlineSubtitleLabelText.observer)
    self.vm.outputs.deadlineTitleLabelText.observe(self.deadlineTitleLabelText.observer)
    self.vm.outputs.pledgedSubtitleLabelText.observe(self.pledgedSubtitleLabelText.observer)
    self.vm.outputs.pledgedTitleLabelText.observe(self.pledgedTitleLabelText.observer)
    self.vm.outputs.progressPercentage.observe(self.progressPercentage.observer)
    self.vm.outputs.projectBlurbLabelText.observe(self.projectBlurbLabelText.observer)
    self.vm.outputs.projectImageUrl.map { $0?.absoluteString }.observe(self.projectImageUrl.observer)
    self.vm.outputs.projectNameLabelText.observe(self.projectNameLabelText.observer)
    self.vm.outputs.projectStateLabelHidden.observe(self.projectStateLabelHidden.observer)
    self.vm.outputs.projectStateLabelText.observe(self.projectStateLabelText.observer)
    self.vm.outputs.youreABackerLabelHidden.observe(self.youreABackerLabelHidden.observer)
  }

  func testAllStatsStackViewAccessibilityValue() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project)

    self.allStatsStackViewAccessibilityValue.assertValueCount(1)
  }

  func testYoureABackerLabelHidden_NotABacker() {
    let project = .template |> Project.lens.personalization.isBacking .~ false
    self.vm.inputs.configureWith(project: project)

    self.youreABackerLabelHidden.assertValues([true])
  }

  func testYoureABackerLabelHidden_LoggedOut() {
    let project = .template |> Project.lens.personalization.isBacking .~ nil
    self.vm.inputs.configureWith(project: project)

    self.youreABackerLabelHidden.assertValues([true])
  }

  func testYoureABackerLabelHidden_Backer() {
    let project = .template |> Project.lens.personalization.isBacking .~ true
    self.vm.inputs.configureWith(project: project)

    self.youreABackerLabelHidden.assertValues([false])
  }

  func testCreatorImageUrl() {
    let project = .template
      |> (Project.lens.creator.avatar • User.Avatar.lens.small) .~ "hello.jpg"
    self.vm.inputs.configureWith(project: project)
    self.creatorImageUrl.assertValues(["hello.jpg"])
  }

  func testCreatorLabelText() {
    let project = Project.template |> Project.lens.creator.name .~ "Creator Blob"
    self.vm.inputs.configureWith(project: project)
    self.creatorLabelText.assertValues(["by Creator Blob"])
  }

  func testProjectBlurbLabelText() {
    let project = Project.template |> Project.lens.blurb .~ "The elevator pitch"
    self.vm.inputs.configureWith(project: project)
    self.projectBlurbLabelText.assertValues(["The elevator pitch"])
  }

  func testProjectImageUrl() {
    let project = .template
      |> Project.lens.photo.full .~ "project.jpg"
    self.vm.inputs.configureWith(project: project)
    self.projectImageUrl.assertValues(["project.jpg"])
  }

  func testProjectNameLabelText() {
    let project = Project.template |> Project.lens.blurb .~ "The elevator pitch"
    self.vm.inputs.configureWith(project: project)
    self.projectBlurbLabelText.assertValues(["The elevator pitch"])
  }

  func testBackersTitleLabel() {
    let project = .template |> Project.lens.stats.backersCount .~ 1_000
    self.vm.inputs.configureWith(project: project)

    self.backersTitleLabelText.assertValues([Format.wholeNumber(project.stats.backersCount)])
  }

  func testConversionLabel_WhenConversionNotNeeded_US_Project_US_User() {
    let project = .template
      |> Project.lens.country .~ .US
    self.vm.inputs.configureWith(project: project)

    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      self.conversionLabelText.assertValueCount(0)
      self.conversionLabelHidden.assertValues([true])
    }
  }

  func testConversionLabel_WhenConversionNotNeeded_US_Project_NonUS_User() {
    let project = .template
      |> Project.lens.country .~ .US
    self.vm.inputs.configureWith(project: project)

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

    self.deadlineTitleLabelText.assertValues(["3"])
    self.deadlineSubtitleLabelText.assertValues(["days to go"])
  }

  func testPledgedLabels_WhenConversionNotNeeded() {
    let project = .template
      |> Project.lens.country .~ .US
      |> Project.lens.stats.pledged .~ 1_000
      |> Project.lens.stats.goal .~ 2_000

    self.vm.inputs.configureWith(project: project)

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

    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      self.pledgedTitleLabelText.assertValues(["$2"])
      self.pledgedSubtitleLabelText.assertValues(
        [Strings.discovery_baseball_card_stats_pledged_of_goal(goal: "$4")]
      )
    }
  }

  func testProgressPercentage_UnderFunded() {
    let project = .template
      |> Project.lens.stats.pledged .~ 100
      |> Project.lens.stats.goal .~ 200
    self.vm.inputs.configureWith(project: project)

    self.progressPercentage.assertValues([0.5])
  }

  func testProgressPercentage_OverFunded() {
    let project = .template
      |> Project.lens.stats.pledged .~ 300
      |> Project.lens.stats.goal .~ 200
    self.vm.inputs.configureWith(project: project)

    self.progressPercentage.assertValues([1.0])
  }
}
