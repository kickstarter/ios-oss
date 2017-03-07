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

  /// Call when the device's orientation will change.
  func deviceOrientationDidChange(orientation: UIInterfaceOrientation, currentIndexPaths: [IndexPath])

  /// Call when the viewDidLoad.
  func viewDidLoad()

  /// Call with new chat messages.
  func received(chatMessages: [LiveStreamChatMessage])
}

public protocol LiveStreamChatViewModelOutputs {
  /// Emits chat messages for appending to the data source.
  var appendChatMessagesToDataSource: Signal<[LiveStreamChatMessage], NoError> { get }

  /// Emits when the LoginToutViewController should be presented.
  var openLoginToutViewController: Signal<LoginIntent, NoError> { get }

  /// Emits when the view controller should reload its input views
  var reloadInputViews: Signal<(), NoError> { get }

  /// Emits the previous index paths that should remain visible on rotate.
  var scrollToIndexPaths: Signal<[IndexPath], NoError> { get }
}

public final class LiveStreamChatViewModel: LiveStreamChatViewModelType, LiveStreamChatViewModelInputs,
LiveStreamChatViewModelOutputs {

  public init() {
    self.appendChatMessagesToDataSource = Signal.combineLatest(
      self.receivedChatMessagesProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    ).map(first)

    self.scrollToIndexPaths = Signal.combineLatest(
      self.deviceOrientationDidChangeProperty.signal.skipNil().map(second),
      self.viewDidLoadProperty.signal
    ).map(first)

    self.reloadInputViews = self.deviceOrientationDidChangeProperty.signal.skipNil().ignoreValues()
    self.openLoginToutViewController = self.chatInputViewRequestedLoginProperty.signal.mapConst(
      .liveStreamChat
    )
  }

  private let chatInputViewRequestedLoginProperty = MutableProperty()
  public func chatInputViewRequestedLogin() {
    self.chatInputViewRequestedLoginProperty.value = ()
  }

  private let deviceOrientationDidChangeProperty =
    MutableProperty<(UIInterfaceOrientation, [IndexPath])?>(nil)
  public func deviceOrientationDidChange(orientation: UIInterfaceOrientation,
                                         currentIndexPaths: [IndexPath]) {
    self.deviceOrientationDidChangeProperty.value = (orientation, currentIndexPaths)
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let receivedChatMessagesProperty = MutableProperty<[LiveStreamChatMessage]?>(nil)
  public func received(chatMessages: [LiveStreamChatMessage]) {
    self.receivedChatMessagesProperty.value = chatMessages
  }

  public let appendChatMessagesToDataSource: Signal<[LiveStreamChatMessage], NoError>
  public let openLoginToutViewController: Signal<LoginIntent, NoError>
  public let reloadInputViews: Signal<(), NoError>
  public let scrollToIndexPaths: Signal<[IndexPath], NoError>

  public var inputs: LiveStreamChatViewModelInputs { return self }
  public var outputs: LiveStreamChatViewModelOutputs { return self }
}
