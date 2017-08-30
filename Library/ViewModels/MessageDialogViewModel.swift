import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol MessageDialogViewModelInputs {
  /// Call when the message text changes.
  func bodyTextChanged(_ body: String)

  /// Call when the cancel button is pressed.
  func cancelButtonPressed()

  /// Call with the backing/message-thread/project that was given to the view.
  func configureWith(messageSubject: MessageSubject, context: Koala.MessageDialogContext)

  /// Call when the post button is pressed.
  func postButtonPressed()

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol MessageDialogViewModelOutputs {
  /// Emits a boolean that determines if the keyboard is shown or not.
  var keyboardIsVisible: Signal<Bool, NoError> { get }

  /// Emits a boolean that determines if the loading view is hidden or not.
  var loadingViewIsHidden: Signal<Bool, NoError> { get }

  /// Emits the message just successfully posted.
  var notifyPresenterCommentWasPostedSuccesfully: Signal<Message, NoError> { get }

  /// Emits when the dialog should be dismissed.
  var notifyPresenterDialogWantsDismissal: Signal<(), NoError> { get }

  /// Emits a boolean that determines if the post button is enabled.
  var postButtonEnabled: Signal<Bool, NoError> { get }

  /// Emits the recipient's name.
  var recipientName: Signal<String, NoError> { get }

  /// Emits a string that should be alerted to the user.
  var showAlertMessage: Signal<String, NoError> { get }
}

public protocol MessageDialogViewModelType {
  var inputs: MessageDialogViewModelInputs { get }
  var outputs: MessageDialogViewModelOutputs { get }
}

public final class MessageDialogViewModel: MessageDialogViewModelType, MessageDialogViewModelInputs,
MessageDialogViewModelOutputs {

    public init() {
    let messageSubject = self.messageSubjectProperty.signal.skipNil()
      .takeWhen(self.viewDidLoadProperty.signal)

    let projectFromBacking = messageSubject
      .map { $0.backing }
      .skipNil()
      .flatMap {
        AppEnvironment.current.apiService.fetchProject(param: .id($0.projectId)).demoteErrors()
    }

    let project = Signal.merge(
      projectFromBacking,
      messageSubject.map { $0.messageThread?.project }.skipNil(),
      messageSubject.map { $0.project }.skipNil()
    )

    let body = self.bodyTextChangedProperty.signal.skipNil()

    let bodyIsPresent = body
      .map { !$0.trimmed().isEmpty }
      .skipRepeats()

    self.postButtonEnabled = Signal.merge(
      self.viewDidLoadProperty.signal.take(first: 1).mapConst(false),
      bodyIsPresent
    )

    let sendMessageResult = Signal.combineLatest(
      body,
      messageSubject
      )
      .takeWhen(self.postButtonPressedProperty.signal)
      .switchMap { body, messageSubject in

        AppEnvironment.current.apiService.sendMessage(body: body, toSubject: messageSubject)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
    }

    self.notifyPresenterCommentWasPostedSuccesfully = sendMessageResult.values()

    self.showAlertMessage = sendMessageResult.errors()
      .map { $0.errorMessages.first ?? Strings.messages_dialog_generic_error() }

    self.notifyPresenterDialogWantsDismissal = Signal.merge(
      self.cancelButtonPressedProperty.signal,
      self.notifyPresenterCommentWasPostedSuccesfully.ignoreValues()
    )

    self.loadingViewIsHidden = Signal.merge(
      self.postButtonPressedProperty.signal.mapConst(false),
      sendMessageResult.filter { $0.isTerminating }.mapConst(true),
      self.viewDidLoadProperty.signal.take(first: 1).mapConst(true)
    )

    self.recipientName = messageSubject
      .take(first: 1)
      .flatMap { messageSubject -> SignalProducer<String, NoError> in
        switch messageSubject {
        case let .backing(backing):
          guard let name = backing.backer?.name else { return fetchBackerName(backing: backing) }
          return .init(value: name)
        case let .messageThread(messageThread):
          return .init(value: messageThread.participant.name)
        case let .project(project):
          return .init(value: project.creator.name)
        }
    }

    self.keyboardIsVisible = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(true),
      self.notifyPresenterDialogWantsDismissal.mapConst(false)
    )

    Signal.combineLatest(project, self.contextProperty.signal.skipNil())
      .observeValues { AppEnvironment.current.koala.trackViewedMessageEditor(project: $0, context: $1) }

    Signal.combineLatest(project, self.contextProperty.signal.skipNil())
      .takeWhen(self.notifyPresenterCommentWasPostedSuccesfully)
      .observeValues { AppEnvironment.current.koala.trackMessageSent(project: $0, context: $1) }
  }

  fileprivate let bodyTextChangedProperty = MutableProperty<String?>(nil)
  public func bodyTextChanged(_ body: String) {
    self.bodyTextChangedProperty.value = body
  }
  fileprivate let cancelButtonPressedProperty = MutableProperty()
  public func cancelButtonPressed() {
    self.cancelButtonPressedProperty.value = ()
  }
  fileprivate let messageSubjectProperty = MutableProperty<MessageSubject?>(nil)
  fileprivate let contextProperty = MutableProperty<Koala.MessageDialogContext?>(nil)
  public func configureWith(messageSubject: MessageSubject,
                            context: Koala.MessageDialogContext) {
    self.messageSubjectProperty.value = messageSubject
    self.contextProperty.value = context
  }
  fileprivate let postButtonPressedProperty = MutableProperty()
  public func postButtonPressed() {
    self.postButtonPressedProperty.value = ()
  }
  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let loadingViewIsHidden: Signal<Bool, NoError>
  public let postButtonEnabled: Signal<Bool, NoError>
  public let notifyPresenterDialogWantsDismissal: Signal<(), NoError>
  public let notifyPresenterCommentWasPostedSuccesfully: Signal<Message, NoError>
  public let recipientName: Signal<String, NoError>
  public let keyboardIsVisible: Signal<Bool, NoError>
  public let showAlertMessage: Signal<String, NoError>

  public var inputs: MessageDialogViewModelInputs { return self }
  public var outputs: MessageDialogViewModelOutputs { return self }
}

func fetchBackerName(backing: Backing) -> SignalProducer<String, NoError> {
  return AppEnvironment.current.apiService.fetchUser(userId: backing.backerId)
    .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
    .demoteErrors()
    .map { $0.name }
}
