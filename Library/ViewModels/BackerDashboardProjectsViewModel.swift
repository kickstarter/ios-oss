import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public enum ProfileProjectsType {
  case backed
  case saved

  var trackingString: String {
    switch self {
    case .backed:  return "backed"
    case .saved:   return "saved"
    }
  }
}

public protocol BackerDashboardProjectsViewModelInputs {
  /// Call to configure with the ProfileProjectsType to display and the default sort.
  func configureWith(projectsType: ProfileProjectsType, sort: DiscoveryParams.Sort)

  /// Call when a project cell is tapped.
  func projectTapped(_ project: Project)

  /// Call when pull-to-refresh is invoked.
  func refresh()

  /// Call when the project navigator has transitioned to a new project with its index.
  func transitionedToProject(at row: Int, outOf totalRows: Int)

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the view will appear.
  func viewWillAppear(_ animated: Bool)

  /// Call when a new row is displayed.
  func willDisplayRow(_ row: Int, outOf totalRows: Int)
}

public protocol BackerDashboardProjectsViewModelOutputs {
  /// Emits a boolean that determines if the empty state is visible and a ProfileProjectsType.
  var emptyStateIsVisible: Signal<(Bool, ProfileProjectsType), NoError> { get }

  /// Emits the project, projects, and ref tag when should go to project page.
  var goToProject: Signal<(Project, [Project], RefTag), NoError > { get }

  /// Emits when the pull-to-refresh control is refreshing or not.
  var isRefreshing: Signal<Bool, NoError> { get }

  /// Emits a list of projects for the tableview datasource.
  var projects: Signal<[Project], NoError> { get }

  /// Emits when should scroll to the table view row while swiping projects in the navigator.
  var scrollToProjectRow: Signal<Int, NoError> { get }
}

public protocol BackerDashboardProjectsViewModelType {
  var inputs: BackerDashboardProjectsViewModelInputs { get }
  var outputs: BackerDashboardProjectsViewModelOutputs { get }
}

public final class BackerDashboardProjectsViewModel: BackerDashboardProjectsViewModelType,
  BackerDashboardProjectsViewModelInputs, BackerDashboardProjectsViewModelOutputs {

  // swiftlint:disable:next function_body_length
  public init() {
    let projectsTypeAndSort = self.configureWithProjectsTypeAndSortProperty.signal.skipNil()
    let projectsType = projectsTypeAndSort.map(first)

    let requestFirstPageWith = projectsTypeAndSort
      .takeWhen(Signal.merge(
        self.viewWillAppearProperty.signal.filter(isFalse).ignoreValues(),
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

    let isCloseToBottom = Signal.merge(
      self.willDisplayRowProperty.signal.skipNil(),
      self.transitionedToProjectRowAndTotalProperty.signal.skipNil()
      )
      .map { row, total in total > 5 && row >= total - 3 }
      .skipRepeats()
      .filter(isTrue)
      .ignoreValues()

    let isLoading: Signal<Bool, NoError>
    (self.projects, isLoading, _) = paginate(
      requestFirstPageWith: requestFirstPageWith,
      requestNextPageWhen: isCloseToBottom,
      clearOnNewRequest: false,
      valuesFromEnvelope: { $0.projects },
      cursorFromEnvelope: { $0.urls.api.moreProjects },
      requestFromParams: { AppEnvironment.current.apiService.fetchDiscovery(params: $0) },
      requestFromCursor: { AppEnvironment.current.apiService.fetchDiscovery(paginationUrl: $0) })

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

    self.scrollToProjectRow = self.transitionedToProjectRowAndTotalProperty.signal.skipNil().map(first)

    projectsType
      .takeWhen(self.viewWillAppearProperty.signal.filter(isFalse))
      .observeValues { pType in
        AppEnvironment.current.koala.trackViewedProfileTab(projectsType: pType)
    }
  }

  private let configureWithProjectsTypeAndSortProperty =
    MutableProperty<(ProfileProjectsType, DiscoveryParams.Sort)?>(nil)
  public func configureWith(projectsType: ProfileProjectsType, sort: DiscoveryParams.Sort) {
    self.configureWithProjectsTypeAndSortProperty.value = (projectsType, sort)
  }

  private let projectTappedProperty = MutableProperty<Project?>(nil)
  public func projectTapped(_ project: Project) {
    self.projectTappedProperty.value = project
  }

  private let refreshProperty = MutableProperty()
  public func refresh() {
    self.refreshProperty.value = ()
  }

  private let transitionedToProjectRowAndTotalProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func transitionedToProject(at row: Int, outOf totalRows: Int) {
    self.transitionedToProjectRowAndTotalProperty.value = (row, totalRows)
  }

  private let viewWillAppearProperty = MutableProperty(false)
  public func viewWillAppear(_ animated: Bool) {
    self.viewWillAppearProperty.value = animated
  }

  private let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let emptyStateIsVisible: Signal<(Bool, ProfileProjectsType), NoError>
  public let goToProject: Signal<(Project, [Project], RefTag), NoError>
  public let isRefreshing: Signal<Bool, NoError>
  public let projects: Signal<[Project], NoError>
  public let scrollToProjectRow: Signal<Int, NoError>

  public var inputs: BackerDashboardProjectsViewModelInputs { return self }
  public var outputs: BackerDashboardProjectsViewModelOutputs { return self }
}
