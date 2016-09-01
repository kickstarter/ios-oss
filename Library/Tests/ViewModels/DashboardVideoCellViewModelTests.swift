import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

internal final class DashboardVideoCellViewModelTests: TestCase {
  internal let vm = DashboardVideoCellViewModel()
  internal let completionPercentage = TestObserver<String, NoError>()
  internal let externalStartCount = TestObserver<String, NoError>()
  internal let externalStartProgress = TestObserver<CGFloat, NoError>()
  internal let externalText = TestObserver<String, NoError>()
  internal let internalStartCount = TestObserver<String, NoError>()
  internal let internalStartProgress = TestObserver<CGFloat, NoError>()
  internal let internalText = TestObserver<String, NoError>()
  internal let totalStartCount = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.completionPercentage.observe(completionPercentage.observer)
    self.vm.outputs.externalStartCount.observe(externalStartCount.observer)
    self.vm.outputs.externalStartProgress.map { round($0 * 100) }.observe(externalStartProgress.observer)
    self.vm.outputs.externalText.observe(externalText.observer)
    self.vm.outputs.internalStartCount.observe(internalStartCount.observer)
    self.vm.outputs.internalStartProgress.map { round($0 * 100) }.observe(internalStartProgress.observer)
    self.vm.outputs.internalText.observe(internalText.observer)
    self.vm.outputs.totalStartCount.map { $0.string }.observe(totalStartCount.observer)
  }

  func testInternalAndExternalPercentRounding() {
    let videoStats = .template
      |> ProjectStatsEnvelope.VideoStats.lens.externalCompletions .~ 25
      |> ProjectStatsEnvelope.VideoStats.lens.externalStarts .~ 145
      |> ProjectStatsEnvelope.VideoStats.lens.internalCompletions .~ 400
      |> ProjectStatsEnvelope.VideoStats.lens.internalStarts .~ 855

    self.vm.inputs.configureWith(videoStats: videoStats)

    self.externalStartProgress.assertValues([14], "0.145, external, rounds down.")
    self.externalText.assertValues(["14% \(Strings.dashboard_graphs_video_stats_off_site())"])

    self.internalStartProgress.assertValues([86], "0.855, internal, rounds up.")
    self.internalText.assertValues(["86% \(Strings.dashboard_graphs_video_stats_on_kickstarter())"],
                                   "Internal rounds up.")

    let videoStats2 = .template
      |> ProjectStatsEnvelope.VideoStats.lens.externalCompletions .~ 25
      |> ProjectStatsEnvelope.VideoStats.lens.externalStarts .~ 600
      |> ProjectStatsEnvelope.VideoStats.lens.internalCompletions .~ 400
      |> ProjectStatsEnvelope.VideoStats.lens.internalStarts .~ 500

    self.vm.inputs.configureWith(videoStats: videoStats2)

    self.externalStartProgress.assertValues([14, 54], "0.545, external, rounds down.")
    self.externalText.assertValues(
      [
        "14% \(Strings.dashboard_graphs_video_stats_off_site())",
        "54% \(Strings.dashboard_graphs_video_stats_off_site())"
      ], "External rounds down.")

    self.internalStartProgress.assertValues([86, 46], "0.454, internal, rounds up.")
    self.internalText.assertValues(
      [
        "86% \(Strings.dashboard_graphs_video_stats_on_kickstarter())",
        "46% \(Strings.dashboard_graphs_video_stats_on_kickstarter())"
      ], "Internal rounds up.")
  }

  func testVideoStatsEmit() {
    let videoStats = .template
      |> ProjectStatsEnvelope.VideoStats.lens.externalCompletions .~ 1000
      |> ProjectStatsEnvelope.VideoStats.lens.externalStarts .~ 2000
      |> ProjectStatsEnvelope.VideoStats.lens.internalCompletions .~ 2000
      |> ProjectStatsEnvelope.VideoStats.lens.internalStarts .~ 3000

    self.vm.inputs.configureWith(videoStats: videoStats)

    self.completionPercentage.assertValues(["60% of plays completed"], "Floored completion percent emits.")
    self.externalStartCount.assertValues(["2,000"], "Formatted external start count emits.")
    self.externalStartProgress.assertValues([40], "External start percentage float value emits.")
    self.internalStartCount.assertValues(["3,000"], "Formatted internal start count emits.")
    self.internalStartProgress.assertValues([60], "Internal start percentage float value emits.")
    self.totalStartCount.assertValues(["5,000 total plays"], "Formatted total start count emits.")
  }
}
