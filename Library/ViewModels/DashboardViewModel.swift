import KsApi
import Prelude
import ReactiveSwift
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
  /// Call to navigate to activities for project with id
  func activitiesNavigated(projectId: Param)

  /// Call to switch display to another project from the drawer.
  func `switch`(toProject param: Param)

  /// Call when the projects drawer has animated out.
  func dashboardProjectsDrawerDidAnimateOut()

  /// Call to open message thread for specific project
  func messageThreadNavigated(projectId: Param, messageThread: MessageThread)

  /// Call to open project messages thread
  func openMessageThreadRequested()

  /// Call when the project context cell is tapped.
  func projectContextCellTapped()

  /// Call when to show or hide the projects drawer.
  func showHideProjectsDrawer()

  /// Call when the view will appear.
  func viewWillAppear(animated: Bool)

  /// Call when the view will disappear
  func viewWillDisappear()
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

  /// Emits when navigating to project activities
  var goToActivities: Signal<Project, NoError> { get }

  /// Emits when to go to project messages thread
  var goToMessages: Signal<Project, NoError> { get }

  /// Emits when opening specific project message thread
  var goToMessageThread: Signal<(Project, MessageThread), NoError> { get }

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

  //We use producers ot this properties during view appearance and projects retreaval process 
  //to avoid any race condisions and keep last selected project param "handy" 
  //for the moment projects are reteaved
  private let selectedProjectProperty: SignalProducer<Param?, NoError>
  private let selectProjectPropertyOrFirst = MutableProperty<Param?>(nil)
  private let messageThreadReceived = MutableProperty<(Param, MessageThread)?>(nil)
  private let navigateToActivitiesReceived =  MutableProperty<Param?>(nil)

  public init() {
    let projects = self.viewWillAppearAnimatedProperty.signal.filter(isFalse).ignoreValues()
      .switchMap {
        AppEnvironment.current.apiService.fetchProjects(member: true)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .demoteErrors()
          .map { $0.projects }
          .prefix(value: [])
    }

    self.selectedProjectProperty = SignalProducer.merge(
      self.switchToProjectProperty.producer,
      self.messageThreadNavigatedProperty.producer.skipNil().map { $0.0 }
    )

    self.selectProjectPropertyOrFirst <~ SignalProducer.combineLatest(
      self.selectedProjectProperty,
      self.viewWillAppearAnimatedProperty.producer.ignoreValues()
    )
    .map { $0.0 }
    .skipRepeats { lhs, rhs in lhs == rhs }

    let projectsAndSelected = projects
      .switchMap { [switchToProject = self.selectProjectPropertyOrFirst.producer] projects in
        switchToProject
          .map { param -> Project? in
            guard let param = param else {
              return projects.first
            }

            return find(projectForParam: param, in: projects) ?? projects.first
          }
          .skipNil()
          .map { (projects, $0) }
    }

    self.project = projectsAndSelected.map(second)

    self.messageThreadReceived <~ Signal.merge(
      self.viewWillDisappearProperty.signal.mapConst(nil),
      self.messageThreadNavigatedProperty.signal
    )

    self.goToMessageThread = project
      .switchMap { [messageThreadReceived = self.messageThreadReceived.producer] project in
        messageThreadReceived
          .skipNil()
          .filter { $0.0 == .id(project.id) }
          .map { (messgeThreadPair: (Param, MessageThread)) -> (Project, MessageThread) in
            return (project, messgeThreadPair.1)
          }
      }

    self.navigateToActivitiesReceived <~ Signal.merge(
      self.viewWillDisappearProperty.signal.mapConst(nil),
      self.activitiesNavigatedProperty.signal
    )

    self.goToActivities = project
      .switchMap { [navigateToActivitiesReceived = self.navigateToActivitiesReceived.producer] project in
        navigateToActivitiesReceived
          .skipNil()
          .filter { $0 == .id(project.id) }
          .map { _ in project }
    }



    let selectedProjectAndStatsEvent = self.project
      .switchMap { project in
        AppEnvironment.current.apiService.fetchProjectStats(projectId: project.id)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
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

    self.videoStats = selectedProjectAndStats.map { _, stats in stats.videoStats }.skipNil()

    self.rewardData = selectedProjectAndStats
      .map { project, stats in
        (stats: stats.rewardDistribution, project: project)
    }

    let drawerStateProjectsAndSelectedProject = Signal.merge(
      projectsAndSelected.map { ($0.0, $0.1, false) },
      projectsAndSelected
        .map { ($0.0, $0.1) }
        .takeWhen(self.showHideProjectsDrawerProperty.signal).map { ($0, $1, true) })
      .scan(nil) { (data, projectsProjectToggle) -> (DrawerState, [Project], Project)? in
        let (projects, project, toggle) = projectsProjectToggle

        return (
          toggle ? (data?.0.toggled ?? DrawerState.closed) : DrawerState.closed,
          projects,
          project
        )
      }
      .skipNil()

    self.updateTitleViewData = drawerStateProjectsAndSelectedProject
      .map { drawerState, projects, selectedProject in
        DashboardTitleViewData(
          drawerState: drawerState,
          isArrowHidden: projects.count <= 1,
          currentProjectIndex: projects.index(of: selectedProject) ?? 0
        )
    }

    let updateDrawerStateToOpen = self.updateTitleViewData
      .map { $0.drawerState == .open }
      .skip(first: 1)

    self.presentProjectsDrawer = drawerStateProjectsAndSelectedProject
      .filter { drawerState, _, _ in drawerState == .open }
      .map { _, projects, selectedProject in
        projects.map { project in
          ProjectsDrawerData(
            project: project,
            indexNum: projects.index(of: project) ?? 0,
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

    self.goToMessages = self.project
      .takeWhen(self.openMessageThreadRequestedProperty.signal)

    self.focusScreenReaderOnTitleView = self.viewWillAppearAnimatedProperty.signal.ignoreValues()

    let projectForTrackingViews = Signal.merge(
      projects.map { $0.first }.skipNil().take(first: 1),
      self.project
        .takeWhen(self.viewWillAppearAnimatedProperty.signal.filter(isFalse))
    )

    projectForTrackingViews
      .observeValues { AppEnvironment.current.koala.trackDashboardView(project: $0) }

    self.project
      .takeWhen(self.presentProjectsDrawer)
      .observeValues { AppEnvironment.current.koala.trackDashboardShowProjectSwitcher(onProject: $0) }

    let drawerHasClosedAndShouldTrack = Signal.merge(
      self.showHideProjectsDrawerProperty.signal.map { (drawerState: true, shouldTrack: true) },
      self.switchToProjectProperty.signal.map { _ in (drawerState: true, shouldTrack: false) }
      )
      .scan(nil) { (data, toggledStateAndShouldTrack) -> (DrawerState, Bool)? in
        let (drawerState, shouldTrack) = toggledStateAndShouldTrack
        return drawerState
          ? ((data?.0.toggled ?? DrawerState.closed), shouldTrack)
          : (DrawerState.closed, shouldTrack)
      }
      .skipNil()
      .filter { drawerState, _ in drawerState == .open }
      .map { _, shouldTrack in shouldTrack }

    self.project
      .takePairWhen(drawerHasClosedAndShouldTrack)
      .filter { _, shouldTrack in shouldTrack }
      .observeValues { project, _ in
        AppEnvironment.current.koala.trackDashboardClosedProjectSwitcher(onProject: project)
    }

    projects
      .takePairWhen(self.selectProjectPropertyOrFirst.signal)
      .map { projects, param in find(projectForParam: param, in: projects) }
      .skipNil()
      .observeValues { AppEnvironment.current.koala.trackDashboardSwitchProject($0) }
  }

  // swiftlint:enable function_body_length
  fileprivate let showHideProjectsDrawerProperty = MutableProperty()
  public func showHideProjectsDrawer() {
    self.showHideProjectsDrawerProperty.value = ()
  }
  fileprivate let projectContextCellTappedProperty = MutableProperty()
  public func projectContextCellTapped() {
    self.projectContextCellTappedProperty.value = ()
  }
  fileprivate let switchToProjectProperty = MutableProperty<Param?>(nil)
  public func `switch`(toProject param: Param) {
    self.switchToProjectProperty.value = param
  }
  fileprivate let activitiesNavigatedProperty = MutableProperty<Param?>(nil)
  public func activitiesNavigated(projectId: Param) {
    self.activitiesNavigatedProperty.value = projectId
  }
  fileprivate let messageThreadNavigatedProperty = MutableProperty<(Param, MessageThread)?>(nil)
  public func messageThreadNavigated(projectId: Param, messageThread: MessageThread) {
    self.messageThreadNavigatedProperty.value = (projectId, messageThread)
  }
  fileprivate let projectsDrawerDidAnimateOutProperty = MutableProperty()
  public func dashboardProjectsDrawerDidAnimateOut() {
    self.projectsDrawerDidAnimateOutProperty.value = ()
  }
  fileprivate let viewWillAppearAnimatedProperty = MutableProperty(false)
  public func viewWillAppear(animated: Bool) {
    self.viewWillAppearAnimatedProperty.value = animated
  }
  fileprivate let viewWillDisappearProperty = MutableProperty()
  public func viewWillDisappear() {
    self.viewWillDisappearProperty.value = ()
  }
  fileprivate let openMessageThreadRequestedProperty = MutableProperty()
  public func openMessageThreadRequested() {
    self.openMessageThreadRequestedProperty.value = ()
  }

  public let animateOutProjectsDrawer: Signal<(), NoError>
  public let dismissProjectsDrawer: Signal<(), NoError>
  public let focusScreenReaderOnTitleView: Signal<(), NoError>
  public let fundingData: Signal<(funding: [ProjectStatsEnvelope.FundingDateStats],
    project: Project), NoError>
  public let goToActivities: Signal<Project, NoError>
  public let goToMessages: Signal<Project, NoError>
  public let goToMessageThread: Signal<(Project, MessageThread), NoError>
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
