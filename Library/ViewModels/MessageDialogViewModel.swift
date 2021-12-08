import KsApi
import Prelude
import ReactiveSwift

public protocol MessageDialogViewModelInputs {
  /// Call when the message text changes.
  func bodyTextChanged(_ body: String)

  /// Call when the cancel button is pressed.
  func cancelButtonPressed()

  /// Call with the backing/message-thread/project that was given to the view.
  func configureWith(messageSubject: MessageSubject, context: KSRAnalytics.MessageDialogContext)

  /// Call when the post button is pressed.
  func postButtonPressed()

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol MessageDialogViewModelOutputs {
  /// Emits a boolean that determines if the keyboard is shown or not.
  var keyboardIsVisible: Signal<Bool, Never> { get }

  /// Emits a boolean that determines if the loading view is hidden or not.
  var loadingViewIsHidden: Signal<Bool, Never> { get }

  /// Emits the message just successfully posted.
  var notifyPresenterCommentWasPostedSuccesfully: Signal<Message, Never> { get }

  /// Emits when the dialog should be dismissed.
  var notifyPresenterDialogWantsDismissal: Signal<(), Never> { get }

  /// Emits a boolean that determines if the post button is enabled.
  var postButtonEnabled: Signal<Bool, Never> { get }

  /// Emits the recipient's name.
  var recipientName: Signal<String, Never> { get }

  /// Emits a string that should be alerted to the user.
  var showAlertMessage: Signal<String, Never> { get }
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
      .flatMap { messageSubject -> SignalProducer<String, Never> in
        switch messageSubject {
        case let .backing(backing):
          guard let name = backing.backer?.name else { return fetchBackerName(backing: backing) }
          return .init(value: name)
        case let .messageThread(messageThread):
          return .init(value: messageThread.participant.name)
        case let .project(project):
          return .init(value: project.name)
        }
      }

    self.keyboardIsVisible = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(true),
      self.notifyPresenterDialogWantsDismissal.mapConst(false)
    )
  }

  fileprivate let bodyTextChangedProperty = MutableProperty<String?>(nil)
  public func bodyTextChanged(_ body: String) {
    self.bodyTextChangedProperty.value = body
  }

  fileprivate let cancelButtonPressedProperty = MutableProperty(())
  public func cancelButtonPressed() {
    self.cancelButtonPressedProperty.value = ()
  }

  fileprivate let messageSubjectProperty = MutableProperty<MessageSubject?>(nil)
  fileprivate let contextProperty = MutableProperty<KSRAnalytics.MessageDialogContext?>(nil)
  public func configureWith(
    messageSubject: MessageSubject,
    context _: KSRAnalytics.MessageDialogContext
  ) {
    self.messageSubjectProperty.value = messageSubject
  }

  fileprivate let postButtonPressedProperty = MutableProperty(())
  public func postButtonPressed() {
    self.postButtonPressedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let loadingViewIsHidden: Signal<Bool, Never>
  public let postButtonEnabled: Signal<Bool, Never>
  public let notifyPresenterDialogWantsDismissal: Signal<(), Never>
  public let notifyPresenterCommentWasPostedSuccesfully: Signal<Message, Never>
  public let recipientName: Signal<String, Never>
  public let keyboardIsVisible: Signal<Bool, Never>
  public let showAlertMessage: Signal<String, Never>

  public var inputs: MessageDialogViewModelInputs { return self }
  public var outputs: MessageDialogViewModelOutputs { return self }
}

func fetchBackerName(backing: Backing) -> SignalProducer<String, Never> {
  return AppEnvironment.current.apiService.fetchUser(userId: backing.backerId)
    .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
    .demoteErrors()
    .map { $0.name }
}
