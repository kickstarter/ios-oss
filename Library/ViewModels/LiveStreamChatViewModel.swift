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

  /// Call with the desired visibility for the chat view controller.
  func didSetChatHidden(hidden: Bool)

  /// Call when the more button is tapped.
  func moreMenuButtonTapped()

  /// Call when the viewDidLoad.
  func viewDidLoad()

  /// Call with new chat messages.
  func received(chatMessages: [LiveStreamChatMessage])

  /// Called when the user session starts.
  func userSessionStarted()
}

public protocol LiveStreamChatViewModelOutputs {
  /// Emits when the chat input view should be hidden
  var chatInputViewHidden: Signal<Bool, NoError> { get }

  /// Emits with new chat user info received after authorization
  var configureChatHandlerWithUserInfo: Signal<LiveStreamChatUserInfo, NoError> { get }

  /// Emits when the keyboard should dismiss on rotate.
  var dismissKeyboard: Signal<(), NoError> { get }

  /// Emits when chat authorization is completed with success status.
  var didAuthorizeChat: Signal<Bool, NoError> { get }

  /// Emits when the LoginToutViewController should be presented.
  var openLoginToutViewController: Signal<LoginIntent, NoError> { get }

  /// Emits chat messages for appending to the data source.
  var prependChatMessagesToDataSourceAndReload: Signal<([LiveStreamChatMessage], Bool), NoError> { get }

  /// Emits when the more menu should be presented with the LiveStreamEvent and chat visibility status.
  var presentMoreMenuViewController: Signal<(LiveStreamEvent, Bool), NoError> { get }

  /// Emits whether or not the chat table view should be hidden.
  var shouldHideChatTableView: Signal<Bool, NoError> { get }

  /// Emits when the live auth token should be updated in the app environment.
  var updateLiveAuthTokenInEnvironment: Signal<String, NoError> { get }

  /// Emits when chat authorization begins.
  var willAuthorizeChat: Signal<(), NoError> { get }
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

    let shouldFetchAuthToken = Signal.merge(
      configData.ignoreValues(),
      Signal.combineLatest(configData, self.userSessionStartedProperty.signal).ignoreValues()
      )
      .filter {
        AppEnvironment.current.currentUser != nil && AppEnvironment.current.liveAuthToken == nil
    }

    let liveAuthTokenFetch = shouldFetchAuthToken.switchMap {
        AppEnvironment.current.apiService.liveAuthToken()
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    self.prependChatMessagesToDataSourceAndReload = Signal.combineLatest(
      self.receivedChatMessagesProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal,
      configData.ignoreValues()
      )
      .map(first)
      .filter { !$0.isEmpty }
      .map { chatMessages in
        (chatMessages, chatMessages.count > 25)
    }

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

    let liveStreamEventFetch = Signal.combineLatest(
      liveAuthTokenFetch
        .values()
        .map { $0.token },
      liveStreamEvent
      )
      .flatMap { token, event -> SignalProducer<Event<LiveStreamEvent, LiveApiError>, NoError> in
        AppEnvironment.current.liveStreamService
          .fetchEvent(
            eventId: event.id,
            uid: AppEnvironment.current.currentUser?.id,
            liveAuthToken: token
          )
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    self.configureChatHandlerWithUserInfo = liveStreamEventFetch
      .values()
      .map { liveStreamEvent -> LiveStreamChatUserInfo? in
        guard
          let userId = liveStreamEvent.firebase?.chatUserId,
          let name = liveStreamEvent.firebase?.chatUserName,
          let avatar = liveStreamEvent.firebase?.chatAvatarUrl,
          let token = liveStreamEvent.firebase?.token
          else { return nil }

        return LiveStreamChatUserInfo(name: name,
                                      profilePictureUrl: avatar,
                                      userId: userId,
                                      token: token)
      }
      .skipNil()

    self.didAuthorizeChat = liveAuthTokenFetch.filter { $0.isTerminating }.map { $0.error == nil }
    self.updateLiveAuthTokenInEnvironment = liveAuthTokenFetch.values().map { $0.token }
    self.willAuthorizeChat = shouldFetchAuthToken

    self.chatInputViewHidden = liveStreamEvent.map { $0.liveNow }.map(negate)
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

  private let receivedChatMessagesProperty = MutableProperty<[LiveStreamChatMessage]?>(nil)
  public func received(chatMessages: [LiveStreamChatMessage]) {
    self.receivedChatMessagesProperty.value = chatMessages
  }

  private let userSessionStartedProperty = MutableProperty()
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  public let chatInputViewHidden: Signal<Bool, NoError>
  public let configureChatHandlerWithUserInfo: Signal<LiveStreamChatUserInfo, NoError>
  public let dismissKeyboard: Signal<(), NoError>
  public let didAuthorizeChat: Signal<Bool, NoError>
  public let openLoginToutViewController: Signal<LoginIntent, NoError>
  public let presentMoreMenuViewController: Signal<(LiveStreamEvent, Bool), NoError>
  public let prependChatMessagesToDataSourceAndReload: Signal<([LiveStreamChatMessage], Bool), NoError>
  public let shouldHideChatTableView: Signal<Bool, NoError>
  public let updateLiveAuthTokenInEnvironment: Signal<String, NoError>
  public let willAuthorizeChat: Signal<(), NoError>

  public var inputs: LiveStreamChatViewModelInputs { return self }
  public var outputs: LiveStreamChatViewModelOutputs { return self }
}
