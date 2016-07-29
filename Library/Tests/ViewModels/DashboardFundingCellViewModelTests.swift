import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

internal final class DashboardFundingCellViewModelTests: TestCase {
  internal let vm = DashboardFundingCellViewModel()
  internal let backersText = TestObserver<String, NoError>()
  internal let cellAccessibilityValue = TestObserver<String, NoError>()
  internal let deadlineDateText = TestObserver<String, NoError>()
  internal let goalText = TestObserver<String, NoError>()
  internal let launchDateText = TestObserver<String, NoError>()
  internal let pledgedText = TestObserver<String, NoError>()
  internal let project = TestObserver<Project, NoError>()
  internal let stats = TestObserver<[ProjectStatsEnvelope.FundingDateStats], NoError>()
  internal let timeRemainingSubtitleText = TestObserver<String, NoError>()
  internal let timeRemainingTitleText = TestObserver<String, NoError>()
  internal let yAxisTickSize = TestObserver<CGFloat, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.backersText.observe(self.backersText.observer)
    self.vm.outputs.cellAccessibilityValue.observe(self.cellAccessibilityValue.observer)
    self.vm.outputs.deadlineDateText.observe(self.deadlineDateText.observer)
    self.vm.outputs.launchDateText.observe(self.launchDateText.observer)
    self.vm.outputs.goalText.observe(self.goalText.observer)
    self.vm.outputs.graphData.map { data in data.project }.observe(self.project.observer)
    self.vm.outputs.graphData.map { data in data.stats }.observe(self.stats.observer)
    self.vm.outputs.graphData.map { data in data.yAxisTickSize }.observe(self.yAxisTickSize.observer)
    self.vm.outputs.pledgedText.observe(self.pledgedText.observer)
    self.vm.outputs.timeRemainingSubtitleText.observe(self.timeRemainingSubtitleText.observer)
    self.vm.outputs.timeRemainingTitleText.observe(self.timeRemainingTitleText.observer)
  }

  func testCellAccessibility() {
    let liveProject = .template
      |> Project.lens.stats.backersCount .~ 5
      |> Project.lens.stats.pledged .~ 50
      |> Project.lens.stats.goal .~ 10_000
      |> Project.lens.dates.deadline .~ NSDate().timeIntervalSince1970 + 60.0 * 60.0 * 24.0 * 3.0
      |> Project.lens.country .~ .US

    let stats = [ProjectStatsEnvelope.FundingDateStats.template]

    self.vm.inputs.configureWith(fundingDateStats: stats, project: liveProject)

    self.cellAccessibilityValue.assertValues(
      [Strings.dashboard_graphs_funding_accessibility_live_stat_value(
        pledged: Format.currency(liveProject.stats.pledged, country: liveProject.country),
        goal: Format.currency(liveProject.stats.goal, country: liveProject.country),
        backers_count: liveProject.stats.backersCount,
        time_left: Format.duration(secondsInUTC: liveProject.dates.deadline).time + " " +
          Format.duration(secondsInUTC: liveProject.dates.deadline).unit
      )],
      "Live project stats value emits."
    )

    let nonLiveProject = .template |> Project.lens.state .~ .successful

    self.vm.inputs.configureWith(fundingDateStats: stats, project: nonLiveProject)

    self.cellAccessibilityValue.assertValues(
      [
        Strings.dashboard_graphs_funding_accessibility_live_stat_value(
        pledged: Format.currency(liveProject.stats.pledged, country: liveProject.country),
        goal: Format.currency(liveProject.stats.goal, country: liveProject.country),
        backers_count: liveProject.stats.backersCount,
        time_left: Format.duration(secondsInUTC: liveProject.dates.deadline).time + " " +
          Format.duration(secondsInUTC: liveProject.dates.deadline).unit
        ),
        Strings.dashboard_graphs_funding_accessibility_non_live_stat_value(
          pledged: Format.currency(nonLiveProject.stats.pledged, country: nonLiveProject.country),
          goal: Format.currency(nonLiveProject.stats.goal, country: nonLiveProject.country),
          backers_count: nonLiveProject.stats.backersCount,
          time_left: Format.duration(secondsInUTC: nonLiveProject.dates.deadline).time + " " +
            Format.duration(secondsInUTC: nonLiveProject.dates.deadline).unit
      )],
      "Non live project stats value emits."
    )
  }

  func testFundingGraphDataEmits() {
    let stat1 = .template
      |> ProjectStatsEnvelope.FundingDateStats.lens.date .~ 1468421287 - 60 * 60 * 24 * 4
      |> ProjectStatsEnvelope.FundingDateStats.lens.cumulativePledged .~ 500

    let stat2 = .template
      |> ProjectStatsEnvelope.FundingDateStats.lens.date .~ 1468421287 - 60 * 60 * 24 * 3
      |> ProjectStatsEnvelope.FundingDateStats.lens.cumulativePledged .~ 700

    let stat3 = .template
      |> ProjectStatsEnvelope.FundingDateStats.lens.date .~ 1468421287 - 60 * 60 * 24 * 2
      |> ProjectStatsEnvelope.FundingDateStats.lens.cumulativePledged .~ 1_500

    let stat4 = .template
      |> ProjectStatsEnvelope.FundingDateStats.lens.date .~ 1468421287 - 60 * 60 * 24 * 1
      |> ProjectStatsEnvelope.FundingDateStats.lens.cumulativePledged .~ 2_200

    let stat5 = .template
      |> ProjectStatsEnvelope.FundingDateStats.lens.date .~ 1468421287
      |> ProjectStatsEnvelope.FundingDateStats.lens.cumulativePledged .~ 3_500

    let fundingDateStats = [stat1, stat2, stat3, stat4, stat5]

    let project = .template
      |> Project.lens.dates.deadline .~ 1468421287
      |> Project.lens.dates.launchedAt .~ 1468421287 - 60 * 60 * 24 * 5
      |> Project.lens.dates.stateChangedAt .~ 1468421287

    self.vm.inputs.configureWith(fundingDateStats: fundingDateStats, project: project)

    self.project.assertValues([project])
    self.stats.assertValues([[stat1, stat2, stat3, stat4, stat5]])
    self.yAxisTickSize.assertValueCount(1)
  }

  func testProjectDataEmits() {
    let fundingDateStats = [ProjectStatsEnvelope.FundingDateStats.template]

    let project = .template
      |> Project.lens.stats.backersCount .~ 2_000
      |> Project.lens.dates.deadline .~ NSDate().timeIntervalSince1970 + 60.0 * 60.0 * 24.0
      |> Project.lens.stats.goal .~ 50_000
      |> Project.lens.stats.pledged .~ 5_000

    self.vm.inputs.configureWith(fundingDateStats: fundingDateStats, project: project)

    self.backersText.assertValues(["2,000"])
    self.deadlineDateText.assertValueCount(1)
    self.goalText.assertValues(["pledged of $50,000"])
    self.launchDateText.assertValueCount(1)
    self.pledgedText.assertValues(["$5,000"])
    self.timeRemainingSubtitleText.assertValues(["hours to go"])
    self.timeRemainingTitleText.assertValues(["23"])
  }
}
