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
  func `switch`(toProject param: Param)

  /// Call when the projects drawer has animated out.
  func dashboardProjectsDrawerDidAnimateOut()

  /// Call when the project context cell is tapped.
  func projectContextCellTapped()

  /// Call when to show or hide the projects drawer.
  func showHideProjectsDrawer()

  /// Call when the view did appear.
  func viewDidAppear()
}

public protocol DashboardViewModelOutputs {
  /// Emits when should animate out projects drawer.
  var animateOutProjectsDrawer: Signal<(), NoError> { get }

  /// Emits when should dismiss projects drawer.
  var dismissProjectsDrawer: Signal<(), NoError> { get }

  /// Emits when to focus the screen reader on the titleView.
  var focusScreenReaderOnTitleView: Signal<(), NoError> { get }

  /// Emits the funding stats and project to be displayed in the funding cell.
  var fundingData: Signal<(funding: [ProjectStatsEnvelope.FundingDateStats],
                           project: Project), NoError> { get }

  /// Emits when to go to the project page.
  var goToProject: Signal<(Project, RefTag), NoError> { get }

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
    let projects = self.viewDidAppearProperty.signal
      .switchMap {
        AppEnvironment.current.apiService.fetchProjects(member: true)
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .demoteErrors()
          .map { $0.projects }
    }

    let projectsAndSelected = projects
      .switchMap { [switchToProject = switchToProjectProperty.producer] projects in
        switchToProject
          .map { param in
            find(projectForParam: param, in: projects) ?? projects.first
          }
          .ignoreNil()
          .map { (projects, $0) }
    }

    self.project = projectsAndSelected.map(second)

    let selectedProjectAndStatsEvent = self.project
      .switchMap { project in
        AppEnvironment.current.apiService.fetchProjectStats(projectId: project.id)
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .map { (project, $0) }
          .materialize()
      }

    let selectedProjectAndStats = selectedProjectAndStatsEvent.values()

    self.fundingData = selectedProjectAndStats
      .map { project, stats in
        (funding: stats.fundingDistribution, project: project)
    }

    self.referrerData = selectedProjectAndStats
      .map { project, stats in
        (cumulative: stats.cumulativeStats, project: project, stats: stats.referralDistribution)
    }

    self.videoStats = selectedProjectAndStats.map { _, stats in stats.videoStats }.ignoreNil()

    self.rewardData = selectedProjectAndStats
      .map { project, stats in
        (stats: stats.rewardDistribution, project: project)
    }

    let drawerStateProjectsAndSelectedProject = Signal.merge(
      projectsAndSelected.map { ($0, $1, false) },
      projectsAndSelected.takeWhen(showHideProjectsDrawerProperty.signal).map { ($0, $1, true) }
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

    self.goToProject = self.project
      .takeWhen(self.projectContextCellTappedProperty.signal)
      .map { ($0, RefTag.dashboard) }

    self.focusScreenReaderOnTitleView = self.viewDidAppearProperty.signal

    self.project
      .takeWhen(self.projectContextCellTappedProperty.signal)
      .observeNext { AppEnvironment.current.koala.trackDashboardProjectModalView(project: $0) }

    self.project
      .take(1)
      .observeNext { AppEnvironment.current.koala.trackDashboardView(project: $0) }

    self.project
      .takeWhen(updateDrawerStateToOpen.filter(isTrue))
      .observeNext { AppEnvironment.current.koala.trackDashboardShowProjectSwitcher(onProject: $0) }

    self.project
      .takeWhen(updateDrawerStateToOpen.filter(isFalse))
      .observeNext { AppEnvironment.current.koala.trackDashboardClosedProjectSwitcher(onProject: $0) }

    self.project
      .skip(1)
      .takeWhen(updateDrawerStateToOpen.filter(isFalse))
      .skipRepeats()
      .observeNext { AppEnvironment.current.koala.trackDashboardSwitchProject($0) }
  }
  // swiftlint:enable function_body_length

  private let showHideProjectsDrawerProperty = MutableProperty()
  public func showHideProjectsDrawer() {
    self.showHideProjectsDrawerProperty.value = ()
  }
  private let projectContextCellTappedProperty = MutableProperty()
  public func projectContextCellTapped() {
    self.projectContextCellTappedProperty.value = ()
  }
  private let switchToProjectProperty = MutableProperty<Param?>(nil)
  public func `switch`(toProject param: Param) {
    self.switchToProjectProperty.value = param
  }
  private let projectsDrawerDidAnimateOutProperty = MutableProperty()
  public func dashboardProjectsDrawerDidAnimateOut() {
    self.projectsDrawerDidAnimateOutProperty.value = ()
  }
  private let viewDidAppearProperty = MutableProperty()
  public func viewDidAppear() {
    self.viewDidAppearProperty.value = ()
  }

  public let animateOutProjectsDrawer: Signal<(), NoError>
  public let dismissProjectsDrawer: Signal<(), NoError>
  public let focusScreenReaderOnTitleView: Signal<(), NoError>
  public let fundingData: Signal<(funding: [ProjectStatsEnvelope.FundingDateStats],
    project: Project), NoError>
  public let goToProject: Signal<(Project, RefTag), NoError>
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

private func find(projectForParam param: Param?, in projects: [Project]) -> Project? {
  guard let param = param else { return nil }

  return projects.filter { project in
    if case .id(project.id) = param { return true }
    if case .slug(project.slug) = param { return true }
    return false
  }.first
}
