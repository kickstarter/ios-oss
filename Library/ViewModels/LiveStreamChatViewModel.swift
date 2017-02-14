import LiveStream
import Prelude
import ReactiveSwift
import Result

public protocol LiveStreamChatViewModelType {
  var inputs: LiveStreamChatViewModelInputs { get }
  var outputs: LiveStreamChatViewModelOutputs { get }
}

public protocol LiveStreamChatViewModelInputs {
  func received(chatMessages: [LiveStreamChatMessage])
}

public protocol LiveStreamChatViewModelOutputs {
  var appendChatMessagesToDataSource: Signal<[LiveStreamChatMessage], NoError> { get }
}

public final class LiveStreamChatViewModel: LiveStreamChatViewModelType, LiveStreamChatViewModelInputs,
LiveStreamChatViewModelOutputs {

  init() {
    self.appendChatMessagesToDataSource = self.receivedChatMessagesProperty.signal.skipNil()
  }

  private let receivedChatMessagesProperty = MutableProperty<[LiveStreamChatMessage]?>(nil)
  public func received(chatMessages: [LiveStreamChatMessage]) {
    self.receivedChatMessagesProperty.value = chatMessages
  }

  public let appendChatMessagesToDataSource: Signal<[LiveStreamChatMessage], NoError>

  public var inputs: LiveStreamChatViewModelInputs { return self }
  public var outputs: LiveStreamChatViewModelOutputs { return self }
}
