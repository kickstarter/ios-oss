@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class DashboardVideoCellViewModelTests: TestCase {
  internal let vm = DashboardVideoCellViewModel()
  internal let completionPercentage = TestObserver<String, Never>()
  internal let externalStartCount = TestObserver<String, Never>()
  internal let externalStartProgress = TestObserver<CGFloat, Never>()
  internal let externalText = TestObserver<String, Never>()
  internal let internalStartCount = TestObserver<String, Never>()
  internal let internalStartProgress = TestObserver<CGFloat, Never>()
  internal let internalText = TestObserver<String, Never>()
  internal let totalStartCount = TestObserver<String, Never>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.completionPercentage.observe(self.completionPercentage.observer)
    self.vm.outputs.externalStartCount.observe(self.externalStartCount.observer)
    self.vm.outputs.externalStartProgress.map { round($0 * 100) }.observe(self.externalStartProgress.observer)
    self.vm.outputs.externalText.observe(self.externalText.observer)
    self.vm.outputs.internalStartCount.observe(self.internalStartCount.observer)
    self.vm.outputs.internalStartProgress.map { round($0 * 100) }.observe(self.internalStartProgress.observer)
    self.vm.outputs.internalText.observe(self.internalText.observer)
    self.vm.outputs.totalStartCount.map { $0.string }.observe(self.totalStartCount.observer)
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
    self.internalText.assertValues(
      ["86% \(Strings.dashboard_graphs_video_stats_on_kickstarter())"],
      "Internal rounds up."
    )

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
      ], "External rounds down."
    )

    self.internalStartProgress.assertValues([86, 46], "0.454, internal, rounds up.")
    self.internalText.assertValues(
      [
        "86% \(Strings.dashboard_graphs_video_stats_on_kickstarter())",
        "46% \(Strings.dashboard_graphs_video_stats_on_kickstarter())"
      ], "Internal rounds up."
    )
  }

  func testVideoStatsEmit() {
    let videoStats = .template
      |> ProjectStatsEnvelope.VideoStats.lens.externalCompletions .~ 1_000
      |> ProjectStatsEnvelope.VideoStats.lens.externalStarts .~ 2_000
      |> ProjectStatsEnvelope.VideoStats.lens.internalCompletions .~ 2_000
      |> ProjectStatsEnvelope.VideoStats.lens.internalStarts .~ 3_000

    self.vm.inputs.configureWith(videoStats: videoStats)

    self.completionPercentage.assertValues(["60% of plays completed"], "Floored completion percent emits.")
    self.externalStartCount.assertValues(["2,000"], "Formatted external start count emits.")
    self.externalStartProgress.assertValues([40], "External start percentage float value emits.")
    self.internalStartCount.assertValues(["3,000"], "Formatted internal start count emits.")
    self.internalStartProgress.assertValues([60], "Internal start percentage float value emits.")
    self.totalStartCount.assertValues(["5,000 total plays"], "Formatted total start count emits.")
  }
}
