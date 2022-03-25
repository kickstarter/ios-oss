import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public enum ProfileProjectsType {
  case backed
  case saved

  var trackingString: String {
    switch self {
    case .backed: return "backed"
    case .saved: return "saved"
    }
  }
}

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

    let requestFirstPageWith = projectsTypeAndSort
      .takeWhen(Signal.merge(
        userUpdatedProjectsCount.ignoreValues(),
        self.refreshProperty.signal
      )
      )
      .map { (pType, sort) -> DiscoveryParams in
        switch pType {
        case .backed:
          return DiscoveryParams.defaults
            |> DiscoveryParams.lens.backed .~ true
            |> DiscoveryParams.lens.sort .~ sort
            |> DiscoveryParams.lens.perPage .~ 20
        case .saved:
          return DiscoveryParams.defaults
            |> DiscoveryParams.lens.starred .~ true
            |> DiscoveryParams.lens.sort .~ sort
            |> DiscoveryParams.lens.perPage .~ 20
        }
      }

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
      valuesFromEnvelope: { $0.projects },
      cursorFromEnvelope: { $0.urls.api.moreProjects },
      requestFromParams: { AppEnvironment.current.apiService.fetchDiscovery(params: $0) },
      requestFromCursor: { AppEnvironment.current.apiService.fetchDiscovery(paginationUrl: $0) }
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
