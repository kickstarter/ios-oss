import KsApi
import LiveStream
import Prelude
import ReactiveSwift
import Result

public protocol LiveStreamChatViewModelType {
  var inputs: LiveStreamChatViewModelInputs { get }
  var outputs: LiveStreamChatViewModelOutputs { get }
}

public protocol LiveStreamChatViewModelInputs {
  /// Call when the chat input view requests login auth.
  func chatInputViewRequestedLogin()

  /// Call with the LiveStreamEvent and chat visibility.
  func configureWith(project: Project, liveStreamEvent: LiveStreamEvent, chatHidden: Bool)

  /// Call when the device orientation changed.
  func deviceOrientationDidChange(orientation: UIInterfaceOrientation)

  /// Call with the message that was sent.
  func didSendMessage(message: String)

  /// Call with the desired visibility for the chat view controller.
  func didSetChatHidden(hidden: Bool)

  /// Call when the more button is tapped.
  func moreMenuButtonTapped()

  /// Call when the user session changes.
  func userSessionChanged(session: LiveStreamSession)

  /// Call when the viewDidLoad.
  func viewDidLoad()
}

public protocol LiveStreamChatViewModelOutputs {
  /// Emits when the chat input view should be collapsed for the table view to fill the height.
  var collapseChatInputView: Signal<Bool, NoError> { get }

  /// Emits when the keyboard should dismiss on rotate.
  var dismissKeyboard: Signal<(), NoError> { get }

  /// Emits when chat authorization is completed with success status.
  var didConnectToChat: Signal<Bool, NoError> { get }

  /// Emits whether or not the chat table view should be hidden.
  var hideChatTableView: Signal<Bool, NoError> { get }

  /// Emits chat messages for appending to the data source.
  var prependChatMessagesToDataSourceAndReload: Signal<([LiveStreamChatMessage], Bool), NoError> { get }

  /// Emits when the LoginToutViewController should be presented.
  var presentLoginToutViewController: Signal<LoginIntent, NoError> { get }

  /// Emits when the more menu should be presented with the LiveStreamEvent and chat visibility status.
  var presentMoreMenuViewController: Signal<(LiveStreamEvent, Bool), NoError> { get }

  /// Emits when an error has occurred with an error message.
  var showErrorAlert: Signal<String, NoError> { get }

  /// Emits when chat authorization begins.
  var willConnectToChat: Signal<(), NoError> { get }
}

