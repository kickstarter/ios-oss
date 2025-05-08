import Foundation
import KsApi
import Prelude
import ReactiveSwift

public typealias SearchResultCard = ProjectCardProperties
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

  /// Call this when the user taps on a button to show one of the sort options.
  func tappedButton(forFilterType type: SearchFilterPill.FilterType)

  /// Call this when the user selects a new sort option.
  func selectedSortOption(_ sort: DiscoveryParams.Sort)

  /// Call this when the user selects a new category.
  func selectedCategory(_ category: SearchFiltersCategory)

  /// Call this when the user selects a new project state filter.
  func selectedProjectState(_ state: DiscoveryParams.State)

  /// Call this when the user taps reset on a filter modal
  func resetFilters(for: SearchFilterModalType)

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
  var isProjectsTitleVisible: Signal<Bool, Never> { get }

  /// Emits an array of projects when they should be shown on the screen.
  var projects: Signal<[SearchResultCard], Never> { get }

  /// A combination of `isProjectsTitleVisible` and `projects`. Used to power the datasource.
  var projectsAndTitle: Signal<(Bool, [SearchResultCard]), Never> { get }

  /// Emits when the search field should resign focus.
  var resignFirstResponder: Signal<(), Never> { get }

  /// Emits a string that should be filled into the search field.
  var searchFieldText: Signal<String, Never> { get }

  /// Emits when loading indicator should be hidden.
  var searchLoaderIndicatorIsAnimating: Signal<Bool, Never> { get }

  /// Emits true when no search results should be shown, and false otherwise.
  var showEmptyState: Signal<(DiscoveryParams, Bool), Never> { get }

  /// Emits true when there are search or discover results, and we should show the UI to sort and filter those results.
  var showSortAndFilterHeader: Signal<Bool, Never> { get }

  /// Sends a model object which can be used to display all filter options, and a type describing which filters to display.
  var showFilters: Signal<(SearchFilterOptions, SearchFilterModalType), Never> { get }

  /// An @ObservableObject model which SwiftUI can use to observe the selected filters. Owned and automatically updated by the `SearchFiltersUseCase`, which this view model itself owns.
  var selectedFilters: SelectedSearchFilters { get }
}

public protocol SearchViewModelType {
  var inputs: SearchViewModelInputs { get }
  var outputs: SearchViewModelOutputs { get }
}

