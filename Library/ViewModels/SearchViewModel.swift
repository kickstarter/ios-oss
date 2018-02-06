import Foundation
import KsApi
import ReactiveSwift
import KsApi
import Result
import Prelude

public protocol SearchViewModelInputs {
  /// Call when the cancel button is pressed.
  func cancelButtonPressed()

  /// Call when the search clear button is tapped.
  func clearSearchText()

  /// Call when the search field begins editing.
  func searchFieldDidBeginEditing()

  /// Call when the user enters a new search term.
  func searchTextChanged(_ searchText: String)

  /// Call when the user taps the return key.
  func searchTextEditingDidEnd()

  /// Call when the project navigator has transitioned to a new project with its index.
  func transitionedToProject(at row: Int, outOf totalRows: Int)

  /// Call when the view loads.
  func viewDidLoad()

   /// Call when the view will appear.
  func viewWillAppear(animated: Bool)

  /// Call when a project is tapped.
  func tapped(project: Project)

  /**
   Call from the controller's `tableView:willDisplayCell:forRowAtIndexPath` method.

   - parameter row:       The 0-based index of the row displaying.
   - parameter totalRows: The total number of rows in the table view.
   */
  func willDisplayRow(_ row: Int, outOf totalRows: Int)
}

public protocol SearchViewModelOutputs {
  /// Emits booleans that determines if the search field should be focused or not, and whether that focus
  /// should be animated.
  var changeSearchFieldFocus: Signal<(focused: Bool, animate: Bool), NoError> { get }

  /// Emits a project, playlist and ref tag when the projet navigator should be opened.
  var goToProject: Signal<(Project, [Project], RefTag), NoError> { get }

  /// Emits true when the popular title should be shown, and false otherwise.
  var isPopularTitleVisible: Signal<Bool, NoError> { get }

  /// Emits when loading indicator should be animated.
  var popularLoaderIndicatorIsAnimating: Signal<Bool, NoError> { get }

   /// Emits an array of projects when they should be shown on the screen.
  var projects: Signal<[Project], NoError> { get }

  /// Emits when the search field should resign focus.
  var resignFirstResponder: Signal<(), NoError> { get }

  /// Emits when should scroll to project with row number.
  var scrollToProjectRow: Signal<Int, NoError> { get }

  /// Emits a string that should be filled into the search field.
  var searchFieldText: Signal<String, NoError> { get }

  /// Emits when loading indicator should be hidden.
  var searchLoaderIndicatorIsAnimating: Signal<Bool, NoError> { get }

  /// Emits true when no search results should be shown, and false otherwise.
  var showEmptyState: Signal<(DiscoveryParams, Bool), NoError> { get }
}

public protocol SearchViewModelType {
  var inputs: SearchViewModelInputs { get }
  var outputs: SearchViewModelOutputs { get }
}

public final class SearchViewModel: SearchViewModelType, SearchViewModelInputs, SearchViewModelOutputs {

    public init() {
    let viewWillAppearNotAnimated = self.viewWillAppearAnimatedProperty.signal.filter(isFalse).ignoreValues()

    let query = Signal
      .merge(
        self.searchTextChangedProperty.signal,
        viewWillAppearNotAnimated.mapConst("").take(first: 1),
        self.cancelButtonPressedProperty.signal.mapConst(""),
        self.clearSearchTextProperty.signal.mapConst("")
      )

    let popularEvent = viewWillAppearNotAnimated
      .switchMap {
        AppEnvironment.current.apiService
          .fetchDiscovery(params: .defaults |> DiscoveryParams.lens.sort .~ .popular)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .map { $0.projects }
          .materialize()
      }

    let popular = popularEvent.values()

    let clears = query.mapConst([Project]())

    self.isPopularTitleVisible = Signal.combineLatest(query, popular)
      .map { query, _ in query.isEmpty }
      .skipRepeats()

    let requestFirstPageWith = query
      .filter { !$0.isEmpty }
      .map { .defaults |> DiscoveryParams.lens.query .~ $0 }

    let isCloseToBottom = Signal.merge(
      self.willDisplayRowProperty.signal.skipNil(),
      self.transitionedToProjectRowAndTotalProperty.signal.skipNil()
      )
      .map { row, total in
        row >= total - 3
      }
      .skipRepeats()
      .filter(isTrue)
      .ignoreValues()

    let requestFromParamsWithDebounce = { params in
      SignalProducer<(), ErrorEnvelope>(value: ())
        .switchMap {
          AppEnvironment.current.apiService.fetchDiscovery(params: params)
            .ksr_debounce(
              AppEnvironment.current.debounceInterval, on: AppEnvironment.current.scheduler)
      }
    }

    let (paginatedProjects, isLoading, page) = paginate(
      requestFirstPageWith: requestFirstPageWith,
      requestNextPageWhen: isCloseToBottom,
      clearOnNewRequest: false,
      skipRepeats: false,
      valuesFromEnvelope: { $0.projects },
      cursorFromEnvelope: { $0.urls.api.moreProjects },
      requestFromParams: requestFromParamsWithDebounce,
      requestFromCursor: { AppEnvironment.current.apiService.fetchDiscovery(paginationUrl: $0) })

    self.searchLoaderIndicatorIsAnimating = isLoading

    self.projects = Signal.combineLatest(
      self.isPopularTitleVisible,
      popular,
      .merge(clears, paginatedProjects)
      )
      .map { showPopular, popular, searchResults in showPopular ? popular : searchResults }
      .skipRepeats(==)

    let shouldShowEmptyState = Signal.merge(
      query.mapConst(false),
      paginatedProjects.map { $0.isEmpty }
      )
      .skipRepeats()
      .skip(first: 1)

    self.showEmptyState = requestFirstPageWith
      .takePairWhen(shouldShowEmptyState)

    self.changeSearchFieldFocus = Signal.merge(
      viewWillAppearNotAnimated.mapConst((false, false)),
      self.cancelButtonPressedProperty.signal.mapConst((false, true)),
      self.searchFieldDidBeginEditingProperty.signal.mapConst((true, true))
    )

    self.searchFieldText = self.cancelButtonPressedProperty.signal.mapConst("")

    self.resignFirstResponder = Signal
      .merge(
        self.searchTextEditingDidEndProperty.signal,
        self.cancelButtonPressedProperty.signal
    )

    self.popularLoaderIndicatorIsAnimating = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(true),
      popularEvent.filter { $0.isTerminating }.mapConst(false)
    )

