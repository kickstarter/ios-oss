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
    let project = .template
      |> Project.lens.stats.backersCount .~ 5
      |> Project.lens.stats.pledged .~ 50
      |> Project.lens.stats.goal .~ 10_000
      |> Project.lens.dates.deadline .~ NSDate().timeIntervalSince1970 + 60.0 * 60.0 * 24.0 * 3.0
      |> Project.lens.country .~ .US

    let stats = [ProjectStatsEnvelope.FundingDateStats.template]

    self.vm.inputs.configureWith(fundingDateStats: stats, project: project)

    // Make a native string for this.
    self.cellAccessibilityValue.assertValues(["$50 pledged of $10,000 goal, 5 backers, 2 days to go"])
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
      |> Project.lens.dates.deadline .~ NSDate().timeIntervalSince1970 + 60.0 * 60.0 * 24.0 * 1
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
