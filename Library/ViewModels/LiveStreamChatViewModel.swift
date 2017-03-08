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

  /// Call with the LiveStreamEvent and chat visibility
  func configureWith(project: Project, liveStreamEvent: LiveStreamEvent, chatHidden: Bool)

  /// Call when the device's orientation will change.
  func deviceOrientationDidChange(orientation: UIInterfaceOrientation, currentIndexPaths: [IndexPath])

  /// Call with the desired visibility for the chat view controller
  func didSetChatHidden(hidden: Bool)

  /// Call when the more button is tapped.
  func moreMenuButtonTapped()

  /// Call when the viewDidLoad.
  func viewDidLoad()

  /// Call with new chat messages.
  func received(chatMessages: [LiveStreamChatMessage])
}

public protocol LiveStreamChatViewModelOutputs {
  /// Emits when the LoginToutViewController should be presented.
  var openLoginToutViewController: Signal<LoginIntent, NoError> { get }

  /// Emits chat messages for appending to the data source.
  var prependChatMessagesToDataSource: Signal<[LiveStreamChatMessage], NoError> { get }

  /// Emits when the more menu should be presented with the LiveStreamEvent and chat visibility status
  var presentMoreMenuViewController: Signal<(LiveStreamEvent, Bool), NoError> { get }

  /// Emits the previous index paths that should remain visible on rotate.
  var scrollToIndexPaths: Signal<[IndexPath], NoError> { get }

  /// Emits whether or not the chat table view should be hidden
  var shouldHideChatTableView: Signal<Bool, NoError> { get }
}

public final class LiveStreamChatViewModel: LiveStreamChatViewModelType, LiveStreamChatViewModelInputs,
LiveStreamChatViewModelOutputs {

  public init() {
    let configData = Signal.combineLatest(
      self.configData.signal.skipNil(),
      self.viewDidLoadProperty.signal
    ).map(first)

    self.prependChatMessagesToDataSource = Signal.combineLatest(
      self.receivedChatMessagesProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    ).map(first)

    self.scrollToIndexPaths = Signal.combineLatest(
      self.deviceOrientationDidChangeProperty.signal.skipNil().map(second),
      self.viewDidLoadProperty.signal
    ).map(first)

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

    self.shouldHideChatTableView = self.didSetChatHiddenProperty.signal
  }

  private let chatInputViewRequestedLoginProperty = MutableProperty()
  public func chatInputViewRequestedLogin() {
    self.chatInputViewRequestedLoginProperty.value = ()
  }

  private let configData = MutableProperty<(Project, LiveStreamEvent, Bool)?>(nil)
  public func configureWith(project: Project, liveStreamEvent: LiveStreamEvent, chatHidden: Bool) {
    self.configData.value = (project, liveStreamEvent, chatHidden)
  }

  private let deviceOrientationDidChangeProperty =
    MutableProperty<(UIInterfaceOrientation, [IndexPath])?>(nil)
  public func deviceOrientationDidChange(orientation: UIInterfaceOrientation,
                                         currentIndexPaths: [IndexPath]) {
    self.deviceOrientationDidChangeProperty.value = (orientation, currentIndexPaths)
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

  public let openLoginToutViewController: Signal<LoginIntent, NoError>
  public let presentMoreMenuViewController: Signal<(LiveStreamEvent, Bool), NoError>
  public let prependChatMessagesToDataSource: Signal<[LiveStreamChatMessage], NoError>
  public let scrollToIndexPaths: Signal<[IndexPath], NoError>
  public let shouldHideChatTableView: Signal<Bool, NoError>

  public var inputs: LiveStreamChatViewModelInputs { return self }
  public var outputs: LiveStreamChatViewModelOutputs { return self }
}
