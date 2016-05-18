import Foundation
import Library
import Models
import ReactiveCocoa
import KsApi
import Result
import Prelude

internal protocol MessagesSearchViewModelInputs {
  /// Call with the (optional) project given to the view.
  func configureWith(project project: Project?)

  /// Call when the search text changes.
  func searchTextChanged(searchText: String?)

  /// Call when a message thread is tapped.
  func tappedMessageThread(messageThread: MessageThread)

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the view will appear.
  func viewWillAppear()

  /// Call when the view will disappear.
  func viewWillDisappear()
}

internal protocol MessagesSearchViewModelOutputs {
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

internal protocol MessagesSearchViewModelType {
  var inputs: MessagesSearchViewModelInputs { get }
  var outputs: MessagesSearchViewModelOutputs { get }
}

internal final class MessagesSearchViewModel: MessagesSearchViewModelType, MessagesSearchViewModelInputs,
MessagesSearchViewModelOutputs {

  internal init() {
    let isLoading = MutableProperty(false)

    let project = self.projectProperty.producer
      .takeWhen(self.viewDidLoadProperty.signal)

    let query = self.searchTextChangedProperty.signal

    let clears = query.map(const([MessageThread]()))

    let searchResults = query
      .switchMap {
        SignalProducer(value: $0)
          .debounce(AppEnvironment.current.debounceInterval, onScheduler: AppEnvironment.current.scheduler)
      }
      .skipRepeats()
      .filter { !$0.isEmpty }
      .combineLatestWith(project)
      .switchMap { query, project in
        AppEnvironment.current.apiService.searchMessages(query: query, project: project)
          .on(started: { isLoading.value = true },
              terminated: { isLoading.value = false })
          .map { $0.messageThreads }
          .materialize()
    }

    self.messageThreads = Signal.merge(clears, searchResults.values())
      .skipWhile { $0.isEmpty }
      .skipRepeats(==)

    self.showKeyboard = Signal.merge(
      self.viewWillAppearProperty.signal.mapConst(true),
      self.viewWillDisappearProperty.signal.mapConst(false)
    )

    self.emptyStateIsVisible = .empty

    self.isSearching = Signal.merge(
      self.viewDidLoadProperty.signal.take(1).mapConst(false),
      query.map { !$0.isEmpty },
      isLoading.signal
    ).skipRepeats()

    self.goToMessageThread = self.tappedMessageThreadProperty.signal.ignoreNil()

    combineLatest(project.take(1), query)
      .takeWhen(self.messageThreads.filter { !$0.isEmpty })
      .observeNext { project, term in
        AppEnvironment.current.koala.trackMessageThreadsSearch(term: term, project: project)
    }
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  internal func configureWith(project project: Project?) {
    self.projectProperty.value = project
  }
  private let searchTextChangedProperty = MutableProperty<String>("")
  internal func searchTextChanged(searchText: String?) {
    self.searchTextChangedProperty.value = searchText ?? ""
  }
  private let tappedMessageThreadProperty = MutableProperty<MessageThread?>(nil)
  internal func tappedMessageThread(messageThread: MessageThread) {
    self.tappedMessageThreadProperty.value = messageThread
  }
  private let viewDidLoadProperty = MutableProperty()
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }
  private let viewWillAppearProperty = MutableProperty()
  internal func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }
  private let viewWillDisappearProperty = MutableProperty()
  internal func viewWillDisappear() {
    self.viewWillDisappearProperty.value = ()
  }

  internal let emptyStateIsVisible: Signal<Bool, NoError>
  internal let goToMessageThread: Signal<MessageThread, NoError>
  internal let isSearching: Signal<Bool, NoError>
  internal let messageThreads: Signal<[MessageThread], NoError>
  internal let showKeyboard: Signal<Bool, NoError>

  internal var inputs: MessagesSearchViewModelInputs { return self }
  internal var outputs: MessagesSearchViewModelOutputs { return self }
}
