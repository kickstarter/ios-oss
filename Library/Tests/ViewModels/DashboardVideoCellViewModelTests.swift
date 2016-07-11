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
  internal let internalStartCount = TestObserver<String, NoError>()
  internal let internalStartProgress = TestObserver<CGFloat, NoError>()
  internal let totalStartCount = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.completionPercentage.observe(completionPercentage.observer)
    self.vm.outputs.externalStartCount.observe(externalStartCount.observer)
    self.vm.outputs.externalStartProgress.observe(externalStartProgress.observer)
    self.vm.outputs.internalStartCount.observe(internalStartCount.observer)
    self.vm.outputs.internalStartProgress.observe(internalStartProgress.observer)
    self.vm.outputs.totalStartCount.map { $0.string }.observe(totalStartCount.observer)
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
    self.externalStartProgress.assertValues([0.4], "External start percentage float value emits.")
    self.internalStartCount.assertValues(["3,000"], "Formatted internal start count emits.")
    self.internalStartProgress.assertValues([0.6], "Internal start percentage float value emits.")
    self.totalStartCount.assertValues(["5,000 total plays"], "Formatted total start count emits.")
  }
}
