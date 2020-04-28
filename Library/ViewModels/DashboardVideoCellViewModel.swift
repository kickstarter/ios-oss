import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol DashboardVideoCellViewModelInputs {
  /// Call to configure cell with video stats.
  func configureWith(videoStats stats: ProjectStatsEnvelope.VideoStats)
}

public protocol DashboardVideoCellViewModelOutputs {
  /// Emits the total completion percentage to be displayed.
  var completionPercentage: Signal<String, Never> { get }

  /// Emits the count of external starts to be displayed.
  var externalStartCount: Signal<String, Never> { get }

  /// Emits the external start progress to be displayed in a progress bar.
  var externalStartProgress: Signal<CGFloat, Never> { get }

  /// Emits text for the external label.
  var externalText: Signal<String, Never> { get }

  /// Emits the count of internal starts to be displayed.
  var internalStartCount: Signal<String, Never> { get }

  /// Emits the internal start progress to be displayed in a progress bar.
  var internalStartProgress: Signal<CGFloat, Never> { get }

  /// Emits text for the internal label.
  var internalText: Signal<String, Never> { get }

  /// Emits the total count of video starts to be displayed.
  var totalStartCount: Signal<NSAttributedString, Never> { get }
}

public protocol DashboardVideoCellViewModelType {
  var inputs: DashboardVideoCellViewModelInputs { get }
  var outputs: DashboardVideoCellViewModelOutputs { get }
}

public final class DashboardVideoCellViewModel: DashboardVideoCellViewModelInputs,
  DashboardVideoCellViewModelOutputs, DashboardVideoCellViewModelType {
  public init() {
    let videoStats = self.statsProperty.signal.skipNil()

    self.completionPercentage = videoStats
      .map {
        Strings.dashboard_graphs_video_stats_percent_plays_completed(
          percent_plays_completed: formattedCompletionPercentage(videoStats: $0)
        )
      }

    self.externalStartCount = videoStats
      .map { Format.wholeNumber($0.externalStarts) }

    self.externalStartProgress = videoStats.map(externalStartPercentage)

    self.internalStartCount = videoStats
      .map { Format.wholeNumber($0.internalStarts) }

    self.internalStartProgress = videoStats.map(internalStartPercentage)

    self.totalStartCount = videoStats
      .map { // TODO: need new string with count value
        let string = Strings.dashboard_graphs_video_stats_total_plays_count(
          total_start_count: totalStarts(videoStats: $0)
        )
        return string.simpleHtmlAttributedString(font: UIFont.ksr_body(), bold: UIFont.ksr_body().bolded)
          ?? NSAttributedString(string: "")
      }

    self.internalText = videoStats
      .map { Format.percentage(Double(internalStartPercentage(videoStats: $0))) +
        " " + Strings.dashboard_graphs_video_stats_on_kickstarter()
      }

    self.externalText = videoStats
      .map { Format.percentage(Double(externalStartPercentage(videoStats: $0))) +
        " " + Strings.dashboard_graphs_video_stats_off_site()
      }
  }

  fileprivate let statsProperty = MutableProperty<ProjectStatsEnvelope.VideoStats?>(nil)
  public func configureWith(videoStats stats: ProjectStatsEnvelope.VideoStats) {
    self.statsProperty.value = stats
  }

  public let completionPercentage: Signal<String, Never>
  public let externalStartCount: Signal<String, Never>
  public let externalStartProgress: Signal<CGFloat, Never>
  public let externalText: Signal<String, Never>
  public let internalStartCount: Signal<String, Never>
  public let internalStartProgress: Signal<CGFloat, Never>
  public let internalText: Signal<String, Never>
  public let totalStartCount: Signal<NSAttributedString, Never>

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
  return ceil(100.0 * CGFloat(stats.internalStarts) / CGFloat(total)) / 100.0
}

private func totalCompletions(videoStats stats: ProjectStatsEnvelope.VideoStats) -> Int {
  return stats.externalCompletions + stats.internalCompletions
}

private func totalStarts(videoStats stats: ProjectStatsEnvelope.VideoStats) -> Int {
  return stats.externalStarts + stats.internalStarts
}
