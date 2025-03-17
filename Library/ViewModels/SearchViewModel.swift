import Foundation
import KsApi
import Prelude
import ReactiveSwift

public typealias SearchResultCard = any BackerDashboardProjectCellViewModel.ProjectCellModel
public typealias SearchResult = GraphAPI.SearchQuery.Data.Project.Node

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
  func tapped(projectAtIndex index: Int)

  func tappedSort()

  func tappedCategoryFilter()

  func selectedSortOption(atIndex index: Int)

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

  /// Emits a project ID  and ref tag when the project page should be opened.
  var goToProject: Signal<(Int, RefTag), Never> { get }

  /// Emits true when the popular title should be shown, and false otherwise.
  var isPopularTitleVisible: Signal<Bool, Never> { get }

  /// Emits when loading indicator should be animated.
  var popularLoaderIndicatorIsAnimating: Signal<Bool, Never> { get }

  /// Emits an array of projects when they should be shown on the screen.
  var projects: Signal<[SearchResultCard], Never> { get }

  /// Emits when the search field should resign focus.
  var resignFirstResponder: Signal<(), Never> { get }

  /// Emits a string that should be filled into the search field.
  var searchFieldText: Signal<String, Never> { get }

  /// Emits when loading indicator should be hidden.
  var searchLoaderIndicatorIsAnimating: Signal<Bool, Never> { get }

  /// Emits true when no search results should be shown, and false otherwise.
  var showEmptyState: Signal<(DiscoveryParams, Bool), Never> { get }

  var showCategoryFilters: Signal<SearchFilterCategoriesSheet, Never> { get }
  var showSort: Signal<SearchSortSheet, Never> { get }
}

public protocol SearchViewModelType {
  var inputs: SearchViewModelInputs { get }
  var outputs: SearchViewModelOutputs { get }
}

