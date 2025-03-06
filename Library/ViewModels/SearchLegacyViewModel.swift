import Foundation
import KsApi
import Prelude
import ReactiveSwift

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
  var changeSearchFieldFocus: Signal<(focused: Bool, animate: Bool), Never> { get }

  /// Emits a project, playlist and ref tag when the projet navigator should be opened.
  var goToProject: Signal<(Project, [Project], RefTag), Never> { get }

  /// Emits true when the popular title should be shown, and false otherwise.
  var isPopularTitleVisible: Signal<Bool, Never> { get }

  /// Emits when loading indicator should be animated.
  var popularLoaderIndicatorIsAnimating: Signal<Bool, Never> { get }

  /// Emits an array of projects when they should be shown on the screen.
  var projects: Signal<[Project], Never> { get }

  /// Emits when the search field should resign focus.
  var resignFirstResponder: Signal<(), Never> { get }

  /// Emits a string that should be filled into the search field.
  var searchFieldText: Signal<String, Never> { get }

  /// Emits when loading indicator should be hidden.
  var searchLoaderIndicatorIsAnimating: Signal<Bool, Never> { get }

  /// Emits true when no search results should be shown, and false otherwise.
  var showEmptyState: Signal<(DiscoveryParams, Bool), Never> { get }
}

public protocol SearchViewModelType {
  var inputs: SearchViewModelInputs { get }
  var outputs: SearchViewModelOutputs { get }
}

public final class SearchViewModel: SearchViewModelType, SearchViewModelInputs, SearchViewModelOutputs {
  public init() {
    let viewWillAppearNotAnimated = self.viewWillAppearAnimatedProperty.signal.filter(isTrue).ignoreValues()

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

    let requestFirstPageWith: Signal<DiscoveryParams, Never> = query
      .filter { !$0.isEmpty }
      .map { .defaults |> DiscoveryParams.lens.query .~ $0 }

    let isCloseToBottom = self.willDisplayRowProperty.signal.skipNil()
      .map { row, total in
        row >= total - 3
      }
      .skipRepeats()
      .filter(isTrue)
      .ignoreValues()

    let requestFromParamsWithDebounce: (DiscoveryParams)
      -> SignalProducer<DiscoveryEnvelope, ErrorEnvelope> = { params in
        SignalProducer<(), ErrorEnvelope>(value: ())
          .switchMap {
            AppEnvironment.current.apiService.fetchDiscovery(params: params)
              .ksr_debounce(
                AppEnvironment.current.debounceInterval, on: AppEnvironment.current.scheduler
              )
          }
      }

    let statsProperty = MutableProperty<Int>(0)

    let (paginatedProjects, isLoading, page, _) = paginate(
      requestFirstPageWith: requestFirstPageWith,
      requestNextPageWhen: isCloseToBottom,
      clearOnNewRequest: false,
      skipRepeats: false,
      valuesFromEnvelope: { [statsProperty] result -> [Project] in
        statsProperty.value = result.stats.count
        return result.projects
      },
      cursorFromEnvelope: { $0.urls.api.moreProjects },
      requestFromParams: requestFromParamsWithDebounce,
      requestFromCursor: { AppEnvironment.current.apiService.fetchDiscovery(paginationUrl: $0) }
    )

    let stats = statsProperty.signal

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

    self.goToProject = Signal.combineLatest(self.projects, query)
      .takePairWhen(self.tappedProjectProperty.signal.skipNil())
      .map { projectsAndQuery, tappedProject in
        let (projects, query) = projectsAndQuery

        return (tappedProject, projects, refTag(query: query, projects: projects, project: tappedProject))
      }

    // Tracking

    // This represents search results count whenever the search page is viewed.
    // An initial value is emitted on first visit.
    let viewWillAppearSearchResultsCount = Signal.merge(
      stats,
      viewWillAppearNotAnimated.mapConst(0).take(first: 1)
    )

    Signal.combineLatest(query, viewWillAppearSearchResultsCount)
      .takeWhen(viewWillAppearNotAnimated)
      .observeValues { query, searchResults in
        let results = query.isEmpty ? 0 : searchResults
        let params = .defaults |> DiscoveryParams.lens.query .~ query
        AppEnvironment.current.ksrAnalytics
          .trackProjectSearchView(params: params, results: results)
      }

    let hasResults = Signal.combineLatest(paginatedProjects, isLoading)
      .filter(second >>> isFalse)
      .map(first)
      .map { !$0.isEmpty }

    let firstPageResults = Signal.zip(hasResults, page)
      .filter { _, page in page == 1 }
      .map(first)

    // This represents search results count only when a search is performed
    // and there is a response from the API for the query.
    let newQuerySearchResultsCount = Signal.merge(
      viewWillAppearSearchResultsCount.filter { $0 == 0 },
      viewWillAppearSearchResultsCount.takeWhen(firstPageResults)
    )

    Signal.combineLatest(query, requestFirstPageWith)
      .takePairWhen(newQuerySearchResultsCount)
      .map(unpack)
      .filter { query, _, _ in !query.isEmpty }
      .observeValues { _, params, stats in
        AppEnvironment.current.ksrAnalytics
          .trackProjectSearchView(params: params, results: stats)
      }

    Signal.combineLatest(self.tappedProjectProperty.signal, requestFirstPageWith)
      .observeValues { project, params in
        guard let project = project else { return }

        AppEnvironment.current.ksrAnalytics.trackProjectCardClicked(
          page: .search,
          project: project,
          typeContext: .results,
          location: .searchResults,
          params: params
        )
      }
  }

