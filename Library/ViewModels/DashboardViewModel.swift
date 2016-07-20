import KsApi
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol DashboardViewModelInputs {
  /// Call when the project context is tapped.
  func projectContextTapped(project: Project)

  /// Call when the view did load.
  func viewDidLoad()
}

public protocol DashboardViewModelOutputs {
  /// Emits the funding stats and project to be displayed in the funding cell.
  var fundingData: Signal<(funding: [ProjectStatsEnvelope.FundingDateStats],
                           project: Project), NoError> { get }

  /// Emits the currently selected project to be displayed in the context and action cells.
  var project: Signal<Project, NoError> { get }

  /// Emits the list of created projects to be displayed in the project switcher.
  var projects: Signal<[Project], NoError> { get }

  /// Emits the cumulative, project, and referreral distribution data to be displayed in the referrers cell.
  var referrerData: Signal<(cumulative: ProjectStatsEnvelope.CumulativeStats, project: Project,
    stats: [ProjectStatsEnvelope.ReferrerStats]), NoError> { get }

  /// Emits the reward stats and project to be displayed in the rewards cell.
  var rewardData: Signal<(stats: [ProjectStatsEnvelope.RewardStats], project: Project), NoError> { get }

  /// Emits the video stats to be displayed in the video cell.
  var videoStats: Signal<ProjectStatsEnvelope.VideoStats, NoError> { get }
}

public protocol DashboardViewModelType {
  var inputs: DashboardViewModelInputs { get }
  var outputs: DashboardViewModelOutputs { get }
}

public final class DashboardViewModel: DashboardViewModelInputs, DashboardViewModelOutputs,
  DashboardViewModelType {

  public init() {
    self.projects = self.viewDidLoadProperty.signal
      .switchMap {
        AppEnvironment.current.apiService.fetchProjects(member: true)
          .demoteErrors()
      }
      .map { $0.projects }

    let project = self.projects.map { $0.first }.ignoreNil()

    let fetchStatsEvent = project
      .switchMap {
        AppEnvironment.current.apiService.fetchProjectStats(projectId: $0.id)
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .materialize()
      }

    let stats = fetchStatsEvent.values()

    self.fundingData = project
      .takePairWhen(stats)
      .map { project, stats in
        (funding: stats.fundingDistribution, project: project)
    }

    self.project = project

    self.referrerData = project
      .takePairWhen(stats)
      .map { project, stats in
        (cumulative: stats.cumulativeStats, project: project, stats: stats.referralDistribution)
    }

    self.videoStats = stats.map { $0.videoStats }.ignoreNil()

    self.rewardData = project
      .takePairWhen(stats)
      .map { project, stats in
        (stats: stats.rewardDistribution, project: project)
    }

    let projectFromTap = self.projectContextTappedProperty.signal.ignoreNil()

    projectFromTap.observeNext { AppEnvironment.current.koala.trackDashboardProjectModalView(project: $0) }

    project.observeNext { AppEnvironment.current.koala.trackDashboardView(project: $0) }
  }

  private let projectContextTappedProperty = MutableProperty<Project?>(nil)
  public func projectContextTapped(project: Project) {
    self.projectContextTappedProperty.value = project
  }
  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let fundingData: Signal<(funding: [ProjectStatsEnvelope.FundingDateStats],
                                  project: Project), NoError>
  public let project: Signal<Project, NoError>
  public let projects: Signal<[Project], NoError>
  public let referrerData: Signal<(cumulative: ProjectStatsEnvelope.CumulativeStats, project: Project,
    stats: [ProjectStatsEnvelope.ReferrerStats]), NoError>
  public let rewardData: Signal<(stats: [ProjectStatsEnvelope.RewardStats], project: Project), NoError>
  public let videoStats: Signal<ProjectStatsEnvelope.VideoStats, NoError>

  public var inputs: DashboardViewModelInputs { return self }
  public var outputs: DashboardViewModelOutputs { return self }
}
