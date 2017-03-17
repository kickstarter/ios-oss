import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift
import Result

public protocol MessageThreadCellViewModelInputs {
  func configureWith(messageThread: MessageThread)
  func setSelected(_ selected: Bool)
}

public protocol MessageThreadCellViewModelOutputs {
  var date: Signal<String, NoError> { get }
  var dateAccessibilityLabel: Signal<String, NoError> { get }
  var messageBody: Signal<String, NoError> { get }
  var participantAvatarURL: Signal<URL?, NoError> { get }
  var participantName: Signal<String, NoError> { get }
  var projectName: Signal<String, NoError> { get }
  var replyIndicatorHidden: Signal<Bool, NoError> { get }
  var unreadIndicatorHidden: Signal<Bool, NoError> { get }

}

public protocol MessageThreadCellViewModelType {
  var inputs: MessageThreadCellViewModelInputs { get }
  var outputs: MessageThreadCellViewModelOutputs { get }
}

public final class MessageThreadCellViewModel: MessageThreadCellViewModelType,
  MessageThreadCellViewModelInputs, MessageThreadCellViewModelOutputs {

  public init() {
    let messageThread = self.messageThreadProperty.signal.skipNil()
    self.date = messageThread.map {
      Format.date(secondsInUTC: $0.lastMessage.createdAt, dateStyle: .short, timeStyle: .none)
    }

    self.dateAccessibilityLabel = messageThread.map {
      Format.date(secondsInUTC: $0.lastMessage.createdAt, dateStyle: .long, timeStyle: .none)
    }

    self.messageBody = messageThread.map {
      $0.lastMessage.body.replacingOccurrences(of: "\n", with: " ")
    }

    self.participantAvatarURL = messageThread.map { URL(string: $0.participant.avatar.medium) }

    self.participantName = messageThread
      .map { thread -> String in
        if thread.lastMessage.sender.id == AppEnvironment.current.currentUser?.id {
          let me = Strings.messages_me()
          return "<b>\(me)</b>, \(thread.participant.name)"
        }
        return thread.participant.name
      }

    self.projectName = messageThread.map { $0.project.name }

    self.replyIndicatorHidden = messageThread.map {
      $0.lastMessage.sender.id != AppEnvironment.current.currentUser?.id
    }

    messageThread
      .takeWhen(self.setSelectedProperty.signal.filter(isTrue))
      .observeValues(markedAsRead)

    self.unreadIndicatorHidden = Signal.merge(
      self.setSelectedProperty.signal.filter(isTrue).mapConst(true),
      messageThread.map { !hasUnreadMessages(for: $0) }
    )
  }

  fileprivate let messageThreadProperty = MutableProperty<MessageThread?>(nil)
  public func configureWith(messageThread: MessageThread) {
    self.messageThreadProperty.value = messageThread
  }
  fileprivate let setSelectedProperty = MutableProperty<Bool>(false)
  public func setSelected(_ selected: Bool) {
    self.setSelectedProperty.value = selected
  }

  public let date: Signal<String, NoError>
  public let dateAccessibilityLabel: Signal<String, NoError>
  public let messageBody: Signal<String, NoError>
  public let participantAvatarURL: Signal<URL?, NoError>
  public let participantName: Signal<String, NoError>
  public let projectName: Signal<String, NoError>
  public let replyIndicatorHidden: Signal<Bool, NoError>
  public let unreadIndicatorHidden: Signal<Bool, NoError>

  public var inputs: MessageThreadCellViewModelInputs { return self }
  public var outputs: MessageThreadCellViewModelOutputs { return self }
}

private func hasUnreadMessages(for messageThread: MessageThread) -> Bool {
  return (AppEnvironment.current.cache[cacheKey(for: messageThread)] as? Bool)
    ?? (messageThread.unreadMessagesCount > 0)
}

private func cacheKey(for messageThread: MessageThread) -> String {
  return "\(KSCache.ksr_messageThreadHasUnreadMessages)_\(messageThread.id)"
}

private func markedAsRead(for messageThread: MessageThread) {
  AppEnvironment.current.cache[cacheKey(for: messageThread)] = false
}
