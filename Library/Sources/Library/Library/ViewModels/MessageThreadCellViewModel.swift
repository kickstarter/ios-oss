import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol MessageThreadCellViewModelInputs {
  func configureWith(messageThread: MessageThread)
  func setSelected(_ selected: Bool)
}

public protocol MessageThreadCellViewModelOutputs {
  var date: Signal<String, Never> { get }
  var dateAccessibilityLabel: Signal<String, Never> { get }
  var messageBody: Signal<String, Never> { get }
  var participantAvatarURL: Signal<URL?, Never> { get }
  var participantName: Signal<String, Never> { get }
  var projectName: Signal<String, Never> { get }
  var replyIndicatorHidden: Signal<Bool, Never> { get }
  var unreadIndicatorHidden: Signal<Bool, Never> { get }
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

  public let date: Signal<String, Never>
  public let dateAccessibilityLabel: Signal<String, Never>
  public let messageBody: Signal<String, Never>
  public let participantAvatarURL: Signal<URL?, Never>
  public let participantName: Signal<String, Never>
  public let projectName: Signal<String, Never>
  public let replyIndicatorHidden: Signal<Bool, Never>
  public let unreadIndicatorHidden: Signal<Bool, Never>

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
