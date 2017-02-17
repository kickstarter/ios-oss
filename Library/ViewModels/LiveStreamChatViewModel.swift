import LiveStream
import Prelude
import ReactiveSwift
import Result

public protocol LiveStreamChatViewModelType {
  var inputs: LiveStreamChatViewModelInputs { get }
  var outputs: LiveStreamChatViewModelOutputs { get }
}

public protocol LiveStreamChatViewModelInputs {
  /// Call when the viewDidLoad.
  func viewDidLoad()

  /// Call with new chat messages.
  func received(chatMessages: [LiveStreamChatMessage])
}

public protocol LiveStreamChatViewModelOutputs {
  /// Emits chat messages for appending to the data source.
  var appendChatMessagesToDataSource: Signal<[LiveStreamChatMessage], NoError> { get }
}

public final class LiveStreamChatViewModel: LiveStreamChatViewModelType, LiveStreamChatViewModelInputs,
LiveStreamChatViewModelOutputs {

  public init() {
    self.appendChatMessagesToDataSource = Signal.combineLatest(
      self.receivedChatMessagesProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    ).map(first)
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

  public var inputs: LiveStreamChatViewModelInputs { return self }
  public var outputs: LiveStreamChatViewModelOutputs { return self }
}
