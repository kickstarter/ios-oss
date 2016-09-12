import Foundation
import KsApi
import ReactiveCocoa
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
  func searchTextChanged(searchText: String)

  /// Call when the view appears.
  func viewDidAppear()

  /**
   Call from the controller's `tableView:willDisplayCell:forRowAtIndexPath` method.

   - parameter row:       The 0-based index of the row displaying.
   - parameter totalRows: The total number of rows in the table view.
   */
  func willDisplayRow(row: Int, outOf totalRows: Int)
}

public protocol SearchViewModelOutputs {
  /// Emits booleans that determines if the search field should be focused or not, and whether that focus
  /// should be animated.
  var changeSearchFieldFocus: Signal<(focused: Bool, animate: Bool), NoError> { get }

  /// Emits true when the popular title should be shown, and false otherwise.
  var isPopularTitleVisible: Signal<Bool, NoError> { get }

  /// Emits an array of projects when they should be shown on the screen.
  var projects: Signal<[Project], NoError> { get }

  /// Emits a string that should be filled into the search field.
  var searchFieldText: Signal<String, NoError> { get }
}

public protocol SearchViewModelType {
  var inputs: SearchViewModelInputs { get }
  var outputs: SearchViewModelOutputs { get }
}

public final class SearchViewModel: SearchViewModelType, SearchViewModelInputs, SearchViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {
    let query = Signal
      .merge(
        self.searchTextChangedProperty.signal,
        self.viewDidAppearProperty.signal.map(const("")).take(1),
        self.cancelButtonPressedProperty.signal.mapConst(""),
        self.clearSearchTextProperty.signal.mapConst("")
      )

    let popular = self.viewDidAppearProperty.signal
      .switchMap {
        AppEnvironment.current.apiService
          .fetchDiscovery(params: .defaults |> DiscoveryParams.lens.sort .~ .popular)
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .demoteErrors()
      }
      .map { $0.projects }

    let clears = query.mapConst([Project]())

    self.isPopularTitleVisible = combineLatest(query, popular)
      .map { query, _ in query.isEmpty }
      .skipRepeats()

    let requestFirstPageWith = query
      .filter { !$0.isEmpty }
      .map { .defaults |> DiscoveryParams.lens.query .~ $0 }

    let isCloseToBottom = self.willDisplayRowProperty.signal.ignoreNil()
      .map { row, total in row >= total - 3 }
      .skipRepeats()
      .filter(isTrue)
      .ignoreValues()

    let requestFromParamsWithDebounce = { params in
      SignalProducer<(), ErrorEnvelope>(value: ())
        .switchMap {
          AppEnvironment.current.apiService.fetchDiscovery(params: params)
            .ksr_debounce(
              AppEnvironment.current.debounceInterval, onScheduler: AppEnvironment.current.scheduler)
      }
    }

    let (searchResults, _, page) = paginate(
      requestFirstPageWith: requestFirstPageWith,
      requestNextPageWhen: isCloseToBottom,
      clearOnNewRequest: true,
      valuesFromEnvelope: { $0.projects },
      cursorFromEnvelope: { $0.urls.api.moreProjects },
      requestFromParams: requestFromParamsWithDebounce,
      requestFromCursor: { AppEnvironment.current.apiService.fetchDiscovery(paginationUrl: $0) })

    self.projects = combineLatest(self.isPopularTitleVisible, popular, .merge(clears, searchResults))
      .map { showPopular, popular, searchResults in showPopular ? popular : searchResults }
      .skipRepeats(==)

    self.changeSearchFieldFocus = Signal.merge(
      self.viewDidAppearProperty.signal.mapConst((false, false)),
      self.cancelButtonPressedProperty.signal.mapConst((false, true)),
      self.searchFieldDidBeginEditingProperty.signal.mapConst((true, true))
    )

    self.searchFieldText = self.cancelButtonPressedProperty.signal.mapConst("")

    // koala

    self.viewDidAppearProperty.signal
      .take(1)
      .observeNext { AppEnvironment.current.koala.trackProjectSearchView() }

    combineLatest(query, page)
      .takePairWhen(searchResults.map { !$0.isEmpty })
      .map(unpack)
      .filter { query, _, _ in !query.isEmpty }
      .observeNext { query, page, hasResults in
        AppEnvironment.current.koala.trackSearchResults(query: query, page: page, hasResults: hasResults)
    }

    self.clearSearchTextProperty.signal
      .observeNext { AppEnvironment.current.koala.trackClearedSearchTerm() }
  }
  // swiftlint:enable function_body_length

  private let cancelButtonPressedProperty = MutableProperty()
  public func cancelButtonPressed() {
    self.cancelButtonPressedProperty.value = ()
  }

  private let clearSearchTextProperty = MutableProperty()
  public func clearSearchText() {
    self.clearSearchTextProperty.value = ()
  }

  private let searchFieldDidBeginEditingProperty = MutableProperty()
  public func searchFieldDidBeginEditing() {
    self.searchFieldDidBeginEditingProperty.value = ()
  }

  private let searchTextChangedProperty = MutableProperty("")
  public func searchTextChanged(searchText: String) {
    self.searchTextChangedProperty.value = searchText
  }

  private let viewDidAppearProperty = MutableProperty()
  public func viewDidAppear() {
    self.viewDidAppearProperty.value = ()
  }

  private let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func willDisplayRow(row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  public let changeSearchFieldFocus: Signal<(focused: Bool, animate: Bool), NoError>
  public let isPopularTitleVisible: Signal<Bool, NoError>
  public let projects: Signal<[Project], NoError>
  public let searchFieldText: Signal<String, NoError>

  public var inputs: SearchViewModelInputs { return self }
  public var outputs: SearchViewModelOutputs { return self }
}
