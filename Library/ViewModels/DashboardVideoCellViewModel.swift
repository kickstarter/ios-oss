import KsApi
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol DashboardVideoCellViewModelInputs {
  /// Call to configure cell with video stats.
  func configureWith(videoStats stats: ProjectStatsEnvelope.VideoStats)
}

public protocol DashboardVideoCellViewModelOutputs {
  /// Emits the total completion percentage to be displayed.
  var completionPercentage: Signal<String, NoError> { get }

  /// Emits the count of external starts to be displayed.
  var externalStartCount: Signal<String, NoError> { get }

  /// Emits the external start progress to be displayed in a progress bar..
  var externalStartProgress: Signal<CGFloat, NoError> { get }

  /// Emits the count of internal starts to be displayed.
  var internalStartCount: Signal<String, NoError> { get }

  /// Emits the internal start progress to be displayed in a progress bar.
  var internalStartProgress: Signal<CGFloat, NoError> { get }

  /// Emits the total count of video starts to be displayed.
  var totalStartCount: Signal<String, NoError> { get }
}

public protocol DashboardVideoCellViewModelType {
  var inputs: DashboardVideoCellViewModelInputs { get }
  var outputs: DashboardVideoCellViewModelOutputs { get }
}

public final class DashboardVideoCellViewModel: DashboardVideoCellViewModelInputs,
  DashboardVideoCellViewModelOutputs, DashboardVideoCellViewModelType {

  public init() {
    let videoStats = self.statsProperty.signal.ignoreNil()

    self.completionPercentage = videoStats
      .map {
        Strings.dashboard_graphs_video_stats_percent_plays_completed(
          percent_plays_completed: formattedCompletionPercentage(videoStats: $0)
        )
    }

    self.externalStartCount = videoStats
      .map {
        Strings.dashboard_graphs_video_stats_external_start_count_off_site(
          external_start_count: Format.wholeNumber($0.externalStarts)
        )
    }

    self.externalStartProgress = videoStats.map(externalStartPercentage)

    self.internalStartCount = videoStats
      .map {
        Strings.dashboard_graphs_video_stats_internal_start_count_on_kickstarter(
          internal_start_count: Format.wholeNumber($0.internalStarts)
        )
    }

    self.internalStartProgress = videoStats.map(internalStartPercentage)

    self.totalStartCount = videoStats
      .map {
        Strings.dashboard_graphs_video_stats_total_plays(
          total_start_count: Format.wholeNumber(totalStarts(videoStats: $0))
        )
    }
  }

  private let statsProperty = MutableProperty<ProjectStatsEnvelope.VideoStats?>(nil)
  public func configureWith(videoStats stats: ProjectStatsEnvelope.VideoStats) {
    self.statsProperty.value = stats
  }

  public let completionPercentage: Signal<String, NoError>
  public let externalStartCount: Signal<String, NoError>
  public let externalStartProgress: Signal<CGFloat, NoError>
  public let internalStartCount: Signal<String, NoError>
  public let internalStartProgress: Signal<CGFloat, NoError>
  public let totalStartCount: Signal<String, NoError>

  public var inputs: DashboardVideoCellViewModelInputs { return self }
  public var outputs: DashboardVideoCellViewModelOutputs { return self }
}

// Formatted string percent of video completions.
private func formattedCompletionPercentage(videoStats stats: ProjectStatsEnvelope.VideoStats) -> String {
  let totalCompletionCount = CGFloat(totalCompletions(videoStats: stats))
  let totalStartCount = CGFloat(totalStarts(videoStats: stats))
  return Format.percentage(Int(floor(100 * totalCompletionCount / totalStartCount)))
}

// Percent ratio of external starts to total starts measured from `0.0` to `1.0`.
private func externalStartPercentage(videoStats stats: ProjectStatsEnvelope.VideoStats) -> CGFloat {
  let internalStarts = internalStartPercentage(videoStats: stats)
  return 1.0 - internalStarts
}

// Percent ratio of internal starts to total starts measured from `0.0` to `1.0`.
private func internalStartPercentage(videoStats stats: ProjectStatsEnvelope.VideoStats) -> CGFloat {
  let total = totalStarts(videoStats: stats)
  return CGFloat(stats.internalStarts) / CGFloat(total)
}

private func totalCompletions(videoStats stats: ProjectStatsEnvelope.VideoStats) -> Int {
  return stats.externalCompletions + stats.internalCompletions
}

private func totalStarts(videoStats stats: ProjectStatsEnvelope.VideoStats) -> Int {
  return stats.externalStarts + stats.internalStarts
}