public final class LiveStreamChatViewModel: LiveStreamChatViewModelType, LiveStreamChatViewModelInputs,
LiveStreamChatViewModelOutputs {

  //swiftlint:disable:next function_body_length
  public init() {
    let configData = Signal.combineLatest(
      self.configData.signal.skipNil(),
      self.viewDidLoadProperty.signal
    ).map(first)

    let initialLiveStreamEvent = configData.map(second)

    let liveStreamEventFetch = Signal.merge(
      initialLiveStreamEvent,
      Signal.combineLatest(
        initialLiveStreamEvent,
        self.userSessionProperty.signal.skipNil()
        )
        .map(first)
      )
      .flatMap { liveStreamEvent -> SignalProducer<Event<LiveStreamEvent, LiveApiError>, NoError> in
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
        AppEnvironment.current.liveStreamService.chatMessageSnapshotsValue(
          withPath: path,
          limitedToLast: 500
        )
        .materialize()
      }
      .take(first: 1)

    let chatMessages = Signal.combineLatest(
      firebase.map { $0.chatPath }.take(first: 1),
      initialChatMessages
        .values()
        .map { $0.last?.date }
        .map { $0.coalesceWith(0) }
      )
      .flatMap { path, lastTimeStamp in
        AppEnvironment.current.liveStreamService.chatMessageSnapshotsAdded(
          withPath: path,
          addedSinceTimeInterval: lastTimeStamp
          )
          .materialize()
    }

    self.prependChatMessagesToDataSourceAndReload = Signal.combineLatest(
      Signal.merge(
        initialChatMessages.values().map { ($0, true) },
        chatMessages.values().map { ([$0], false) }
      ),
      configData
      )
      .map(first)

    self.presentLoginToutViewController = self.chatInputViewRequestedLoginProperty.signal
      .mapConst(.liveStreamChat)

    let chatHidden = Signal.merge(
      configData.map { _, _, chatHidden in chatHidden },
      self.didSetChatHiddenProperty.signal
    )

    self.presentMoreMenuViewController = Signal.combineLatest(
      liveStreamEvent,
      chatHidden
      )
      .takeWhen(self.moreMenuButtonTappedProperty.signal)

    self.hideChatTableView =
      Signal.merge(
        configData.map { $2 },
        self.didSetChatHiddenProperty.signal
    )

    let newChatMessage = firebase
      .takePairWhen(self.didSendMessageProperty.signal.skipNil())
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

    let sentChatMessageEvent = firebase.map { $0.chatPath }
      .takePairWhen(newChatMessage)
      .flatMap { path, message in
        AppEnvironment.current.liveStreamService.sendChatMessage(
          withPath: path,
          chatMessage: message
        )
        .materialize()
    }

    let signInWithCustomTokenEvent = Signal.merge(
      liveStreamEvent.map { $0.firebase?.token }.skipNil(),
      self.userSessionProperty.signal.skipNil()
        .map { session -> String? in
          if case let .loggedIn(token) = session { return token }
          return nil
        }
        .skipNil()
      )
      .filter { _ in AppEnvironment.current.currentUser != nil }
      .flatMap {
        AppEnvironment.current.liveStreamService.signInToFirebase(withCustomToken: $0)
          .materialize()
    }

    self.showErrorAlert = Signal.merge(
      initialChatMessages.errors(),
      chatMessages.errors(),
      sentChatMessageEvent.errors(),
      signInWithCustomTokenEvent.errors()
      )
      .map { $0.description }

    self.willConnectToChat = liveStreamEventFetch.map { $0.isTerminating }.filter(isFalse).ignoreValues()
    self.didConnectToChat = Signal.merge(
      liveStreamEventFetch.errors().mapConst(false),
      signInWithCustomTokenEvent.values().mapConst(true)
    )

    self.collapseChatInputView = liveStreamEvent.map { $0.liveNow }.map(negate).skipRepeats()
    self.dismissKeyboard = self.deviceOrientationDidChangeProperty.signal.ignoreValues()
  }

  private let chatInputViewRequestedLoginProperty = MutableProperty()
  public func chatInputViewRequestedLogin() {
    self.chatInputViewRequestedLoginProperty.value = ()
  }

  private let configData = MutableProperty<(Project, LiveStreamEvent, Bool)?>(nil)
  public func configureWith(project: Project, liveStreamEvent: LiveStreamEvent, chatHidden: Bool) {
    self.configData.value = (project, liveStreamEvent, chatHidden)
  }

  private let deviceOrientationDidChangeProperty = MutableProperty<UIInterfaceOrientation?>(nil)
  public func deviceOrientationDidChange(orientation: UIInterfaceOrientation) {
    self.deviceOrientationDidChangeProperty.value = orientation
  }

  private let didSendMessageProperty = MutableProperty<String?>(nil)
  public func didSendMessage(message: String) {
    self.didSendMessageProperty.value = message
  }

  private let didSetChatHiddenProperty = MutableProperty(false)
  public func didSetChatHidden(hidden: Bool) {
    self.didSetChatHiddenProperty.value = hidden
  }

  private let moreMenuButtonTappedProperty = MutableProperty()
  public func moreMenuButtonTapped() {
    self.moreMenuButtonTappedProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let userSessionProperty = MutableProperty<LiveStreamSession?>(nil)
  public func userSessionChanged(session: LiveStreamSession) {
    self.userSessionProperty.value = session
  }

  public let collapseChatInputView: Signal<Bool, NoError>
  public let dismissKeyboard: Signal<(), NoError>
  public let didConnectToChat: Signal<Bool, NoError>
  public let hideChatTableView: Signal<Bool, NoError>
  public let prependChatMessagesToDataSourceAndReload: Signal<([LiveStreamChatMessage], Bool), NoError>
  public let presentLoginToutViewController: Signal<LoginIntent, NoError>
  public let presentMoreMenuViewController: Signal<(LiveStreamEvent, Bool), NoError>
  public let showErrorAlert: Signal<String, NoError>
  public let willConnectToChat: Signal<(), NoError>

  public var inputs: LiveStreamChatViewModelInputs { return self }
  public var outputs: LiveStreamChatViewModelOutputs { return self }
}

extension LiveApiError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .failedToInitializeFirebase,
         .firebaseAnonymousAuthFailed,
         .firebaseCustomTokenAuthFailed:
      return localizedString(key: "We_were_unable_to_connect_to_the_live_stream_chat",
                             defaultValue: "We were unable to connect to the live stream chat.")
    case .sendChatMessageFailed:
      return localizedString(key: "Your_chat_message_wasnt_sent_successfully",
                             defaultValue: "Your chat message wasn't sent successfully.")
    case .snapshotDecodingFailed,
         .genericFailure,
         .invalidJson,
         .invalidRequest:
      return localizedString(key: "Something_went_wrong_please_try_again",
                             defaultValue: "Something went wrong, please try again.")
    }
  }
}
