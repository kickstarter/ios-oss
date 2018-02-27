import KsApi
import LiveStream
import Prelude
import ReactiveSwift
import Result

private let maxMessageLength = 140

public protocol LiveStreamChatViewModelType {
  var inputs: LiveStreamChatViewModelInputs { get }
  var outputs: LiveStreamChatViewModelOutputs { get }
}

public protocol LiveStreamChatViewModelInputs {
  /// Call with the LiveStreamEvent and chat visibility.
  func configureWith(project: Project, liveStreamEvent: LiveStreamEvent)

  /// Call when the device orientation changed.
  func deviceOrientationDidChange(orientation: UIInterfaceOrientation)

  /// Call when send button was tapped
  func sendButtonTapped()

  /// Call when the text field should begin editing
  func textFieldShouldBeginEditing() -> Bool

  /// Call with new value from the input field
  func textDidChange(toText text: String?)

  /// Call when the user session started.
  func userSessionStarted()

  /// Call when the viewDidLoad.
  func viewDidLoad()
}

public protocol LiveStreamChatViewModelOutputs {
  /// Emits when the keyboard should dismiss.
  var clearTextFieldAndResignFirstResponder: Signal<(), NoError> { get }

  /// Emits when the chat input view should be collapsed for the table view to fill the height.
  var collapseChatInputView: Signal<Bool, NoError> { get }

  /// Emits when the keyboard should dismiss on rotate.
  var dismissKeyboard: Signal<(), NoError> { get }

  /// Emits the remaining message length of the chat input text field.
  var chatInputViewMessageLengthCountLabelText: Signal<String, NoError> { get }

  /// Emits the text color for the message length count label.
  var chatInputViewMessageLengthCountLabelTextColor: Signal<UIColor, NoError> { get }

  /// Emits the placeholder text
  var chatInputViewPlaceholderText: Signal<NSAttributedString, NoError> { get }

  /// Emits chat messages for appending to the data source.
  var prependChatMessagesToDataSourceAndReload: Signal<([LiveStreamChatMessage], Bool), NoError> { get }

  /// Emits when the LoginToutViewController should be presented.
  var presentLoginToutViewController: Signal<LoginIntent, NoError> { get }

  /// Emits when the send button should be hidden
  var sendButtonEnabled: Signal<Bool, NoError> { get }

  /// Emits when an error has occurred with an error message.
  var showErrorAlert: Signal<String, NoError> { get }
}

