import KsApi
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol DiscoveryPageViewModelInputs {
  /// Call with the sort provided to the view.
  func configureWith(sort sort: DiscoveryParams.Sort)

  /// Call when the filter is changed.
  func selectedFilter(params: DiscoveryParams)

  /// Call when the user taps on a project.
  func tapped(project project: Project)

  /// Call when the view appears.
  func viewDidAppear()

  /// Call when the view disappears.
  func viewDidDisappear()

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the view will appear.
  func viewWillAppear()

  /**
   Call from the controller's `tableView:willDisplayCell:forRowAtIndexPath` method.

   - parameter row:       The 0-based index of the row displaying.
   - parameter totalRows: The total number of rows in the table view.
   */
  func willDisplayRow(row: Int, outOf totalRows: Int)
}

public protocol DiscoveryPageViewModelOutputs {
  /// Emits a project and ref tag that we should go to.
  var goToProject: Signal<(Project, RefTag), NoError> { get }

  /// Emits a list of projects that should be shown.
  var projects: Signal<[Project], NoError> { get }

  /// Emits a boolean that determines if projects are currently loading or not.
  var projectsAreLoading: Signal<Bool, NoError> { get }

  /// Emits a boolean that determines of the onboarding should be shown.
  var showOnboarding: Signal<Bool, NoError> { get }
}

public protocol DiscoveryPageViewModelType {
  var inputs: DiscoveryPageViewModelInputs { get }
  var outputs: DiscoveryPageViewModelOutputs { get }
}

public final class DiscoveryPageViewModel: DiscoveryPageViewModelType, DiscoveryPageViewModelInputs,
DiscoveryPageViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {
    let isCloseToBottom = self.willDisplayRowProperty.signal.ignoreNil()
      .map { row, total in row >= total - 3 && row > 0 }
      .skipRepeats()
      .filter(isTrue)
      .ignoreValues()

    let paramsChanged = combineLatest(
      self.sortProperty.signal.ignoreNil(),
      self.selectedFilterProperty.signal.ignoreNil()
      )
      .map(DiscoveryParams.lens.sort.set)

    let isVisible = Signal.merge(
      self.viewDidAppearProperty.signal.mapConst(true),
      self.viewDidDisappearProperty.signal.mapConst(false)
    ).skipRepeats()

    let requestFirstPageWith = combineLatest(paramsChanged, isVisible)
      .filter { _, visible in visible }
      .map { params, _ in params }
      .skipRepeats()

    let paginatedProjects: Signal<[Project], NoError>
    let pageCount: Signal<Int, NoError>
    (paginatedProjects, self.projectsAreLoading, pageCount) = paginate(
      requestFirstPageWith: requestFirstPageWith,
      requestNextPageWhen: isCloseToBottom,
      clearOnNewRequest: true,
      valuesFromEnvelope: { $0.projects },
      cursorFromEnvelope: { $0.urls.api.moreProjects },
      requestFromParams: { AppEnvironment.current.apiService.fetchDiscovery(params: $0) },
      requestFromCursor: { AppEnvironment.current.apiService.fetchDiscovery(paginationUrl: $0) })

    self.projects = Signal.merge(
      paginatedProjects,
      self.selectedFilterProperty.signal.ignoreNil().skipRepeats().mapConst([])
      )
      .skipWhile { $0.isEmpty }
      .skipRepeats(==)

    self.goToProject = paramsChanged
      .takePairWhen(self.tappedProject.signal.ignoreNil())
      .map { params, project in (project, refTag(fromParams: params, project: project)) }

    self.showOnboarding = combineLatest(
      self.viewWillAppearProperty.signal,
      self.sortProperty.signal.ignoreNil()
      )
      .map { _, sort in
        return AppEnvironment.current.currentUser == nil && sort == .Magic
      }
      .skipRepeats()

    requestFirstPageWith
      .takePairWhen(pageCount)
      .observeNext { params, page in
        AppEnvironment.current.koala.trackDiscovery(params: params, page: page)
    }
  }
  // swiftlint:enable function_body_length

  private let sortProperty = MutableProperty<DiscoveryParams.Sort?>(nil)
  public func configureWith(sort sort: DiscoveryParams.Sort) {
    self.sortProperty.value = sort
  }
  private let selectedFilterProperty = MutableProperty<DiscoveryParams?>(nil)
  public func selectedFilter(params: DiscoveryParams) {
    self.selectedFilterProperty.value = params
  }
  private let tappedProject = MutableProperty<Project?>(nil)
  public func tapped(project project: Project) {
    self.tappedProject.value = project
  }
  private let viewDidAppearProperty = MutableProperty()
  public func viewDidAppear() {
    self.viewDidAppearProperty.value = ()
  }
  private let viewDidDisappearProperty = MutableProperty()
  public func viewDidDisappear() {
    self.viewDidDisappearProperty.value = ()
  }
  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }
  private let viewWillAppearProperty = MutableProperty()
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }
  private let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func willDisplayRow(row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  public let goToProject: Signal<(Project, RefTag), NoError>
  public let projects: Signal<[Project], NoError>
  public let projectsAreLoading: Signal<Bool, NoError>
  public let showOnboarding: Signal<Bool, NoError>

  public var inputs: DiscoveryPageViewModelInputs { return self }
  public var outputs: DiscoveryPageViewModelOutputs { return self }
}

private func refTag(fromParams params: DiscoveryParams, project: Project) -> RefTag {

  if project.isPotdToday() {
    return .discoveryPotd
  } else if params.category != nil {
    return .categoryWithSort(params.sort ?? .Magic)
  } else if params.staffPicks == true {
    return .recommendedWithSort(params.sort ?? .Magic)
  } else if params.social == true {
    return .social
  }
  return RefTag.discovery
}
