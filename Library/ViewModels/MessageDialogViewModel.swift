import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol MessageDialogViewModelInputs {
  /// Call when the message text changes.
  func bodyTextChanged(body: String)

  /// Call when the cancel button is pressed.
  func cancelButtonPressed()

  /// Call with the message thread provided to the view.
  func configureWith(messageThread messageThread: MessageThread, context: Koala.MessageDialogContext)

  /// Call with the project provided to the view.
  func configureWith(project project: Project, context: Koala.MessageDialogContext)

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

  // swiftlint:disable function_body_length
  public init() {
    let projectConfig = self.projectConfigProperty.signal.ignoreNil()
    let messageThreadConfig = self.messageThreadConfig.signal.ignoreNil()

    let projectOrMessageThread = Signal.merge(
      projectConfig.map(first).map(Either.left),
      messageThreadConfig.map(first).map(Either.right)
      )
      .takeWhen(self.viewDidLoadProperty.signal)

    let context = Signal.merge(
      projectConfig.map(second),
      messageThreadConfig.map(second)
    )

    let project = Signal.merge(
      projectConfig.map(first),
      messageThreadConfig.map(first).map { $0.project }
    )

    let body = self.bodyTextChangedProperty.signal.ignoreNil()

    let bodyIsPresent = body
      .map { !$0.trimmed().isEmpty }
      .skipRepeats()

    self.postButtonEnabled = Signal.merge(
      self.viewDidLoadProperty.signal.take(1).mapConst(false),
      bodyIsPresent
    )

    let sendMessageResult = combineLatest(
      body,
      projectOrMessageThread
      )
      .takeWhen(self.postButtonPressedProperty.signal)
      .switchMap { body, projectOrMessageThread in

        projectOrMessageThread
          .ifLeft({
            AppEnvironment.current.apiService.sendMessage(body: body, toCreatorOfProject: $0)
            },
            ifRight: {
              AppEnvironment.current.apiService.sendMessage(body: body, toThread: $0)
          })
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .materialize()
    }

    self.notifyPresenterCommentWasPostedSuccesfully = sendMessageResult.values()

    self.showAlertMessage = sendMessageResult.errors()
      .map {
        $0.errorMessages.first ??
          localizedString(key: "messages.dialog.generic_error",
            defaultValue: "Sorry, your message could not be posted.")
    }

    self.notifyPresenterDialogWantsDismissal = Signal.merge(
      self.cancelButtonPressedProperty.signal,
      self.notifyPresenterCommentWasPostedSuccesfully.ignoreValues()
    )

    self.loadingViewIsHidden = Signal.merge(
      self.postButtonPressedProperty.signal.mapConst(false),
      sendMessageResult.filter { $0.isTerminating }.mapConst(true),
      self.viewDidLoadProperty.signal.take(1).mapConst(true)
    )

    self.recipientName = projectOrMessageThread
      .take(1)
      .map {
        $0.ifLeft({ $0.creator.name }, ifRight: { $0.participant.name })
    }

    self.keyboardIsVisible = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(true),
      self.notifyPresenterDialogWantsDismissal.mapConst(false)
    )

    combineLatest(project, context)
      .takeWhen(self.notifyPresenterCommentWasPostedSuccesfully)
      .observeNext { project, context in
        AppEnvironment.current.koala.trackMessageSent(project: project, context: context)
    }
  }
  // swiftlint:enable function_body_length

  private let bodyTextChangedProperty = MutableProperty<String?>(nil)
  public func bodyTextChanged(body: String) {
    self.bodyTextChangedProperty.value = body
  }
  private let cancelButtonPressedProperty = MutableProperty()
  public func cancelButtonPressed() {
    self.cancelButtonPressedProperty.value = ()
  }
  private let messageThreadConfig = MutableProperty<(MessageThread, Koala.MessageDialogContext)?>(nil)
  public func configureWith(messageThread messageThread: MessageThread,
                                            context: Koala.MessageDialogContext) {
    self.messageThreadConfig.value = (messageThread, context)
  }
  private let projectConfigProperty = MutableProperty<(Project, Koala.MessageDialogContext)?>(nil)
  public func configureWith(project project: Project, context: Koala.MessageDialogContext) {
    self.projectConfigProperty.value = (project, context)
  }
  private let postButtonPressedProperty = MutableProperty()
  public func postButtonPressed() {
    self.postButtonPressedProperty.value = ()
  }
  private let viewDidLoadProperty = MutableProperty()
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
