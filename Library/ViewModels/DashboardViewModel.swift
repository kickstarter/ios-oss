import KsApi
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

public enum DrawerState {
  case open
  case closed

  public var toggled: DrawerState {
    return self == .open ? .closed : .open
  }
}

public struct DashboardTitleViewData {
  public let drawerState: DrawerState
  public let isArrowHidden: Bool
  public let currentProjectIndex: Int
}

public struct ProjectsDrawerData {
  public let project: Project
  public let indexNum: Int
  public let isChecked: Bool
}

public protocol DashboardViewModelInputs {
  /// Call to switch display to another project from the drawer.
  func dashboardProjectsDrawerSwitchToProject(project: Project)

  /// Call when the projects drawer has animated out.
  func dashboardProjectsDrawerDidAnimateOut()

  /// Call when the project context is tapped.
  func projectContextTapped(project: Project)

  /// Call when to show or hide the projects drawer.
  func showHideProjectsDrawer()

  /// Call when the view did load.
  func viewDidLoad()
}

public protocol DashboardViewModelOutputs {
  /// Emits when should animate out projects drawer.
  var animateOutProjectsDrawer: Signal<(), NoError> { get }

  /// Emits when should dismiss projects drawer.
  var dismissProjectsDrawer: Signal<(), NoError> { get }

  /// Emits the funding stats and project to be displayed in the funding cell.
  var fundingData: Signal<(funding: [ProjectStatsEnvelope.FundingDateStats],
                           project: Project), NoError> { get }


  /// Emits when should present projects drawer with data to populate it.
  var presentProjectsDrawer: Signal<[ProjectsDrawerData], NoError> { get }

  /// Emits the currently selected project to display in the context and action cells.
  var project: Signal<Project, NoError> { get }

  /// Emits the cumulative, project, and referreral distribution data to display in the referrers cell.
  var referrerData: Signal<(cumulative: ProjectStatsEnvelope.CumulativeStats, project: Project,
    stats: [ProjectStatsEnvelope.ReferrerStats]), NoError> { get }

  /// Emits the project, reward stats, and cumulative pledges to display in the rewards cell.
  var rewardData: Signal<(stats: [ProjectStatsEnvelope.RewardStats], project: Project), NoError> { get }

  /// Emits the video stats to display in the video cell.
  var videoStats: Signal<ProjectStatsEnvelope.VideoStats, NoError> { get }

  /// Emits data for the title view.
  var updateTitleViewData: Signal<DashboardTitleViewData, NoError> { get }
}

public protocol DashboardViewModelType {
  var inputs: DashboardViewModelInputs { get }
  var outputs: DashboardViewModelOutputs { get }
}

