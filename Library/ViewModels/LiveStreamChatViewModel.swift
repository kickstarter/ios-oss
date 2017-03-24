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

  /// Call when the viewDidLoad.
  func viewDidLoad()

  /// Called when the user session starts.
  func userSessionStarted()
}

public protocol LiveStreamChatViewModelOutputs {
  /// Emits when the keyboard should dismiss on rotate.
  var dismissKeyboard: Signal<(), NoError> { get }

  /// Emits when chat authorization is completed with success status.
  var didConnectToChat: Signal<Bool, NoError> { get }

  /// Emits when the LoginToutViewController should be presented.
  var openLoginToutViewController: Signal<LoginIntent, NoError> { get }

  /// Emits when a live stream api error occurred.
  var notifyDelegateLiveStreamApiErrorOccurred: Signal<LiveApiError, NoError> { get }

  /// Emits chat messages for appending to the data source.
  var prependChatMessagesToDataSourceAndReload: Signal<([LiveStreamChatMessage], Bool), NoError> { get }

  /// Emits when the more menu should be presented with the LiveStreamEvent and chat visibility status.
  var presentMoreMenuViewController: Signal<(LiveStreamEvent, Bool), NoError> { get }

  /// Emits when the chat input view should be collapsed for the table view to fill the height.
  var shouldCollapseChatInputView: Signal<Bool, NoError> { get }

  /// Emits whether or not the chat table view should be hidden.
  var shouldHideChatTableView: Signal<Bool, NoError> { get }

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

    let liveStreamEvent = configData.map(second)

    let liveStreamEventFetch = Signal.merge(
      liveStreamEvent,
      Signal.combineLatest(
        liveStreamEvent,
        self.userSessionStartedProperty.signal
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
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
    }

    let firebase = liveStreamEventFetch
      .values()
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
      firebase.map { $0.chatPath },
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

    self.openLoginToutViewController = self.chatInputViewRequestedLoginProperty.signal.mapConst(
      .liveStreamChat
    )

    let chatHidden = Signal.merge(
      configData.map { _, _, chatHidden in chatHidden },
      self.didSetChatHiddenProperty.signal
    )

    self.presentMoreMenuViewController = Signal.combineLatest(
      configData.map { _, liveStreamEvent, _ in liveStreamEvent },
      chatHidden
      )
      .takeWhen(self.moreMenuButtonTappedProperty.signal)

    self.shouldHideChatTableView =
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

    self.notifyDelegateLiveStreamApiErrorOccurred = Signal.merge(
      initialChatMessages.errors(),
      chatMessages.errors(),
      sentChatMessageEvent.errors()
    )

    self.willConnectToChat = liveStreamEventFetch.map { $0.isTerminating }.filter(isFalse).ignoreValues()
    self.didConnectToChat = Signal.merge(
      liveStreamEventFetch.errors().mapConst(false),
      liveStreamEventFetch.values()
        .map { $0.firebase?.chatUserId }
        .skipNil()
        .mapConst(true)
    )

    self.shouldCollapseChatInputView = liveStreamEvent.map { $0.liveNow }.map(negate)
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

  private let userSessionStartedProperty = MutableProperty()
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }
  
  public let dismissKeyboard: Signal<(), NoError>
  public let didConnectToChat: Signal<Bool, NoError>
  public let notifyDelegateLiveStreamApiErrorOccurred: Signal<LiveApiError, NoError>
  public let openLoginToutViewController: Signal<LoginIntent, NoError>
  public let presentMoreMenuViewController: Signal<(LiveStreamEvent, Bool), NoError>
  public let prependChatMessagesToDataSourceAndReload: Signal<([LiveStreamChatMessage], Bool), NoError>
  public let shouldCollapseChatInputView: Signal<Bool, NoError>
  public let shouldHideChatTableView: Signal<Bool, NoError>
  public let willConnectToChat: Signal<(), NoError>

  public var inputs: LiveStreamChatViewModelInputs { return self }
  public var outputs: LiveStreamChatViewModelOutputs { return self }
}
