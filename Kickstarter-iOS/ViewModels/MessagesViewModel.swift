import KsApi
import Library
import Models
import Prelude
import ReactiveCocoa
import Result

internal protocol MessagesViewModelInputs {
  /// Call when the backing button is pressed.
  func backingInfoPressed()

  /// Configures the view model with either a message thread or a project and a backing.
  func configureWith(data data: Either<MessageThread, (project: Project, backing: Backing)>)

  /// Call when the message dialog has told us that a message was successfully posted.
  func messageSent(message: Message)

  /// Call when the project banner is tapped.
  func projectBannerTapped()

  /// Call when the reply button is pressed.
  func replyButtonPressed()

  /// Call when the view loads.
  func viewDidLoad()
}

internal protocol MessagesViewModelOutputs {
  /// Emits a backing and project that can be used to popular the backing info header.
  var backingAndProject: Signal<(Backing, Project), NoError> { get }

  /// Emits when we should go to the backing screen.
  var goToBacking: Signal<(Backing, Project), NoError> { get }

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

internal protocol MessagesViewModelType {
  var inputs: MessagesViewModelInputs { get }
  var outputs: MessagesViewModelOutputs { get }
}

internal final class MessagesViewModel: MessagesViewModelType, MessagesViewModelInputs,
MessagesViewModelOutputs {

  // swiftlint:disable function_body_length
  init() {
    let configData = self.configData.signal.ignoreNil()
      .takeWhen(self.viewDidLoadProperty.signal)

    let configBacking = configData.map { $0.right?.backing }

    let configThread = configData.map { $0.left }
      .ignoreNil()

    let currentUser = self.viewDidLoadProperty.signal
      .map { AppEnvironment.current.currentUser }
      .ignoreNil()

    self.project = configData.map { $0.left?.project ?? $0.right?.project }
      .ignoreNil()

    self.backingAndProject = combineLatest(configBacking, self.project, currentUser)
      .switchMap { (backing, project, user) -> SignalProducer<(Backing, Project), NoError> in
        if let backing = backing {
          return SignalProducer(value: (backing, project))
        }
        return AppEnvironment.current.apiService.fetchBacking(forProject: project, forUser: user)
          .map { ($0, project) }
          .demoteErrors()
    }

    let backingOrThread = Signal.merge(
      configBacking.ignoreNil().map(Either.left),
      configThread.map(Either.right)
    )

    let messageThreadEnvelope = Signal.merge(
      backingOrThread,
      backingOrThread.takeWhen(self.messageSentProperty.signal)
      )
      .switchMap { backingOrThread in
        backingOrThread.ifLeft(AppEnvironment.current.apiService.fetchMessageThread(backing:),
          ifRight: AppEnvironment.current.apiService.fetchMessageThread(messageThread:))
            .demoteErrors()
    }

    self.messages = messageThreadEnvelope
      .map { $0.messages }
      .sort { $0.id > $1.id }

    self.presentMessageDialog = messageThreadEnvelope
      .map { ($0.messageThread, .messages) }
      .takeWhen(self.replyButtonPressedProperty.signal)

    self.goToBacking = self.backingAndProject
      .takeWhen(self.backingInfoPressedProperty.signal)

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
      .observeNext { project, _ in
        AppEnvironment.current.koala.trackMessageThreadView(project: project)
    }
  }
  // swiftlint:enable function_body_length

  private let backingInfoPressedProperty = MutableProperty()
  internal func backingInfoPressed() {
    self.backingInfoPressedProperty.value = ()
  }
  private let configData = MutableProperty<Either<MessageThread, (project: Project, backing: Backing)>?>(nil)
  internal func configureWith(data data: Either<MessageThread, (project: Project, backing: Backing)>) {
    self.configData.value = data
  }
  private let messageSentProperty = MutableProperty<Message?>(nil)
  internal func messageSent(message: Message) {
    self.messageSentProperty.value = message
  }
  private let projectBannerTappedProperty = MutableProperty()
  internal func projectBannerTapped() {
    self.projectBannerTappedProperty.value = ()
  }
  private let replyButtonPressedProperty = MutableProperty()
  internal func replyButtonPressed() {
    self.replyButtonPressedProperty.value = ()
  }
  private let viewDidLoadProperty = MutableProperty()
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  internal let backingAndProject: Signal<(Backing, Project), NoError>
  internal let goToBacking: Signal<(Backing, Project), NoError>
  internal let goToProject: Signal<(Project, RefTag), NoError>
  internal let messages: Signal<[Message], NoError>
  internal let presentMessageDialog: Signal<(MessageThread, Koala.MessageDialogContext), NoError>
  internal let project: Signal<Project, NoError>
  internal let successfullyMarkedAsRead: Signal<(), NoError>

  internal var inputs: MessagesViewModelInputs { return self }
  internal var outputs: MessagesViewModelOutputs { return self }
}
