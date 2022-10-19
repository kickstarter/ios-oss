import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift
import UIKit

public struct FundingGraphData {
  public let project: Project
  public let stats: [ProjectStatsEnvelope.FundingDateStats]
  public let yAxisTickSize: CGFloat
}

extension FundingGraphData: Equatable {}
public func == (lhs: FundingGraphData, rhs: FundingGraphData) -> Bool {
  return
    lhs.project == rhs.project &&
    lhs.stats == rhs.stats &&
    lhs.yAxisTickSize == rhs.yAxisTickSize
}

public protocol DashboardFundingCellViewModelInputs {
  /// Call to configure cell with funding stats and project data.
  func configureWith(
    fundingDateStats stats: [ProjectStatsEnvelope.FundingDateStats],
    project: Project
  )
}

public protocol DashboardFundingCellViewModelOutputs {
  /// Emits the backers count text to be displayed.
  var backersText: Signal<String, Never> { get }

  /// Emits the relevant cell information to be spoken on VoiceOver.
  var cellAccessibilityValue: Signal<String, Never> { get }

  /// Emits the deadline date text (e.g. Jul 26) to be displayed.
  var deadlineDateText: Signal<String, Never> { get }

  /// Emits the disparate funding data to be displayed in the funding graph.
  var graphData: Signal<FundingGraphData, Never> { get }

  /// Emits the pledged of goal text to be displayed.
  var goalText: Signal<String, Never> { get }

  /// Emits the launch date text (e.g. Jun 26) to be displayed.
  var launchDateText: Signal<String, Never> { get }

  /// Emits the amount pledged text to be displayed.
  var pledgedText: Signal<String, Never> { get }

  /// Emits the time remaining (units) text to be displayed.
  var timeRemainingSubtitleText: Signal<String, Never> { get }

  /// Emits the time remaining (value) text to be displayed.
  var timeRemainingTitleText: Signal<String, Never> { get }

  /// Emits the bottom y axis pledge interval label to be displayed.
  var graphYAxisBottomLabelText: Signal<String, Never> { get }

  /// Emits the middle y axis pledge interval label to be displayed.
  var graphYAxisMiddleLabelText: Signal<String, Never> { get }

  /// Emits the top y axis pledge interval label to be displayed.
  var graphYAxisTopLabelText: Signal<String, Never> { get }
}

public protocol DashboardFundingCellViewModelType {
  var inputs: DashboardFundingCellViewModelInputs { get }
  var outputs: DashboardFundingCellViewModelOutputs { get }
}

public final class DashboardFundingCellViewModel: DashboardFundingCellViewModelInputs,
  DashboardFundingCellViewModelOutputs, DashboardFundingCellViewModelType {
  public static let tickCount = 4

  public init() {
    let statsProject = self.statsProjectProperty.signal.skipNil()

    self.backersText = statsProject.map { _, project in Format.wholeNumber(project.stats.backersCount) }

    self.deadlineDateText = statsProject.map { _, project in
      Format.date(secondsInUTC: project.dates.deadline, dateStyle: .short, timeStyle: .none)
    }

    self.goalText = statsProject.map { _, project in
      Strings.discovery_baseball_card_stats_pledged_of_goal(
        goal: Format.currency(project.stats.goal, country: project.country)
      )
    }

    self.graphData = statsProject
      .map { stats, project in
        let maxPledged = stats.map { $0.cumulativePledged }.max() ?? 0
        let range = Double(maxPledged > project.stats.goal ? maxPledged : project.stats.goal)

        return FundingGraphData(
          project: project,
          stats: stats,
          yAxisTickSize: tickSize(DashboardFundingCellViewModel.tickCount, range: range)
        )
      }

    self.graphYAxisBottomLabelText = self.graphData
      .map { data in Format.currency(Int(data.yAxisTickSize), country: data.project.country) }

    self.graphYAxisMiddleLabelText = self.graphData
      .map { data in Format.currency(Int(data.yAxisTickSize * 2), country: data.project.country) }

    self.graphYAxisTopLabelText = self.graphData
      .map { data in Format.currency(Int(data.yAxisTickSize * 3), country: data.project.country) }

    self.launchDateText = statsProject
      .map { _, project in
        Format.date(secondsInUTC: project.dates.launchedAt, dateStyle: .short, timeStyle: .none)
      }

    self.pledgedText = statsProject
      .map { _, project in Format.currency(project.stats.pledged, country: project.country) }

    let timeRemaining = statsProject.map { _, project in
      Format.duration(secondsInUTC: project.dates.deadline, useToGo: true)
    }

    self.timeRemainingTitleText = timeRemaining.map(first)
    self.timeRemainingSubtitleText = timeRemaining.map(second)

    self.cellAccessibilityValue = statsProject
      .map { _, project in

        let pledged = Format.currency(project.stats.pledged, country: project.country)
        let goal = Format.currency(project.stats.goal, country: project.country)
        let backersCount = project.stats.backersCount
        let (time, unit) = Format.duration(secondsInUTC: project.dates.deadline, useToGo: false)
        let timeLeft = time + " " + unit

        return project.state == .live ?
          Strings.dashboard_graphs_funding_accessibility_live_stat_value(
            pledged: pledged, goal: goal, backers_count: backersCount, time_left: timeLeft
          ) :
          Strings.dashboard_graphs_funding_accessibility_non_live_stat_value(
            pledged: pledged, goal: goal, backers_count: backersCount, time_left: timeLeft
          )
      }
  }

  private let statsProjectProperty = MutableProperty<([ProjectStatsEnvelope.FundingDateStats], Project)?>(nil)
  public func configureWith(
    fundingDateStats stats: [ProjectStatsEnvelope.FundingDateStats],
    project: Project
  ) {
    self.statsProjectProperty.value = (stats, project)
  }

  public let backersText: Signal<String, Never>
  public let cellAccessibilityValue: Signal<String, Never>
  public let deadlineDateText: Signal<String, Never>
  public let goalText: Signal<String, Never>
  public let graphData: Signal<FundingGraphData, Never>
  public let graphYAxisBottomLabelText: Signal<String, Never>
  public let graphYAxisMiddleLabelText: Signal<String, Never>
  public let graphYAxisTopLabelText: Signal<String, Never>
  public let launchDateText: Signal<String, Never>
  public let pledgedText: Signal<String, Never>
  public let timeRemainingSubtitleText: Signal<String, Never>
  public let timeRemainingTitleText: Signal<String, Never>

  public var inputs: DashboardFundingCellViewModelInputs { return self }
  public var outputs: DashboardFundingCellViewModelOutputs { return self }
}

// Returns the tick size relative to the number of ticks in a range.
private func tickSize(_ tickCount: Int, range: Double) -> CGFloat {
  let unroundedTickSize = range / (Double(tickCount) - 1.0)
  let exponent = ceil(log10(unroundedTickSize) - 1.0)
  let power = pow(10.0, exponent)
  return CGFloat(ceil(unroundedTickSize / power) * power)
}
