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
  /// Emits the project and ref tag when should go to project page.
  var goToProject: Signal<(Project, RefTag), NoError > { get }

  /// Emits the currently selected project to display in the context and action cells.
  var project: Signal<Project, NoError> { get }

  /// Emits the list of created projects to display in the project switcher.
  var projects: Signal<[Project], NoError> { get }

  /// Emits the project, reward stats, and cumulative pledges to display in the rewards cell.
  var rewardStats: Signal<(stats: [ProjectStatsEnvelope.RewardStats], project: Project), NoError> { get }

  /// Emits the video stats to display in the video cell.
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

    self.project = project

    let stats = project
      .switchMap {
        AppEnvironment.current.apiService.fetchProjectStats(projectId: $0.id)
          .demoteErrors()
      }

    self.videoStats = stats.map { $0.videoStats }.ignoreNil()

    self.rewardStats = project
      .takePairWhen(stats)
      .map { project, stats in
        (stats: stats.rewardStats, project: project)
    }

    let projectFromTap = self.projectContextTappedProperty.signal.ignoreNil()

    self.goToProject = projectFromTap
      .map { ($0, RefTag.dashboard) }

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

  public let goToProject: Signal<(Project, RefTag), NoError>
  public let project: Signal<Project, NoError>
  public let projects: Signal<[Project], NoError>
  public let rewardStats: Signal<(stats: [ProjectStatsEnvelope.RewardStats], project: Project), NoError>
  public let videoStats: Signal<ProjectStatsEnvelope.VideoStats, NoError>

  public var inputs: DashboardViewModelInputs { return self }
  public var outputs: DashboardViewModelOutputs { return self }
}