    self.scrollToProjectRow = self.transitionedToProjectRowAndTotalProperty.signal.skipNil().map(first)

    // koala

    viewWillAppearNotAnimated
      .observeValues { AppEnvironment.current.koala.trackProjectSearchView() }

    let hasResults = Signal.combineLatest(paginatedProjects, isLoading)
      .filter(second >>> isFalse)
      .map(first)
      .map { !$0.isEmpty }

    Signal.combineLatest(query, page)
      .takePairWhen(hasResults)
      .map(unpack)
      .filter { query, _, _ in !query.isEmpty }
      .observeValues { query, page, hasResults in
        AppEnvironment.current.koala.trackSearchResults(query: query, page: page, hasResults: hasResults)
    }

    self.clearSearchTextProperty.signal
      .observeValues { AppEnvironment.current.koala.trackClearedSearchTerm() }

    self.goToProject = Signal.combineLatest(self.projects, query)
      .takePairWhen(self.tappedProjectProperty.signal.skipNil())
      .map { projectsAndQuery, tappedProject in
        let (projects, query) = projectsAndQuery

        return (tappedProject, projects, refTag(query: query, projects: projects, project: tappedProject))
    }

    query.combinePrevious()
      .map(first)
      .takeWhen(self.cancelButtonPressedProperty.signal)
      .filter { !$0.isEmpty }
      .observeValues { _ in AppEnvironment.current.koala.trackClearedSearchTerm() }
  }

  fileprivate let cancelButtonPressedProperty = MutableProperty()
  public func cancelButtonPressed() {
    self.cancelButtonPressedProperty.value = ()
  }

  fileprivate let clearSearchTextProperty = MutableProperty()
  public func clearSearchText() {
    self.clearSearchTextProperty.value = ()
  }

  fileprivate let searchFieldDidBeginEditingProperty = MutableProperty()
  public func searchFieldDidBeginEditing() {
    self.searchFieldDidBeginEditingProperty.value = ()
  }

  fileprivate let searchTextChangedProperty = MutableProperty("")
  public func searchTextChanged(_ searchText: String) {
    self.searchTextChangedProperty.value = searchText
  }

  fileprivate let searchTextEditingDidEndProperty = MutableProperty()
  public func searchTextEditingDidEnd() {
    self.searchTextEditingDidEndProperty.value = ()
  }

  fileprivate let tappedProjectProperty = MutableProperty<Project?>(nil)
  public func tapped(project: Project) {
    self.tappedProjectProperty.value = project
  }

  private let transitionedToProjectRowAndTotalProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func transitionedToProject(at row: Int, outOf totalRows: Int) {
    self.transitionedToProjectRowAndTotalProperty.value = (row, totalRows)
  }

  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let viewWillAppearAnimatedProperty = MutableProperty(false)
  public func viewWillAppear(animated: Bool) {
    self.viewWillAppearAnimatedProperty.value = animated
  }

  fileprivate let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  public let changeSearchFieldFocus: Signal<(focused: Bool, animate: Bool), NoError>
  public let goToProject: Signal<(Project, [Project], RefTag), NoError>
  public let isPopularTitleVisible: Signal<Bool, NoError>
  public let popularLoaderIndicatorIsAnimating: Signal<Bool, NoError>
  public let projects: Signal<[Project], NoError>
  public let resignFirstResponder: Signal<(), NoError>
  public let scrollToProjectRow: Signal<Int, NoError>
  public let searchFieldText: Signal<String, NoError>
  public let searchLoaderIndicatorIsAnimating: Signal<Bool, NoError>
  public let showEmptyState: Signal<(DiscoveryParams, Bool), NoError>

  public var inputs: SearchViewModelInputs { return self }
  public var outputs: SearchViewModelOutputs { return self }
}

/// Calculates a ref tag from the search query, the list of displayed projects, and the project
/// tapped.
private func refTag(query: String, projects: [Project], project: Project) -> RefTag {
  if project == projects.first && query.isEmpty {
    return RefTag.searchPopularFeatured
  } else if project == projects.first && !query.isEmpty {
    return RefTag.searchFeatured
  } else if query.isEmpty {
    return RefTag.searchPopular
  } else {
    return RefTag.search
  }
}
