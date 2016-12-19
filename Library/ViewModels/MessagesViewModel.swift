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
  /// Emits a backing and project that can be used to popular the backing info header.
  var backingAndProject: Signal<(Backing, Project), NoError> { get }

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

  /// Emits when the thread has been marked as read.
  var successfullyMarkedAsRead: Signal<(), NoError> { get }
}

public protocol MessagesViewModelType {
  var inputs: MessagesViewModelInputs { get }
  var outputs: MessagesViewModelOutputs { get }
}

public final class MessagesViewModel: MessagesViewModelType, MessagesViewModelInputs,
MessagesViewModelOutputs {

  // swiftlint:disable function_body_length
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

    let messageThreadEnvelope = Signal.merge(
      backingOrThread,
      backingOrThread.takeWhen(self.messageSentProperty.signal)
      )
      .switchMap { backingOrThread -> SignalProducer<MessageThreadEnvelope, NoError> in

        switch backingOrThread {
        case let .left(backing):
          return AppEnvironment.current.apiService.fetchMessageThread(backing: backing)
            .demoteErrors()
        case let .right(thread):
          return AppEnvironment.current.apiService.fetchMessageThread(messageThreadId: thread.id)
            .demoteErrors()
        }
    }

    let participant = messageThreadEnvelope.map { $0.messageThread.participant }

    self.backingAndProject = combineLatest(configBacking, self.project, participant, currentUser)
      .switchMap { value -> SignalProducer<(Backing, Project), NoError> in
        let (backing, project, participant, currentUser) = value

        if let backing = backing {
          return SignalProducer(value: (backing, project))
        }

        let request = project.personalization.isBacking == .Some(true)
          ? AppEnvironment.current.apiService.fetchBacking(forProject: project, forUser: currentUser)
          : AppEnvironment.current.apiService.fetchBacking(forProject: project, forUser: participant)

        return request
          .map { ($0, project) }
          .demoteErrors()
    }

    self.messages = messageThreadEnvelope
      .map { $0.messages }
      .sort { $0.id > $1.id }

    self.presentMessageDialog = messageThreadEnvelope
      .map { ($0.messageThread, .messages) }
      .takeWhen(self.replyButtonPressedProperty.signal)

    self.goToBacking = combineLatest(messageThreadEnvelope, currentUser)
      .takeWhen(self.backingInfoPressedProperty.signal)
      .map { env, currentUser in
        env.messageThread.project.personalization.isBacking == .Some(true)
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

    combineLatest(project, self.viewDidLoadProperty.signal)
      .take(1)
      .observeValues { project, _ in
        AppEnvironment.current.koala.trackMessageThreadView(project: project)
    }
  }
  // swiftlint:enable function_body_length

  fileprivate let backingInfoPressedProperty = MutableProperty()
  public func backingInfoPressed() {
    self.backingInfoPressedProperty.value = ()
  }
  fileprivate let configData = MutableProperty<Either<MessageThread, (project: Project, backing: Backing)>?>(nil)
  public func configureWith(data: Either<MessageThread, (project: Project, backing: Backing)>) {
    self.configData.value = data
  }

  fileprivate let messageSentProperty = MutableProperty<Message?>(nil)
  public func messageSent(_ message: Message) {
    self.messageSentProperty.value = message
  }
  fileprivate let projectBannerTappedProperty = MutableProperty()
  public func projectBannerTapped() {
    self.projectBannerTappedProperty.value = ()
  }
  fileprivate let replyButtonPressedProperty = MutableProperty()
  public func replyButtonPressed() {
    self.replyButtonPressedProperty.value = ()
  }
  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let backingAndProject: Signal<(Backing, Project), NoError>
  public let goToBacking: Signal<(Project, User), NoError>
  public let goToProject: Signal<(Project, RefTag), NoError>
  public let messages: Signal<[Message], NoError>
  public let presentMessageDialog: Signal<(MessageThread, Koala.MessageDialogContext), NoError>
  public let project: Signal<Project, NoError>
  public let successfullyMarkedAsRead: Signal<(), NoError>

  public var inputs: MessagesViewModelInputs { return self }
  public var outputs: MessagesViewModelOutputs { return self }
}