public final class LiveStreamChatViewModel: LiveStreamChatViewModelType, LiveStreamChatViewModelInputs,
LiveStreamChatViewModelOutputs {

  public init() {
    let configData = Signal.combineLatest(
      self.configData.signal.skipNil(),
      self.viewDidLoadProperty.signal
    ).map(first)

    let project = configData.map(first)
    let initialLiveStreamEvent = configData.map(second)

    let liveStreamEventFetch = Signal.merge(
      initialLiveStreamEvent,
      initialLiveStreamEvent
        .takeWhen(self.userSessionStartedProperty.signal)
      )
      .flatMap { liveStreamEvent in
        AppEnvironment.current.liveStreamService
          .fetchEvent(
            eventId: liveStreamEvent.id,
            uid: AppEnvironment.current.currentUser?.id,
            liveAuthToken: AppEnvironment.current.currentUser?.liveAuthToken
          )
          .prefix(SignalProducer(value: liveStreamEvent))
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
    }

    let liveStreamEvent = liveStreamEventFetch.values()

    let firebase = liveStreamEvent
      .map { $0.firebase }
      .skipNil()

    let initialChatMessages = firebase
      .map { $0.chatPath }
      .flatMap { path in
        AppEnvironment.current.liveStreamService.initialChatMessages(
          withPath: path,
          limitedToLast: 500
        )
        .materialize()
      }
      .take(first: 1)

    let chatMessages = Signal.combineLatest(
      firebase.map { $0.chatPath }.take(first: 1),
      initialChatMessages.values().map { $0.last?.date ?? 0 }
      )
      .flatMap { path, lastTimeStamp in
        AppEnvironment.current.liveStreamService.chatMessagesAdded(
          withPath: path,
          addedSince: lastTimeStamp
          )
          .materialize()
    }

    self.prependChatMessagesToDataSourceAndReload = Signal.merge(
      initialChatMessages.values().map { ($0, true) },
      chatMessages.values().map { ([$0], false) }
    )

    self.presentLoginToutViewController = self.textFieldShouldBeginEditingProperty.signal
      .filter { AppEnvironment.current.currentUser == nil }
      .mapConst(.liveStreamChat)

    let signInWithCustomTokenEvent = firebase.map { $0.token }.skipNil()
      .flatMap {
        AppEnvironment.current.liveStreamService.signInToFirebase(withCustomToken: $0)
          .materialize()
    }

    self.collapseChatInputView = liveStreamEvent.map { !$0.liveNow }.skipRepeats()
    self.dismissKeyboard = self.deviceOrientationDidChangeProperty.signal.skipNil()
      .filter { $0.isLandscape }
      .ignoreValues()

    let textIsEmpty = Signal.merge(
      self.textProperty.signal.filter { $0 == nil }.mapConst(true),
      self.textProperty.signal.skipNil().map(isWhitespacesAndNewlines),
      self.sendButtonTappedProperty.signal.mapConst(true)
    )

    self.clearTextFieldAndResignFirstResponder = self.textProperty.signal.skipNil()
      .takeWhen(self.sendButtonTappedProperty.signal)
      .ignoreValues()

    let wantsToSendChat = self.textProperty.signal.skipNil()
      .filter { !isWhitespacesAndNewlines($0) }
      .takeWhen(self.sendButtonTappedProperty.signal)
      .map { $0.trimmed() }

    let newChatMessage = firebase
      .takePairWhen(wantsToSendChat)
      .map { firebase, message -> NewLiveStreamChatMessage? in
        guard
          let userId = firebase.chatUserId,
          let name = firebase.chatUserName,
          let avatar = firebase.chatAvatarUrl
          else { return nil }

        return NewLiveStreamChatMessage(
          message: message,
          name: name,
          profilePic: avatar,
          userId: userId
        )
      }
      .skipNil()

    let sentChatMessageEvent = firebase
      .map { $0.chatPostPath.coalesceWith($0.chatPath) }
      .takePairWhen(newChatMessage)
      .flatMap { path, message in
        AppEnvironment.current.liveStreamService.sendChatMessage(withPath: path, chatMessage: message)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
    }

    Signal.combineLatest(project, liveStreamEvent)
      .takeWhen(sentChatMessageEvent.values())
      .observeValues { project, liveStreamEvent in
        AppEnvironment.current.koala.trackLiveStreamChatSentMessage(project: project,
                                                                    liveStreamEvent: liveStreamEvent)
    }

    self.chatInputViewPlaceholderText = self.viewDidLoadProperty.signal
      .map {
        NSAttributedString(
          string: Strings.Say_something_kind(),
          attributes: [
            NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.8),
            NSAttributedStringKey.font: UIFont.ksr_body(size: 14)
          ]
        )
    }

    self.textFieldShouldBeginEditingReturnValueProperty <~ self.textFieldShouldBeginEditingProperty.map {
      return AppEnvironment.current.currentUser != nil
    }

    self.showErrorAlert = Signal.merge(
      initialChatMessages.errors(),
      sentChatMessageEvent.errors(),
      signInWithCustomTokenEvent.errors()
      )
      .map {
        switch $0 {
        case .failedToInitializeFirebase,
             .firebaseAnonymousAuthFailed,
             .firebaseCustomTokenAuthFailed:
          return Strings.We_were_unable_to_connect_to_the_live_stream_chat()
        case .sendChatMessageFailed:
          return Strings.Your_chat_message_wasnt_sent_successfully()
        case .snapshotDecodingFailed,
             .chatMessageDecodingFailed,
             .genericFailure,
             .invalidJson,
             .invalidRequest:
          return Strings.Something_went_wrong_please_try_again()
        }
    }

    let text = Signal.merge(
      self.textProperty.signal,
      self.viewDidLoadProperty.signal.mapConst("")
      )
      .map { $0.coalesceWith("") }

    let maxLengthExceeded = text.map { $0.count > maxMessageLength }

    self.chatInputViewMessageLengthCountLabelText = text
      .map { "\(maxMessageLength - $0.count)" }

    self.sendButtonEnabled = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(false),
      Signal.combineLatest(textIsEmpty.map(negate), maxLengthExceeded.map(negate)).map { $0 && $1 }
    ).skipRepeats()

    self.chatInputViewMessageLengthCountLabelTextColor = maxLengthExceeded
      .map {
        $0 ? .ksr_red_400 : UIColor.white.withAlphaComponent(0.8)
    }.skipRepeats()
  }

  private let configData = MutableProperty<(Project, LiveStreamEvent)?>(nil)
  public func configureWith(project: Project, liveStreamEvent: LiveStreamEvent) {
    self.configData.value = (project, liveStreamEvent)
  }

  private let deviceOrientationDidChangeProperty = MutableProperty<UIInterfaceOrientation?>(nil)
  public func deviceOrientationDidChange(orientation: UIInterfaceOrientation) {
    self.deviceOrientationDidChangeProperty.value = orientation
  }

  private let sendButtonTappedProperty = MutableProperty(())
  public func sendButtonTapped() {
    self.sendButtonTappedProperty.value = ()
  }

  private let textFieldShouldBeginEditingProperty = MutableProperty(())
  private let textFieldShouldBeginEditingReturnValueProperty = MutableProperty<Bool>(false)
  public func textFieldShouldBeginEditing() -> Bool {
    self.textFieldShouldBeginEditingProperty.value = ()
    return self.textFieldShouldBeginEditingReturnValueProperty.value
  }

  private let textProperty = MutableProperty<String?>(nil)
  public func textDidChange(toText text: String?) {
    self.textProperty.value = text
  }

  private let userSessionStartedProperty = MutableProperty(())
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let clearTextFieldAndResignFirstResponder: Signal<(), NoError>
  public let collapseChatInputView: Signal<Bool, NoError>
  public let dismissKeyboard: Signal<(), NoError>
  public let chatInputViewMessageLengthCountLabelText: Signal<String, NoError>
  public let chatInputViewMessageLengthCountLabelTextColor: Signal<UIColor, NoError>
  public let chatInputViewPlaceholderText: Signal<NSAttributedString, NoError>
  public let prependChatMessagesToDataSourceAndReload: Signal<([LiveStreamChatMessage], Bool), NoError>
  public let presentLoginToutViewController: Signal<LoginIntent, NoError>
  public let sendButtonEnabled: Signal<Bool, NoError>
  public let showErrorAlert: Signal<String, NoError>

  public var inputs: LiveStreamChatViewModelInputs { return self }
  public var outputs: LiveStreamChatViewModelOutputs { return self }
}