public final class SearchViewModel: SearchViewModelType, SearchViewModelInputs, SearchViewModelOutputs {
  public init() {
    self.categoriesUseCase = FetchCategoriesUseCase(
      initialSignal: self.viewDidLoadProperty.signal
    )

    self.searchFiltersUseCase = SearchFiltersUseCase(
      initialSignal: self.viewDidLoadProperty.signal,
      categories: self.categoriesUseCase.categories
    )

    let viewWillAppearNotAnimated = self.viewWillAppearAnimatedProperty.signal.filter(isTrue).ignoreValues()

    // What the user has typed in the search bar (or empty, if they've cleared their search).
    let queryText = Signal
      .merge(
        self.searchTextChangedProperty.signal,
        viewWillAppearNotAnimated.mapConst("").take(first: 1),
        self.cancelButtonPressedProperty.signal.mapConst(""),
        self.clearSearchTextProperty.signal.mapConst("")
      )

    // DiscoveryParams using the users currently selected query text, sort and filters.
    let queryParams: Signal<DiscoveryParams, Never> = Signal.combineLatest(
      queryText,
      self.searchFiltersUseCase.selectedSort,
      self.searchFiltersUseCase.selectedCategory,
      self.searchFiltersUseCase.selectedState
    )
    .map { query, sort, category, state in
      DiscoveryParams.withQuery(query, sort: sort, category: category.category, state: state)
    }

    // Every time the user changes their query, sort or filters, we set an empty
    // results set to clear out the page. The user will just see the spinner.
    let clears = queryParams.mapConst([SearchResult]())

    let requestFirstPageWith: Signal<DiscoveryParams, Never> = queryParams

    let isCloseToBottom = self.willDisplayRowProperty.signal.skipNil()
      .map { row, total in
        row >= total - 3
      }
      .skipRepeats()
      .filter(isTrue)
      .ignoreValues()

    var firstRequest = true
    let requestFromOptionsWithDebounce: (DiscoveryParams)
      -> SignalProducer<GraphAPI.SearchQuery.Data, ErrorEnvelope> = { params in
        SignalProducer<(), ErrorEnvelope>(value: ())
          .switchMap {
            let query = GraphAPI.SearchQuery.from(discoveryParams: params)
            let request = AppEnvironment.current.apiService.fetch(query: query)
            // Don't debounce if the page is empty and this is the first request.
            let debounce = firstRequest ? DispatchTimeInterval.seconds(0) : AppEnvironment.current
              .debounceInterval

            if firstRequest {
              firstRequest = false
            }

            return request
              .ksr_debounce(
                debounce, on: AppEnvironment.current.scheduler
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

    let searchResults: Signal<[SearchResult], Never> = Signal.merge(clears, paginatedProjects)
      .skipRepeats(==)

    // Show the 'Discover projects' title if we're showing 'Discover' results (i.e. no query)
    self.isProjectsTitleVisible = Signal.combineLatest(queryText, searchResults)
      .map { query, projects in query.isEmpty && !projects.isEmpty }
      .skipRepeats()

    self.projects = searchResults
      .map { (nodes: [SearchResult]) -> [SearchResultCard] in
        nodes.compactMap { node in
          let fragment = node.fragments.projectCardFragment
          return ProjectCardProperties(fragment)
        }
      }

    let shouldShowEmptyState = Signal.merge(
      queryText.mapConst(false),
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

    self.goToProject = Signal.combineLatest(searchResults, queryText)
      .takePairWhen(self.tappedProjectIndexSignal)
      .map { ($0.0, $0.1, $1) } // ((a, b) c) -> (a, b, c)
      .map { projects, query, index in

        guard index >= 0, index < projects.count else {
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

    Signal.combineLatest(queryText, queryParams, viewWillAppearSearchResultsCount)
      .takeWhen(viewWillAppearNotAnimated)
      .observeValues { query, params, searchResults in
        let results = query.isEmpty ? 0 : searchResults
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

    Signal.combineLatest(queryText, requestFirstPageWith)
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

        guard index >= 0, index < results.count else {
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

    self.showSortAndFilterHeader = self.projects
      .map { results in
        results.count > 0
      }

    self.projectsAndTitle = Signal.combineLatest(
      self.isProjectsTitleVisible,
      self.projects
    )
  }

  fileprivate let cancelButtonPressedProperty = MutableProperty(())
  public func cancelButtonPressed() {
    self.cancelButtonPressedProperty.value = ()
    self.searchFiltersUseCase.inputs.clearedQueryText()
  }

  fileprivate let clearSearchTextProperty = MutableProperty(())
  public func clearSearchText() {
    self.clearSearchTextProperty.value = ()
    self.searchFiltersUseCase.inputs.clearedQueryText()
  }

  fileprivate let searchFieldDidBeginEditingProperty = MutableProperty(())
  public func searchFieldDidBeginEditing() {
    self.searchFieldDidBeginEditingProperty.value = ()
  }

  fileprivate let searchTextChangedProperty = MutableProperty("")
  public func searchTextChanged(_ searchText: String) {
    self.searchTextChangedProperty.value = searchText

    if searchText.isEmpty {
      self.searchFiltersUseCase.inputs.clearedQueryText()
    }
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

  public func tappedButton(forFilterType type: SearchFilterPill.FilterType) {
    self.searchFiltersUseCase.inputs.tappedButton(forFilterType: type)
  }

  public func resetFilters(for type: SearchFilterModalType) {
    self.searchFiltersUseCase.inputs.resetFilters(for: type)
  }

  private let categoriesUseCase: FetchCategoriesUseCase
  private let searchFiltersUseCase: SearchFiltersUseCase

  public let changeSearchFieldFocus: Signal<(focused: Bool, animate: Bool), Never>
  public let goToProject: Signal<(Int, RefTag), Never>
  public let isProjectsTitleVisible: Signal<Bool, Never>
  public let projects: Signal<[SearchResultCard], Never>
  public let resignFirstResponder: Signal<(), Never>
  public let searchFieldText: Signal<String, Never>
  public let searchLoaderIndicatorIsAnimating: Signal<Bool, Never>
  public let showEmptyState: Signal<(DiscoveryParams, Bool), Never>
  public let showSortAndFilterHeader: Signal<Bool, Never>
  public let projectsAndTitle: Signal<(Bool, [SearchResultCard]), Never>

  public var showFilters: Signal<(SearchFilterOptions, SearchFilterModalType), Never> {
    return self.searchFiltersUseCase.showFilters
  }

  public func selectedCategory(_ category: SearchFiltersCategory) {
    self.searchFiltersUseCase.selectedCategory(category)
  }

  public func selectedSortOption(_ sort: DiscoveryParams.Sort) {
    self.searchFiltersUseCase.selectedSortOption(sort)
  }

  public func selectedProjectState(_ state: DiscoveryParams.State) {
    self.searchFiltersUseCase.selectedProjectState(state)
  }

  public var selectedFilters: SelectedSearchFilters {
    return self.searchFiltersUseCase.selectedFilters
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

private struct ProjectCardPropertiesProjectCellModel: BackerDashboardProjectCellViewModel.ProjectCellModel {
  private let properties: ProjectCardProperties
  init(_ properties: ProjectCardProperties) {
    self.properties = properties
  }

  var name: String { self.properties.name }
  var state: KsApi.Project.State { self.properties.state }
  var imageURL: String? { self.properties.image.url?.absoluteString }
  var fundingProgress: Float { Float(self.properties.percentFunded) / 100 }
  var percentFunded: Int { self.properties.percentFunded }
  var displayPrelaunch: Bool? { self.properties.shouldDisplayPrelaunch }
  var prelaunchActivated: Bool? { self.properties.isPrelaunchActivated }
  var launchedAt: TimeInterval? { self.properties.launchedAt?.timeIntervalSince1970 }
  var deadline: TimeInterval? { self.properties.deadlineAt?.timeIntervalSince1970 }
  var isStarred: Bool? { self.properties.isStarred }
}

extension ProjectCardProperties: BackerDashboardProjectCellViewModel.HasProjectCellModel {
  public var projectCellModel: any BackerDashboardProjectCellViewModel.ProjectCellModel {
    ProjectCardPropertiesProjectCellModel(self)
  }
}
