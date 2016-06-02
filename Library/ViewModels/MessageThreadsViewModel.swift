import KsApi
import Models
import Prelude
import ReactiveCocoa
import Result

public protocol MessageThreadsViewModelInputs {
  /// Call when the mailbox chooser button is pressed.
  func mailboxButtonPressed()

  /// Call with the project whose message threads we are viewing. If no project is given, then use `nil`.
  func configureWith(project project: Project?)

  /// Call when pull-to-refresh is invoked.
  func refresh()

  /// Call when the search button is pressed.
  func searchButtonPressed()

  /// Call when the user has selected a mailbox to switch to.
  func switchTo(mailbox mailbox: Mailbox)

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when a new row is displayed.
  func willDisplayRow(row: Int, outOf totalRows: Int)
}

public protocol MessageThreadsViewModelOutputs {
  /// Emits a boolean that determines if the empty state is visible.
  var emptyStateIsVisible: Signal<Bool, NoError> { get }

  /// Emits when we should go to the search messages screen.
  var goToSearch: Signal<(), NoError> { get }

  /// Emits a boolean that determines if the footer loading view is hidden.
  var loadingFooterIsHidden: Signal<Bool, NoError> { get }

  /// Emits a string of the mailbox we are currently viewing.
  var mailboxName: Signal<String, NoError> { get }

  /// Emits an array of message threads to be displayed.
  var messageThreads: Signal<[MessageThread], NoError> { get }

  /// Emits when the refresh control should end refreshing.
  var refreshControlEndRefreshing: Signal<(), NoError> { get }

  /// Emits when an action sheet should be displayed that allows the user to choose mailboxes.
  var showMailboxChooserActionSheet: Signal<(), NoError> { get }
}

public protocol MessageThreadsViewModelType {
  var inputs: MessageThreadsViewModelInputs { get }
  var outputs: MessageThreadsViewModelOutputs { get }
}

public final class MessageThreadsViewModel: MessageThreadsViewModelType, MessageThreadsViewModelInputs,
MessageThreadsViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {
    let isCloseToBottom = self.willDisplayRowProperty.signal.ignoreNil()
      .filter { row, total in total > 1 }
      .map { row, total in row >= total - 3 }
      .skipRepeats()
      .filter { isClose in isClose }
      .ignoreValues()

    let mailbox = Signal.merge(
      self.switchToMailbox.signal.ignoreNil(),
      self.viewDidLoadProperty.signal.mapConst(.inbox)
    )

    let requestFirstPageWith = Signal.merge(
      mailbox,
      mailbox.takeWhen(self.refreshProperty.signal)
    )

    let (messageThreads, isLoading, _) = paginate(
      requestFirstPageWith: requestFirstPageWith,
      requestNextPageWhen: isCloseToBottom,
      clearOnNewRequest: true,
      valuesFromEnvelope: { $0.messageThreads },
      cursorFromEnvelope: { $0.urls.api.moreMessageThreads },
      requestFromParams: { [project = projectProperty.producer] mailbox in
        project.take(1)
          .promoteErrors(ErrorEnvelope.self)
          .flatMap { project in
            AppEnvironment.current.apiService.fetchMessageThreads(mailbox: mailbox, project: project)
        }
      },
      requestFromCursor: {
        AppEnvironment.current.apiService.fetchMessageThreads(paginationUrl: $0)
    })

    self.mailboxName = mailbox.map {
      switch $0 {
      case .inbox:  return localizedString(key: "messages.navigation.inbox", defaultValue: "Inbox")
      case .sent:   return localizedString(key: "messages.navigation.sent", defaultValue: "Sent")
      }
    }

    self.messageThreads = messageThreads

    self.refreshControlEndRefreshing = isLoading.filter(isFalse).ignoreValues()

    self.emptyStateIsVisible = Signal.merge(
      self.messageThreads.filter { !$0.isEmpty }.mapConst(false),
      self.messageThreads.takeWhen(isLoading.filter(isFalse)).filter { $0.isEmpty }.mapConst(true)
    ).skipRepeats()

    self.loadingFooterIsHidden = Signal.merge([
      self.viewDidLoadProperty.signal.take(1).mapConst(false),
      isCloseToBottom.mapConst(false),
      mailbox.mapConst(false),
      isLoading.filter(isFalse).mapConst(true),
    ]).skipRepeats()

    self.showMailboxChooserActionSheet = self.mailboxButtonPressedProperty.signal

    self.goToSearch = self.searchButtonPressedProperty.signal

    self.projectProperty.producer
      .takePairWhen(mailbox)
      .observeNext { project, mailbox in
        AppEnvironment.current.koala.trackMessageThreadsView(mailbox: mailbox, project: project)
    }
  }
  // swiftlint:enable function_body_length

  private let mailboxButtonPressedProperty = MutableProperty()
  public func mailboxButtonPressed() {
    self.mailboxButtonPressedProperty.value = ()
  }
  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project project: Project?) {
    self.projectProperty.value = project
  }
  private let refreshProperty = MutableProperty()
  public func refresh() {
    self.refreshProperty.value = ()
  }
  private let searchButtonPressedProperty = MutableProperty()
  public func searchButtonPressed() {
    self.searchButtonPressedProperty.value = ()
  }
  private let switchToMailbox = MutableProperty<Mailbox?>(nil)
  public func switchTo(mailbox mailbox: Mailbox) {
    self.switchToMailbox.value = mailbox
  }
  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }
  private let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func willDisplayRow(row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  public let emptyStateIsVisible: Signal<Bool, NoError>
  public let loadingFooterIsHidden: Signal<Bool, NoError>
  public let goToSearch: Signal<(), NoError>
  public let mailboxName: Signal<String, NoError>
  public let messageThreads: Signal<[MessageThread], NoError>
  public let refreshControlEndRefreshing: Signal<(), NoError>
  public let showMailboxChooserActionSheet: Signal<(), NoError>

  public var inputs: MessageThreadsViewModelInputs { return self }
  public var outputs: MessageThreadsViewModelOutputs { return self }
}
