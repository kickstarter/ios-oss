import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol MessagesViewModelInputs {
  /// Call when the backing button is pressed.
  func backingInfoPressed()

  /// Configures the view model with either a message thread or a project and a backing.
  func configureWith(data: Either<MessageThread, (project: Project, backing: Backing)>)

  /// Call when the message dialog has told us that a message was successfully posted.
  func messageSent(_ message: Message)

  /// Call when the project banner is tapped.
  func projectBannerTapped()

  /// Call when the reply button is pressed.
  func replyButtonPressed()

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol MessagesViewModelOutputs {
  /** 
   Emits a Backing and Project that can be used to populate the BackingCell.
   The boolean tells if navigation to this screen occurred from the backing info screen.
  */
  var backingAndProjectAndIsFromBacking: Signal<(Backing, Project, Bool), NoError> { get }

  /// Emits a boolean that determines if the empty state is visible and a message to display.
  var emptyStateIsVisibleAndMessageToUser: Signal<(Bool, String), NoError> { get }

  /// Emits when we should go to the backing screen.
  var goToBacking: Signal<(Project, User), NoError> { get }

  /// Emits when we should go to the projet.
  var goToProject: Signal<(Project, RefTag), NoError> { get }

  /// Emits a list of messages to be displayed.
  var messages: Signal<[Message], NoError> { get }

  /// Emits when we should show the message dialog.
  var presentMessageDialog: Signal<(MessageThread, Koala.MessageDialogContext), NoError> { get }

  /// Emits the project we are viewing the messages for.
  var project: Signal<Project, NoError> { get }

  /// Emits a bool whether the reply button is enabled.
  var replyButtonIsEnabled: Signal<Bool, NoError> { get }

  /// Emits when the thread has been marked as read.
  var successfullyMarkedAsRead: Signal<(), NoError> { get }
}

public protocol MessagesViewModelType {
  var inputs: MessagesViewModelInputs { get }
  var outputs: MessagesViewModelOutputs { get }
}

public final class MessagesViewModel: MessagesViewModelType, MessagesViewModelInputs,
MessagesViewModelOutputs {

    public init() {
    let configData = self.configData.signal.skipNil()
      .takeWhen(self.viewDidLoadProperty.signal)

    let configBacking = configData.map { $0.right?.backing }

    let configThread = configData.map { $0.left }
      .skipNil()

    let currentUser = self.viewDidLoadProperty.signal
      .map { AppEnvironment.current.currentUser }
      .skipNil()

    self.project = configData
      .map {
        switch $0 {
        case let .left(thread):
          return thread.project
        case let .right((project, _)):
          return project
        }
    }

    let backingOrThread = Signal.merge(
      configBacking.skipNil().map(Either.left),
      configThread.map(Either.right)
    )

    let messageThreadEnvelopeEvent = Signal.merge(
      backingOrThread,
      backingOrThread.takeWhen(self.messageSentProperty.signal)
      )
      .switchMap { backingOrThread -> SignalProducer<Event<MessageThreadEnvelope, ErrorEnvelope>, NoError> in
        switch backingOrThread {
        case let .left(backing):
          return AppEnvironment.current.apiService.fetchMessageThread(backing: backing)
            .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
            .materialize()
        case let .right(thread):
          return AppEnvironment.current.apiService.fetchMessageThread(messageThreadId: thread.id)
            .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
            .materialize()
        }
    }

    let messageThreadEnvelope = messageThreadEnvelopeEvent.values()

    let participant = messageThreadEnvelope.map { $0.messageThread.participant }

    self.backingAndProjectAndIsFromBacking = Signal.combineLatest(
      configBacking, self.project, participant, currentUser
      )
      .switchMap { value -> SignalProducer<(Backing, Project, Bool), NoError> in
        let (backing, project, participant, currentUser) = value

        if let backing = backing {
          return SignalProducer(value: (backing, project, true))
        }

        let request = project.personalization.isBacking == .some(true)
          ? AppEnvironment.current.apiService.fetchBacking(forProject: project, forUser: currentUser)
          : AppEnvironment.current.apiService.fetchBacking(forProject: project, forUser: participant)

        return request
          .map { ($0, project, false) }
          .demoteErrors()
    }

    self.messages = messageThreadEnvelope
      .map { $0.messages }
      .sort { $0.id > $1.id }

    self.emptyStateIsVisibleAndMessageToUser = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst((false, "")),
      Signal.combineLatest(
        messageThreadEnvelopeEvent.errors(), // todo: fix Argo decoding error
        configBacking.skipNil(),
        self.project
        )
        .map { _, backing, project in
          let isCreator = project.creator == AppEnvironment.current.currentUser
            && backing.backer != AppEnvironment.current.currentUser
          let message = isCreator
            ? Strings.messages_empty_state_message_creator()
            : Strings.messages_empty_state_message_backer()
          return (true, message)
      }
    )

    self.replyButtonIsEnabled = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(false),
      self.messages.map { !$0.isEmpty }
    )

    self.presentMessageDialog = messageThreadEnvelope
      .map { ($0.messageThread, .messages) }
      .takeWhen(self.replyButtonPressedProperty.signal)

    self.goToBacking = Signal.combineLatest(messageThreadEnvelope, currentUser)
      .takeWhen(self.backingInfoPressedProperty.signal)
      .map { env, currentUser in
        env.messageThread.project.personalization.isBacking == .some(true)
          ? (env.messageThread.project, currentUser)
          : (env.messageThread.project, env.messageThread.participant)
    }

    self.goToProject = self.project.takeWhen(self.projectBannerTappedProperty.signal)
      .map { ($0, .messageThread) }

    self.successfullyMarkedAsRead = messageThreadEnvelope
      .switchMap {
        AppEnvironment.current.apiService.markAsRead(messageThread: $0.messageThread)
          .demoteErrors()
      }
      .ignoreValues()

    Signal.combineLatest(project, self.viewDidLoadProperty.signal)
      .take(first: 1)
      .observeValues { project, _ in
        AppEnvironment.current.koala.trackMessageThreadView(project: project)
    }
  }
  // swiftlint:enable function_body_length

  private let backingInfoPressedProperty = MutableProperty()
  public func backingInfoPressed() {
    self.backingInfoPressedProperty.value = ()
  }
  private let configData = MutableProperty<Either<MessageThread, (project: Project, backing: Backing)>?>(nil)
  public func configureWith(data: Either<MessageThread, (project: Project, backing: Backing)>) {
    self.configData.value = data
  }

  private let messageSentProperty = MutableProperty<Message?>(nil)
  public func messageSent(_ message: Message) {
    self.messageSentProperty.value = message
  }
  private let projectBannerTappedProperty = MutableProperty()
  public func projectBannerTapped() {
    self.projectBannerTappedProperty.value = ()
  }
  private let replyButtonPressedProperty = MutableProperty()
  public func replyButtonPressed() {
    self.replyButtonPressedProperty.value = ()
  }
  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let backingAndProjectAndIsFromBacking: Signal<(Backing, Project, Bool), NoError>
  public let emptyStateIsVisibleAndMessageToUser: Signal<(Bool, String), NoError>
  public let goToBacking: Signal<(Project, User), NoError>
  public let goToProject: Signal<(Project, RefTag), NoError>
  public let messages: Signal<[Message], NoError>
  public let presentMessageDialog: Signal<(MessageThread, Koala.MessageDialogContext), NoError>
  public let project: Signal<Project, NoError>
  public let replyButtonIsEnabled: Signal<Bool, NoError>
  public let successfullyMarkedAsRead: Signal<(), NoError>

  public var inputs: MessagesViewModelInputs { return self }
  public var outputs: MessagesViewModelOutputs { return self }
}
