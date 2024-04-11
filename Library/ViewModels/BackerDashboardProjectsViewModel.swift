import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol BackerDashboardProjectsViewModelInputs {
  /// Call to configure with the ProfileProjectsType to display and the default sort.
  func configureWith(projectsType: ProfileProjectsType, sort: DiscoveryParams.Sort)

  /// Call when the user has updated.
  func currentUserUpdated()

  /// Call when a project cell is tapped.
  func projectTapped(_ project: Project)

  /// Call when pull-to-refresh is invoked.
  func refresh()

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the view will appear.
  func viewWillAppear(_ animated: Bool)

  /// Call when a new row is displayed.
  func willDisplayRow(_ row: Int, outOf totalRows: Int)
}

public protocol BackerDashboardProjectsViewModelOutputs {
  /// Emits a boolean that determines if the empty state is visible and a ProfileProjectsType.
  var emptyStateIsVisible: Signal<(Bool, ProfileProjectsType), Never> { get }

  /// Emits the project, projects, and ref tag when should go to project page.
  var goToProject: Signal<(Project, [Project], RefTag), Never> { get }

  /// Emits when the pull-to-refresh control is refreshing or not.
  var isRefreshing: Signal<Bool, Never> { get }

  /// Emits a list of projects for the tableview datasource.
  var projects: Signal<[Project], Never> { get }
}

public protocol BackerDashboardProjectsViewModelType {
  var inputs: BackerDashboardProjectsViewModelInputs { get }
  var outputs: BackerDashboardProjectsViewModelOutputs { get }
}

public final class BackerDashboardProjectsViewModel: BackerDashboardProjectsViewModelType,
  BackerDashboardProjectsViewModelInputs, BackerDashboardProjectsViewModelOutputs {
  public init() {
    let projectsTypeAndSort = self.configureWithProjectsTypeAndSortProperty.signal.skipNil()
    let projectsType = projectsTypeAndSort.map(first)

    let userUpdatedProjectsCount = Signal.merge(
      self.viewWillAppearProperty.signal.ignoreValues(),
      self.currentUserUpdatedProperty.signal
    )
    .map { _ -> (Int, Int) in
      (
        AppEnvironment.current.currentUser?.stats.backedProjectsCount ?? 0,
        AppEnvironment.current.currentUser?.stats.starredProjectsCount ?? 0
      )
    }
    .skipRepeats { $0 == $1 }

    let requestFirstPageWith = projectsType
      .takeWhen(
        Signal.merge(
          userUpdatedProjectsCount.ignoreValues(),
          self.refreshProperty.signal
        )
      )

    let isCloseToBottom = self.willDisplayRowProperty.signal.skipNil()
      .map { row, total in total > 5 && row >= total - 3 }
      .skipRepeats()
      .filter(isTrue)
      .ignoreValues()

    let isLoading: Signal<Bool, Never>
    (self.projects, isLoading, _, _) = paginate(
      requestFirstPageWith: requestFirstPageWith,
      requestNextPageWhen: isCloseToBottom,
      clearOnNewRequest: false,
      skipRepeats: false,
      valuesFromEnvelope: { (envelope: FetchProjectsEnvelope) -> [Project] in
        envelope.projects
      },
      cursorFromEnvelope: { (envelope: FetchProjectsEnvelope) -> (ProfileProjectsType, String?) in
        (envelope.type, envelope.cursor)
      },
      requestFromParams: { projectType in
        if projectType == .backed {
          return AppEnvironment.current.apiService.fetchBackedProjects(cursor: nil, limit: 20)
        } else {
          return AppEnvironment.current.apiService.fetchSavedProjects(cursor: nil, limit: 20)
        }
      },
      requestFromCursor: { projectType, cursor in
        if projectType == .backed {
          return AppEnvironment.current.apiService.fetchBackedProjects(cursor: cursor, limit: 20)
        } else {
          return AppEnvironment.current.apiService.fetchSavedProjects(cursor: cursor, limit: 20)
        }
      }
    )

    self.isRefreshing = isLoading

    self.emptyStateIsVisible = Signal.combineLatest(projectsType, self.projects)
      .map { type, projects in
        (projects.isEmpty, type)
      }

    self.goToProject = Signal.combineLatest(projectsType, self.projects)
      .takePairWhen(self.projectTappedProperty.signal.skipNil())
      .map(unpack)
      .map { projectsType, projects, project in
        let ref = (projectsType == .backed) ? RefTag.profileBacked : RefTag.profileSaved
        return (project, projects, ref)
      }

    // Tracking

    Signal.combineLatest(self.projectTappedProperty.signal, projectsType)
      .observeValues { project, profilesProjectType in
        guard let project = project else { return }
        let sectionContext: KSRAnalytics.SectionContext = profilesProjectType == .backed ?
          .backed : .watched

        AppEnvironment.current.ksrAnalytics.trackProjectCardClicked(
          page: .profile,
          project: project,
          location: .accountMenu,
          section: sectionContext
        )
      }
  }

  private let configureWithProjectsTypeAndSortProperty =
    MutableProperty<(ProfileProjectsType, DiscoveryParams.Sort)?>(nil)
  public func configureWith(projectsType: ProfileProjectsType, sort: DiscoveryParams.Sort) {
    self.configureWithProjectsTypeAndSortProperty.value = (projectsType, sort)
  }

  private let currentUserUpdatedProperty = MutableProperty(())
  public func currentUserUpdated() {
    self.currentUserUpdatedProperty.value = ()
  }

  private let projectTappedProperty = MutableProperty<Project?>(nil)
  public func projectTapped(_ project: Project) {
    self.projectTappedProperty.value = project
  }

  private let refreshProperty = MutableProperty(())
  public func refresh() {
    self.refreshProperty.value = ()
  }

  private let viewWillAppearProperty = MutableProperty(false)
  public func viewWillAppear(_ animated: Bool) {
    self.viewWillAppearProperty.value = animated
  }

  private let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let emptyStateIsVisible: Signal<(Bool, ProfileProjectsType), Never>
  public let goToProject: Signal<(Project, [Project], RefTag), Never>
  public let isRefreshing: Signal<Bool, Never>
  public let projects: Signal<[Project], Never>

  public var inputs: BackerDashboardProjectsViewModelInputs { return self }
  public var outputs: BackerDashboardProjectsViewModelOutputs { return self }
}
