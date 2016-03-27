import struct Foundation.NSTimeInterval
import struct Library.AppEnvironment
import struct Library.Environment
import struct Models.Project
import struct ReactiveCocoa.SignalProducer
import class ReactiveCocoa.Signal
import struct KsApi.Service
import struct KsApi.DiscoveryParams
import enum Result.NoError
import func Prelude.const

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
  
  private let (viewDidAppearSignal, viewDidAppearObserver) = Signal<(), NoError>.pipe()
  func viewDidAppear() {
    viewDidAppearObserver.sendNext()
  }
  private let (searchTextChangedSignal, searchTextChangedObserver) = Signal<String, NoError>.pipe()
  func searchTextChanged(searchText: String) {
    searchTextChangedObserver.sendNext(searchText)
  }

  let projects: Signal<[Project], NoError>
  let isPopularTitleVisible: Signal<Bool, NoError>
  
  var inputs: SearchViewModelInputs { return self }
  var outputs: SearchViewModelOutputs { return self }
  
  init(env: Environment = AppEnvironment.current) {

    let query = searchTextChangedSignal
      .mergeWith(viewDidAppearSignal.map(const("")).take(1))

    let clears = query.skip(1).map(const([Project]()))

    let popular = query
      .filter { $0.isEmpty }
      .map(const(DiscoveryParams(sort: .Popular)))
      .switchMap { env.apiService.fetchProjects($0).demoteErrors() }

    let searchResults = query
      .switchMap { q in SignalProducer(value: q)
        .debounce(env.debounceInterval, onScheduler: env.scheduler)
        .skipRepeats()
        .filter { !$0.isEmpty }
        .map { DiscoveryParams(query: $0) }
        .switchMap {
          env.apiService.fetchProjects($0)
            .demoteErrors()
            .delay(env.apiThrottleInterval, onScheduler: env.scheduler)
        }
    }

    self.projects = Signal.merge([clears, popular, searchResults])
      .skipRepeats(==)

    self.isPopularTitleVisible = query
      .map { $0.isEmpty }
      .skipRepeats()

    self.viewDidAppearSignal
      .take(1)
      .observeNext { _ in env.koala.trackProjectSearchView() }

    query
      .filter { !$0.isEmpty }
      .takeWhen(searchResults)
      .observeNext { env.koala.trackSearchResults(query: $0, pageCount: 1) }
  }
}
