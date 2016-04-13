import Foundation
import Library
import Models
import ReactiveCocoa
import KsApi
import Result
import Prelude

internal protocol SearchViewModelInputs {
  /// Call when the view appears.
  func viewDidAppear()

  /// Call when the user enters a new search term.
  func searchTextChanged(searchText: String)
}

internal protocol SearchViewModelOutputs {
  /// Emits an array of projects when they should be shown on the screen.
  var projects: Signal<[Project], NoError> { get }

  /// Emits true when the popular title should be shown, and false otherwise.
  var isPopularTitleVisible: Signal<Bool, NoError> { get }
}

internal protocol SearchViewModelType {
  var inputs: SearchViewModelInputs { get }
  var outputs: SearchViewModelOutputs { get }
}

internal final class SearchViewModel: SearchViewModelType, SearchViewModelInputs, SearchViewModelOutputs {

  private let viewDidAppearProperty = MutableProperty()
  func viewDidAppear() {
    self.viewDidAppearProperty.value = ()
  }
  private let searchTextChangedProperty = MutableProperty("")
  func searchTextChanged(searchText: String) {
    self.searchTextChangedProperty.value = searchText
  }

  let projects: Signal<[Project], NoError>
  let isPopularTitleVisible: Signal<Bool, NoError>

  var inputs: SearchViewModelInputs { return self }
  var outputs: SearchViewModelOutputs { return self }

  init() {
    let query = Signal.merge([
      self.searchTextChangedProperty.signal,
      self.viewDidAppearProperty.signal.map(const("")).take(1)
      ])

    let clears = query.skip(1).map(const([Project]()))

    let popular = query
      .filter { $0.isEmpty }
      .map(const(DiscoveryParams(sort: .Popular)))
      .switchMap { AppEnvironment.current.apiService.fetchProjects($0).demoteErrors() }

    let searchResults = query
      .switchMap { q in SignalProducer(value: q)
        .debounce(AppEnvironment.current.debounceInterval, onScheduler: AppEnvironment.current.scheduler)
        .skipRepeats()
        .filter { !$0.isEmpty }
        .map { DiscoveryParams(query: $0) }
        .switchMap { params in
          AppEnvironment.current.apiService.fetchProjects(params)
            .demoteErrors()
            .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
        }
    }

    self.projects = Signal.merge([clears, popular, searchResults])
      .skipRepeats(==)

    self.isPopularTitleVisible = query
      .map { $0.isEmpty }
      .skipRepeats()

    self.viewDidAppearProperty.signal
      .take(1)
      .observeNext { AppEnvironment.current.koala.trackProjectSearchView() }

    query
      .filter { !$0.isEmpty }
      .takeWhen(searchResults)
      .observeNext { AppEnvironment.current.koala.trackSearchResults(query: $0, pageCount: 1) }
  }
}