  fileprivate let cancelButtonPressedProperty = MutableProperty(())
  public func cancelButtonPressed() {
    self.cancelButtonPressedProperty.value = ()
  }

  fileprivate let clearSearchTextProperty = MutableProperty(())
  public func clearSearchText() {
    self.clearSearchTextProperty.value = ()
  }

  fileprivate let searchFieldDidBeginEditingProperty = MutableProperty(())
  public func searchFieldDidBeginEditing() {
    self.searchFieldDidBeginEditingProperty.value = ()
  }

  fileprivate let searchTextChangedProperty = MutableProperty("")
  public func searchTextChanged(_ searchText: String) {
    self.searchTextChangedProperty.value = searchText
  }

  fileprivate let searchTextEditingDidEndProperty = MutableProperty(())
  public func searchTextEditingDidEnd() {
    self.searchTextEditingDidEndProperty.value = ()
  }

  fileprivate let tappedProjectProperty = MutableProperty<Project?>(nil)
  public func tapped(project: Project) {
    self.tappedProjectProperty.value = project
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
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

  public let changeSearchFieldFocus: Signal<(focused: Bool, animate: Bool), Never>
  public let goToProject: Signal<(Project, [Project], RefTag), Never>
  public let isPopularTitleVisible: Signal<Bool, Never>
  public let popularLoaderIndicatorIsAnimating: Signal<Bool, Never>
  public let projects: Signal<[Project], Never>
  public let resignFirstResponder: Signal<(), Never>
  public let searchFieldText: Signal<String, Never>
  public let searchLoaderIndicatorIsAnimating: Signal<Bool, Never>
  public let showEmptyState: Signal<(DiscoveryParams, Bool), Never>

  public var inputs: SearchViewModelInputs { return self }
  public var outputs: SearchViewModelOutputs { return self }
}

/// Calculates a ref tag from the search query, the list of displayed projects, and the project
/// tapped.
private func refTag(query: String, projects: [Project], project: Project) -> RefTag {
  if project == projects.first, query.isEmpty {
    return RefTag.searchPopularFeatured
  } else if project == projects.first, !query.isEmpty {
    return RefTag.searchFeatured
  } else if query.isEmpty {
    return RefTag.searchPopular
  } else {
    return RefTag.search
  }
}
