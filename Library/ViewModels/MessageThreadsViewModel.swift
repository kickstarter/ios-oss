import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol MessageThreadsViewModelInputs {
  /// Call when the mailbox chooser button is pressed.
  func mailboxButtonPressed()

  /// Call with the project whose message threads we are viewing. If no project or refTag is given, then use
  /// `nil`.
  func configureWith(project: Project?, refTag: RefTag?)

  /// Call when pull-to-refresh is invoked.
  func refresh()

  /// Call when the search button is pressed.
  func searchButtonPressed()

  /// Call when the user has selected a mailbox to switch to.
  func switchTo(mailbox: Mailbox)

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when a new row is displayed.
  func willDisplayRow(_ row: Int, outOf totalRows: Int)
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

    public init() {
    let isCloseToBottom = self.willDisplayRowProperty.signal.skipNil()
      .filter { _, total in total > 1 }
      .map { row, total in row >= total - 3 }
      .skipRepeats()
      .filter { isClose in isClose }
      .ignoreValues()

    let mailbox = Signal.merge(
      self.switchToMailbox.signal.skipNil(),
      self.viewDidLoadProperty.signal.mapConst(.inbox)
    )

    let configData = Signal.combineLatest(
      self.configDataProperty.signal.skipNil(),
      mailbox
    )
    .map(first)

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
      requestFromParams: { [project = configDataProperty.producer.map { $0?.project }] mailbox in
        project.take(first: 1)
          .promoteError(ErrorEnvelope.self)
          .flatMap { project in
            AppEnvironment.current.apiService.fetchMessageThreads(mailbox: mailbox, project: project)
        }
      },
      requestFromCursor: {
        AppEnvironment.current.apiService.fetchMessageThreads(paginationUrl: $0)
    })

    self.mailboxName = mailbox.map {
      switch $0 {
      case .inbox:  return Strings.messages_navigation_inbox()
      case .sent:   return Strings.messages_navigation_sent()
      }
    }

    self.messageThreads = messageThreads

    self.refreshControlEndRefreshing = isLoading.filter(isFalse).ignoreValues()

    self.emptyStateIsVisible = Signal.merge(
      self.messageThreads.filter { !$0.isEmpty }.mapConst(false),
      self.messageThreads.takeWhen(isLoading.filter(isFalse)).filter { $0.isEmpty }.mapConst(true)
    ).skipRepeats()

    self.loadingFooterIsHidden = Signal.merge([
      self.viewDidLoadProperty.signal.take(first: 1).mapConst(false),
      isCloseToBottom.mapConst(false),
      mailbox.mapConst(false),
      isLoading.filter(isFalse).mapConst(true),
    ]).skipRepeats()

    self.showMailboxChooserActionSheet = self.mailboxButtonPressedProperty.signal

    self.goToSearch = self.searchButtonPressedProperty.signal

    configData
      .takePairWhen(mailbox)
      .observeValues { configData, mailbox in
        AppEnvironment.current.koala.trackMessageThreadsView(mailbox: mailbox,
                                                             project: configData.project,
                                                             refTag: configData.refTag ?? .unrecognized(""))

      }
  }
  // swiftlint:enable function_body_length

  fileprivate let mailboxButtonPressedProperty = MutableProperty(())
  public func mailboxButtonPressed() {
    self.mailboxButtonPressedProperty.value = ()
  }
  fileprivate let configDataProperty = MutableProperty<ConfigData?>(nil)
  public func configureWith(project: Project?, refTag: RefTag?) {
    self.configDataProperty.value = ConfigData(project: project, refTag: refTag)
  }
  fileprivate let refreshProperty = MutableProperty(())
  public func refresh() {
    self.refreshProperty.value = ()
  }
  fileprivate let searchButtonPressedProperty = MutableProperty(())
  public func searchButtonPressed() {
    self.searchButtonPressedProperty.value = ()
  }
  fileprivate let switchToMailbox = MutableProperty<Mailbox?>(nil)
  public func switchTo(mailbox: Mailbox) {
    self.switchToMailbox.value = mailbox
  }
  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }
  fileprivate let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
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

private struct ConfigData {
  fileprivate let project: Project?
  fileprivate let refTag: RefTag?
}
