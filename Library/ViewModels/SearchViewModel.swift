import Foundation
import KsApi
import ReactiveCocoa
import KsApi
import Result
import Prelude

public protocol SearchViewModelInputs {
  /// Call when the cancel button is pressed.
  func cancelButtonPressed()

  /// Call when the search field begins editing.
  func searchFieldDidBeginEditing()

  /// Call when the user enters a new search term.
  func searchTextChanged(searchText: String)

  /// Call when the view appears.
  func viewDidAppear()
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
    let query = Signal.merge([
      self.searchTextChangedProperty.signal,
      self.viewDidAppearProperty.signal.map(const("")).take(1),
      self.cancelButtonPressedProperty.signal.mapConst("")
      ])

    let clears = query.skip(1).map(const([Project]()))

    let popular = query
      .filter { $0.isEmpty }
      .map(const(DiscoveryParams.defaults |> DiscoveryParams.lens.sort .~ .popular))
      .switchMap {
        AppEnvironment.current.apiService.fetchDiscovery(params: $0)
          .map { $0.projects }
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .demoteErrors()
    }

    let searchResults = query
      .ksr_debounce(AppEnvironment.current.debounceInterval, onScheduler: AppEnvironment.current.scheduler)
      .skipRepeats()
      .filter { !$0.isEmpty }
      .map { DiscoveryParams.defaults |> DiscoveryParams.lens.query .~ $0 }
      .switchMap { params in
        AppEnvironment.current.apiService.fetchDiscovery(params: params)
          .map { $0.projects }
          .demoteErrors()
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
    }

    self.projects = Signal.merge([clears, popular, searchResults])
      .skipRepeats(==)

    self.isPopularTitleVisible = Signal.merge(
      popular.mapConst(true),
      clears.mapConst(false),
      searchResults.mapConst(false)
      )
      .skipRepeats()

    self.viewDidAppearProperty.signal
      .take(1)
      .observeNext { AppEnvironment.current.koala.trackProjectSearchView() }

    query
      .filter { !$0.isEmpty }
      .takeWhen(searchResults)
      .observeNext { AppEnvironment.current.koala.trackSearchResults(query: $0, pageCount: 1) }

    self.changeSearchFieldFocus = Signal.merge(
      self.viewDidAppearProperty.signal.mapConst((false, false)),
      self.cancelButtonPressedProperty.signal.mapConst((false, true)),
      self.searchFieldDidBeginEditingProperty.signal.mapConst((true, true))
    )

    self.searchFieldText = self.cancelButtonPressedProperty.signal.mapConst("")
  }
  // swiftlint:enable function_body_length

  private let cancelButtonPressedProperty = MutableProperty()
  public func cancelButtonPressed() {
    self.cancelButtonPressedProperty.value = ()
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

  public let changeSearchFieldFocus: Signal<(focused: Bool, animate: Bool), NoError>
  public let isPopularTitleVisible: Signal<Bool, NoError>
  public let projects: Signal<[Project], NoError>
  public let searchFieldText: Signal<String, NoError>

  public var inputs: SearchViewModelInputs { return self }
  public var outputs: SearchViewModelOutputs { return self }
}
