import KsApi
import ReactiveSwift
import Result

public protocol MessageCellViewModelInputs {
  func configureWith(message: Message)
}

public protocol MessageCellViewModelOutputs {
  var avatarURL: Signal<NSURL?, NoError> { get }
  var name: Signal<String, NoError> { get }
  var timestamp: Signal<String, NoError> { get }
  var timestampAccessibilityLabel: Signal<String, NoError> { get }
  var body: Signal<String, NoError> { get }
}

public protocol MessageCellViewModelType {
  var inputs: MessageCellViewModelInputs { get }
  var outputs: MessageCellViewModelOutputs { get }
}

public final class MessageCellViewModel: MessageCellViewModelType, MessageCellViewModelInputs,
MessageCellViewModelOutputs {

  public init() {
    let message = self.messageProperty.signal.skipNil()

    self.avatarURL = message.map { NSURL.init(string: $0.sender.avatar.large ?? $0.sender.avatar.medium) }

    self.name = message.map { $0.sender.name }

    self.timestamp = message.map {
      Format.date(secondsInUTC: $0.createdAt, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
    }

    self.timestampAccessibilityLabel = message.map {
      Format.date(secondsInUTC: $0.createdAt, dateStyle: .LongStyle, timeStyle: .ShortStyle)
    }

    self.body = message.map { $0.body }
  }

  fileprivate let messageProperty = MutableProperty<Message?>(nil)
  public func configureWith(message: Message) {
    self.messageProperty.value = message
  }

  public let avatarURL: Signal<NSURL?, NoError>
  public let name: Signal<String, NoError>
  public let timestamp: Signal<String, NoError>
  public var timestampAccessibilityLabel: Signal<String, NoError>
  public let body: Signal<String, NoError>

  public var inputs: MessageCellViewModelInputs { return self }
  public var outputs: MessageCellViewModelOutputs { return self }
}
