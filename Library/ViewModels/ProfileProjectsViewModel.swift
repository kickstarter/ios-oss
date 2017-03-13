import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public enum ProfileProjectsType {
  case backed
  case saved
}

public protocol ProfileProjectsViewModelInputs {
  /// Call to configure with the type of projects to display.
  func configureWith(type: ProfileProjectsType)

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

public protocol ProfileProjectsViewModelOutputs {
  /// Emits a boolean that determines if the empty state is visible and a ProfileProjectsType.
  var emptyStateIsVisible: Signal<(Bool, ProfileProjectsType), NoError> { get }

  /// Emits when the pull-to-refresh control is refreshing or not.
  var isRefreshing: Signal<Bool, NoError> { get }

  /// Emits the project and ref tag when should go to project page.
  var notifyDelegateGoToProject: Signal<(Project, [Project], RefTag), NoError > { get }

  /// Emits a list of projects for the tableview datasource.
  var projects: Signal<[Project], NoError> { get }

  /// Emits when should scroll to the table view row while swiping projects in the navigator.
  var scrollToProjectRow: Signal<Int, NoError> { get }
}

public protocol ProfileProjectsViewModelType {
  var inputs: ProfileProjectsViewModelInputs { get }
  var outputs: ProfileProjectsViewModelOutputs { get }
}

public final class ProfileProjectsViewModel: ProfileProjectsViewModelType, ProfileProjectsViewModelInputs,
  ProfileProjectsViewModelOutputs {

  public init() {
    let projectsType = self.configureWithTypeProperty.signal.skipNil()

    let requestFirstPageWith = Signal.merge(
      viewWillAppearProperty.signal.filter(isFalse).ignoreValues(),
      refreshProperty.signal
      ).mapConst(
        DiscoveryParams.defaults
          |> DiscoveryParams.lens.backed .~ true
          |> DiscoveryParams.lens.sort .~ .endingSoon
    )

    let requestNextPageWhen = Signal.merge(
      self.willDisplayRowProperty.signal.skipNil(),
      self.transitionedToProjectRowAndTotalProperty.signal.skipNil()
      )
      .map { row, total in row >= total - 3 }
      .skipRepeats()
      .filter(isTrue)
      .ignoreValues()

    let isLoading: Signal<Bool, NoError>
    (self.projects, isLoading, _) = paginate(
      requestFirstPageWith: requestFirstPageWith,
      requestNextPageWhen: requestNextPageWhen,
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

    self.notifyDelegateGoToProject = self.projects
      .takePairWhen(self.projectTappedProperty.signal.skipNil())
      .map { projects, project in (project, projects, RefTag.profileBacked) }

    self.scrollToProjectRow = self.transitionedToProjectRowAndTotalProperty.signal.skipNil().map(first)
  }

  private let configureWithTypeProperty = MutableProperty<ProfileProjectsType?>(nil)
  public func configureWith(type: ProfileProjectsType) {
    self.configureWithTypeProperty.value = type
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
  public let isRefreshing: Signal<Bool, NoError>
  public let notifyDelegateGoToProject: Signal<(Project, [Project], RefTag), NoError>
  public let projects: Signal<[Project], NoError>
  public let scrollToProjectRow: Signal<Int, NoError>

  public var inputs: ProfileProjectsViewModelInputs { return self }
  public var outputs: ProfileProjectsViewModelOutputs { return self }
}