public final class SearchViewModel: SearchViewModelType, SearchViewModelInputs, SearchViewModelOutputs {
  public init() {
    self.searchFiltersUseCase = SearchFiltersUseCase(initialSignal: self.viewDidLoadProperty.signal)

    let viewWillAppearNotAnimated = self.viewWillAppearAnimatedProperty.signal.filter(isTrue).ignoreValues()

    let query = Signal
      .merge(
        self.searchTextChangedProperty.signal,
        viewWillAppearNotAnimated.mapConst("").take(first: 1),
        self.cancelButtonPressedProperty.signal.mapConst(""),
        self.clearSearchTextProperty.signal.mapConst("")
      )

    let popularQuery = GraphAPI.SearchQuery.from(discoveryParams: DiscoveryParams.popular)

    let popularEvent = viewWillAppearNotAnimated
      .switchMap {
        AppEnvironment.current.apiService
          .fetch(query: popularQuery)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .map { $0.projects?.nodes?.compact() ?? [] }
          .materialize()
      }

    let popular = popularEvent.values()

    let clears = query.mapConst([SearchResult]())

    self.isPopularTitleVisible = Signal.combineLatest(query, popular)
      .map { query, _ in query.isEmpty }
      .skipRepeats()

    let requestFirstPageWith: Signal<DiscoveryParams, Never> = query
      .filter { !$0.isEmpty }
      .combineLatest(with: self.searchFiltersUseCase.selectedSort)
      .map { query, sort in
        DiscoveryParams.withQuery(query, sort: sort)
      }

    let isCloseToBottom = self.willDisplayRowProperty.signal.skipNil()
      .map { row, total in
        row >= total - 3
      }
      .skipRepeats()
      .filter(isTrue)
      .ignoreValues()

    let requestFromOptionsWithDebounce: (DiscoveryParams)
      -> SignalProducer<GraphAPI.SearchQuery.Data, ErrorEnvelope> = { params in
        SignalProducer<(), ErrorEnvelope>(value: ())
          .switchMap {
            AppEnvironment.current.apiService.fetch(query: GraphAPI.SearchQuery.from(discoveryParams: params))
              .ksr_debounce(
                AppEnvironment.current.debounceInterval, on: AppEnvironment.current.scheduler
              )
          }
      }

    let statsProperty = MutableProperty<Int>(0)
    let optionsProperty = MutableProperty<DiscoveryParams?>(nil)
    optionsProperty <~ requestFirstPageWith // Bound to the SearchOptions for the current query

    let (paginatedProjects, isLoading, page, _) = paginate(
      requestFirstPageWith: requestFirstPageWith,
      requestNextPageWhen: isCloseToBottom,
      clearOnNewRequest: false,
      skipRepeats: false,
      valuesFromEnvelope: { [statsProperty] (data: GraphAPI.SearchQuery.Data) -> [
        SearchResult
      ] in
        statsProperty.value = data.projects?.totalCount ?? 0
        return data.projects?.nodes?.compact() ?? []
      },
      cursorFromEnvelope: { data in
        guard let pageInfo = data.projects?.pageInfo else {
          return nil
        }

        return pageInfo.hasNextPage ? pageInfo.endCursor : nil
      },
      requestFromParams: requestFromOptionsWithDebounce,
      requestFromCursor: { [optionsProperty] (maybeCursor: String?) -> SignalProducer<
        GraphAPI.SearchQuery.Data,
        ErrorEnvelope
      > in
        guard let options = optionsProperty.value, let cursor = maybeCursor else {
          return SignalProducer.empty
        }

        let query = GraphAPI.SearchQuery.from(discoveryParams: options, withCursor: cursor)
        return AppEnvironment.current.apiService.fetch(query: query)
      }
    )

    let stats = statsProperty.signal

    self.searchLoaderIndicatorIsAnimating = isLoading

    let searchResults: Signal<[SearchResult], Never> = Signal.combineLatest(
      self.isPopularTitleVisible,
      popular,
      .merge(clears, paginatedProjects)
    )
    .map { showPopular, popular, searchResults in showPopular ? popular : searchResults }
    .skipRepeats(==)

    self.projects = searchResults
      .map { (nodes: [
        SearchResult
      ]) -> [GraphAPI.BackerDashboardProjectCellFragment] in
        nodes.map { $0.fragments.backerDashboardProjectCellFragment }
      }

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

    self.goToProject = Signal.combineLatest(searchResults, query)
      .takePairWhen(self.tappedProjectIndexSignal)
      .map { ($0.0, $0.1, $1) } // ((a, b) c) -> (a, b, c)
      .map { projects, query, index in

        guard index < projects.count else {
          let emptyResult: (Int, RefTag)? = nil
          assert(false, "Tapped card out of bounds.")
          return emptyResult
        }

        let project = projects[index]
        let graphQLID = project.fragments.backerDashboardProjectCellFragment.projectId

        guard let projectId = decompose(id: graphQLID) else {
          let emptyResult: (Int, RefTag)? = nil
          return emptyResult
        }

        let refTag = refTag(query: query, projects: projects, project: project)

        return (projectId, refTag)
      }
      .skipNil()

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

    Signal.combineLatest(requestFirstPageWith, searchResults)
      .takePairWhen(self.tappedProjectIndexSignal)
      .map { ($0.0, $0.1, $1) } // ((a, b), c) -> (a, b, c)
      .observeValues { params, results, index in

        guard index < results.count else {
          assert(false, "Tapped card out of bounds.")
          return
        }

        let projectAnalytics = results[index].fragments.projectAnalyticsFragment

        AppEnvironment.current.ksrAnalytics.trackProjectCardClicked(
          page: .search,
          project: projectAnalytics,
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

  fileprivate let (tappedProjectIndexSignal, tappedProjectIndexObserver) = Signal<Int, Never>.pipe()
  public func tapped(projectAtIndex index: Int) {
    self.tappedProjectIndexObserver.send(value: index)
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

  public func tappedSort() {
    self.searchFiltersUseCase.tappedSort()
  }

  public func tappedCategoryFilter() {
    self.searchFiltersUseCase.tappedCategoryFilter()
  }

  public func selectedSortOption(atIndex index: Int) {
    self.searchFiltersUseCase.selectedSortOption(atIndex: index)
  }

  private let searchFiltersUseCase: SearchFiltersUseCase

  public let changeSearchFieldFocus: Signal<(focused: Bool, animate: Bool), Never>
  public let goToProject: Signal<(Int, RefTag), Never>
  public let isPopularTitleVisible: Signal<Bool, Never>
  public let popularLoaderIndicatorIsAnimating: Signal<Bool, Never>
  public let projects: Signal<[SearchResultCard], Never>
  public let resignFirstResponder: Signal<(), Never>
  public let searchFieldText: Signal<String, Never>
  public let searchLoaderIndicatorIsAnimating: Signal<Bool, Never>
  public let showEmptyState: Signal<(DiscoveryParams, Bool), Never>

  public var showSort: Signal<SearchSortSheet, Never> {
    return self.searchFiltersUseCase.showSort
  }

  public var showCategoryFilters: Signal<SearchFilterCategoriesSheet, Never> {
    return self.searchFiltersUseCase.showCategoryFilters
  }

  public var inputs: SearchViewModelInputs { return self }
  public var outputs: SearchViewModelOutputs { return self }
}

/// Calculates a ref tag from the search query, the list of displayed projects, and the project
/// tapped.
private func refTag(query: String, projects: [SearchResult], project: SearchResult) -> RefTag {
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
