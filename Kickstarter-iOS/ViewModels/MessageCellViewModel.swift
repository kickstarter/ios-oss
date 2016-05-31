import Library
import Models
import ReactiveCocoa
import Result

internal protocol MessageCellViewModelInputs {
  func configureWith(message message: Message)
}

internal protocol MessageCellViewModelOutputs {
  var avatarURL: Signal<NSURL?, NoError> { get }
  var name: Signal<String, NoError> { get }
  var timestamp: Signal<String, NoError> { get }
  var body: Signal<String, NoError> { get }
}

internal protocol MessageCellViewModelType {
  var inputs: MessageCellViewModelInputs { get }
  var outputs: MessageCellViewModelOutputs { get }
}

internal final class MessageCellViewModel: MessageCellViewModelType, MessageCellViewModelInputs,
MessageCellViewModelOutputs {

  internal init() {
    let message = self.messageProperty.signal.ignoreNil()

    self.avatarURL = message.map { NSURL.init(string: $0.sender.avatar.large ?? $0.sender.avatar.medium) }

    self.name = message.map { $0.sender.name }

    self.timestamp = message.map {
      Format.date(secondsInUTC: $0.createdAt, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
    }

    self.body = message.map { $0.body }
  }

  private let messageProperty = MutableProperty<Message?>(nil)
  internal func configureWith(message message: Message) {
    self.messageProperty.value = message
  }

  internal let avatarURL: Signal<NSURL?, NoError>
  internal let name: Signal<String, NoError>
  internal let timestamp: Signal<String, NoError>
  internal let body: Signal<String, NoError>

  internal var inputs: MessageCellViewModelInputs { return self }
  internal var outputs: MessageCellViewModelOutputs { return self }
}