public final class DashboardViewModel: DashboardViewModelInputs, DashboardViewModelOutputs,
  DashboardViewModelType {

  // swiftlint:disable function_body_length
  public init() {
    let projectAndSelectedProject = self.viewDidLoadProperty.signal
      .switchMap {
        AppEnvironment.current.apiService.fetchProjects(member: true)
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .demoteErrors()
      }
      .flatMap { env -> SignalProducer<([Project], Project), NoError> in
        if let first = env.projects.first {
          return .init(value: (env.projects, first))
        }
        return .empty
      }
      .switchMap { [producer = self.switchToProjectProperty.producer] (projects, mostRecentProject) in
        return producer
          .ignoreNil()
          .map { (projects, $0) }
          .prefix(value: (projects, mostRecentProject))
    }

    let selectedProject = projectAndSelectedProject.map(second)
    self.project = selectedProject

    let fetchStatsEvent = selectedProject
      .switchMap {
        AppEnvironment.current.apiService.fetchProjectStats(projectId: $0.id)
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .materialize()
      }

    let stats = fetchStatsEvent.values()

    self.fundingData = selectedProject
      .takePairWhen(stats)
      .map { project, stats in
        (funding: stats.fundingDistribution, project: project)
    }

    self.referrerData = selectedProject
      .takePairWhen(stats)
      .map { project, stats in
        (cumulative: stats.cumulativeStats, project: project, stats: stats.referralDistribution)
    }

    self.videoStats = stats.map { $0.videoStats }.ignoreNil()

    self.rewardData = selectedProject
      .takePairWhen(stats)
      .map { project, stats in
        (stats: stats.rewardDistribution, project: project)
    }

    let drawerStateProjectsAndSelectedProject = Signal.merge(
      projectAndSelectedProject.map { ($0, $1, false) },
      projectAndSelectedProject.takeWhen(showHideProjectsDrawerProperty.signal).map { ($0, $1, true) }
      )
      .scan(nil) { (data, projectsProjectToggle) -> (DrawerState, [Project], Project)? in

        let (projects, project, toggle) = projectsProjectToggle

        return (
          toggle ? (data?.0.toggled ?? DrawerState.closed) : DrawerState.closed,
          projects,
          project
        )
      }
      .ignoreNil()

    self.updateTitleViewData = drawerStateProjectsAndSelectedProject
      .map { drawerState, projects, selectedProject in
        DashboardTitleViewData(
          drawerState: drawerState,
          isArrowHidden: projects.count <= 1,
          currentProjectIndex: projects.indexOf(selectedProject) ?? 0
        )
    }

    let updateDrawerStateToOpen = self.updateTitleViewData
      .map { $0.drawerState == .open }
      .skip(1)

    self.presentProjectsDrawer = drawerStateProjectsAndSelectedProject
      .filter { drawerState, _, _ in drawerState == .open }
      .map { _, projects, selectedProject in
        projects.map { project in
          ProjectsDrawerData(
            project: project,
            indexNum: projects.indexOf(project) ?? 0,
            isChecked: project == selectedProject
          )
        }
    }

    self.animateOutProjectsDrawer = updateDrawerStateToOpen
      .filter(isFalse)
      .ignoreValues()

    self.dismissProjectsDrawer = self.projectsDrawerDidAnimateOutProperty.signal

    self.projectContextTappedProperty.signal.ignoreNil()
      .observeNext { AppEnvironment.current.koala.trackDashboardProjectModalView(project: $0) }

    selectedProject
      .take(1)
      .observeNext { AppEnvironment.current.koala.trackDashboardView(project: $0) }

    selectedProject
      .takeWhen(updateDrawerStateToOpen.filter(isTrue))
      .observeNext { AppEnvironment.current.koala.trackDashboardShowProjectSwitcher(onProject: $0) }

    selectedProject
      .takeWhen(updateDrawerStateToOpen.filter(isFalse))
      .observeNext { AppEnvironment.current.koala.trackDashboardClosedProjectSwitcher(onProject: $0) }

    self.switchToProjectProperty.signal.ignoreNil()
      .observeNext { AppEnvironment.current.koala.trackDashboardSwitchProject($0) }
  }
  // swiftlint:enable function_body_length

  private let showHideProjectsDrawerProperty = MutableProperty()
  public func showHideProjectsDrawer() {
    self.showHideProjectsDrawerProperty.value = ()
  }
  private let projectContextTappedProperty = MutableProperty<Project?>(nil)
  public func projectContextTapped(project: Project) {
    self.projectContextTappedProperty.value = project
  }
  private let switchToProjectProperty = MutableProperty<Project?>(nil)
  public func dashboardProjectsDrawerSwitchToProject(project: Project) {
    self.switchToProjectProperty.value = project
  }
  private let projectsDrawerDidAnimateOutProperty = MutableProperty()
  public func dashboardProjectsDrawerDidAnimateOut() {
    self.projectsDrawerDidAnimateOutProperty.value = ()
  }
  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let animateOutProjectsDrawer: Signal<(), NoError>
  public let dismissProjectsDrawer: Signal<(), NoError>
  public let fundingData: Signal<(funding: [ProjectStatsEnvelope.FundingDateStats],
    project: Project), NoError>
  public let project: Signal<Project, NoError>
  public let presentProjectsDrawer: Signal<[ProjectsDrawerData], NoError>
  public let referrerData: Signal<(cumulative: ProjectStatsEnvelope.CumulativeStats, project: Project,
    stats: [ProjectStatsEnvelope.ReferrerStats]), NoError>
  public let rewardData: Signal<(stats: [ProjectStatsEnvelope.RewardStats], project: Project), NoError>
  public let videoStats: Signal<ProjectStatsEnvelope.VideoStats, NoError>
  public let updateTitleViewData: Signal<DashboardTitleViewData, NoError>

  public var inputs: DashboardViewModelInputs { return self }
  public var outputs: DashboardViewModelOutputs { return self }
}

extension ProjectsDrawerData: Equatable {}
public func == (lhs: ProjectsDrawerData, rhs: ProjectsDrawerData) -> Bool {
  return lhs.project.id == rhs.project.id
}

extension DashboardTitleViewData: Equatable {}
public func == (lhs: DashboardTitleViewData, rhs: DashboardTitleViewData) -> Bool {
  return lhs.drawerState == rhs.drawerState &&
         lhs.currentProjectIndex == rhs.currentProjectIndex &&
         lhs.isArrowHidden == rhs.isArrowHidden
}
