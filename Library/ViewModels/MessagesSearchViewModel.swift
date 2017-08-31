import Foundation
import KsApi
import ReactiveSwift
import KsApi
import Result
import Prelude

public protocol MessagesSearchViewModelInputs {
  /// Call when the search clear button is tapped.
  func clearSearchText()

  /// Call with the (optional) project given to the view.
  func configureWith(project: Project?)

  /// Call when the search text changes.
  func searchTextChanged(_ searchText: String?)

  /// Call when a message thread is tapped.
  func tappedMessageThread(_ messageThread: MessageThread)

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the view will appear.
  func viewWillAppear()

  /// Call when the view will disappear.
  func viewWillDisappear()
}

public protocol MessagesSearchViewModelOutputs {
  /// Emits a boolean that determines if the empty state is visible.
  var emptyStateIsVisible: Signal<Bool, NoError> { get }

  /// Emits when we should navigate to the message thread.
  var goToMessageThread: Signal<MessageThread, NoError> { get }

  /// Emits a boolean that determines if a search request is currently in-flight.
  var isSearching: Signal<Bool, NoError> { get }

  /// Emits an array of message threads to be displayed.
  var messageThreads: Signal<[MessageThread], NoError> { get }

  /// Emits a boolean that determines if the keyboard should be shown or not.
  var showKeyboard: Signal<Bool, NoError> { get }
}

public protocol MessagesSearchViewModelType {
  var inputs: MessagesSearchViewModelInputs { get }
  var outputs: MessagesSearchViewModelOutputs { get }
}

public final class MessagesSearchViewModel: MessagesSearchViewModelType, MessagesSearchViewModelInputs,
MessagesSearchViewModelOutputs {

    public init() {
    let isLoading = MutableProperty(false)

    let project = self.projectProperty.producer
      .takeWhen(self.viewDidLoadProperty.signal)

    let query = Signal
      .merge(
        self.searchTextChangedProperty.signal,
        self.clearSearchTextProperty.signal.mapConst("")
      )
      .skipRepeats()

    let clears = query.map(const([MessageThread]()))

    let searchResults = query
      .ksr_debounce(AppEnvironment.current.debounceInterval, on: AppEnvironment.current.scheduler)
      .skipRepeats()
      .filter { !$0.isEmpty }
      .combineLatest(with: project)
      .switchMap { query, project in
        AppEnvironment.current.apiService.searchMessages(query: query, project: project)
          .on(starting: { isLoading.value = true },
              terminated: { isLoading.value = false })
          .map { $0.messageThreads }
          .materialize()
    }

    self.messageThreads = Signal.merge(clears, searchResults.values())
      .skip(while: { $0.isEmpty })
      .skipRepeats(==)

    self.showKeyboard = Signal.merge(
      self.viewWillAppearProperty.signal.mapConst(true),
      self.viewWillDisappearProperty.signal.mapConst(false)
    )

    self.emptyStateIsVisible = .empty

    self.isSearching = Signal.merge(
      self.viewDidLoadProperty.signal.take(first: 1).mapConst(false),
      query.map { !$0.isEmpty },
      isLoading.signal
    ).skipRepeats()

    self.goToMessageThread = self.tappedMessageThreadProperty.signal.skipNil()

    project
      .takeWhen(self.viewDidLoadProperty.signal)
      .observeValues { AppEnvironment.current.koala.trackViewedMessageSearch(project: $0) }

    Signal.combineLatest(query, project.take(first: 1), self.messageThreads.map { !$0.isEmpty })
      .takeWhen(self.isSearching.filter(isFalse))
      .filter { query, _, _ in !query.isEmpty }
      .observeValues {
        AppEnvironment.current.koala.trackViewedMessageSearchResults(term: $0, project: $1, hasResults: $2)
    }

    project
      .takeWhen(self.clearSearchTextProperty.signal)
      .observeValues { AppEnvironment.current.koala.trackClearedMessageSearchTerm(project: $0) }
  }

  fileprivate let clearSearchTextProperty = MutableProperty()
  public func clearSearchText() {
    self.clearSearchTextProperty.value = ()
  }
  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project?) {
    self.projectProperty.value = project
  }
  fileprivate let searchTextChangedProperty = MutableProperty<String>("")
  public func searchTextChanged(_ searchText: String?) {
    self.searchTextChangedProperty.value = searchText ?? ""
  }
  fileprivate let tappedMessageThreadProperty = MutableProperty<MessageThread?>(nil)
  public func tappedMessageThread(_ messageThread: MessageThread) {
    self.tappedMessageThreadProperty.value = messageThread
  }
  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }
  fileprivate let viewWillAppearProperty = MutableProperty()
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }
  fileprivate let viewWillDisappearProperty = MutableProperty()
  public func viewWillDisappear() {
    self.viewWillDisappearProperty.value = ()
  }

  public let emptyStateIsVisible: Signal<Bool, NoError>
  public let goToMessageThread: Signal<MessageThread, NoError>
  public let isSearching: Signal<Bool, NoError>
  public let messageThreads: Signal<[MessageThread], NoError>
  public let showKeyboard: Signal<Bool, NoError>

  public var inputs: MessagesSearchViewModelInputs { return self }
  public var outputs: MessagesSearchViewModelOutputs { return self }
}
