import KsApi
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol MessageThreadCellViewModelInputs {
  func configureWith(messageThread messageThread: MessageThread)
}

public protocol MessageThreadCellViewModelOutputs {
  var date: Signal<String, NoError> { get }
  var dateAccessibilityLabel: Signal<String, NoError> { get }
  var messageBody: Signal<String, NoError> { get }
  var participantAvatarURL: Signal<NSURL?, NoError> { get }
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
    let messageThread = self.messageThreadProperty.signal.ignoreNil()

    self.date = messageThread.map {
      Format.date(secondsInUTC: $0.lastMessage.createdAt, dateStyle: .ShortStyle, timeStyle: .NoStyle)
    }

    self.dateAccessibilityLabel = messageThread.map {
      Format.date(secondsInUTC: $0.lastMessage.createdAt, dateStyle: .LongStyle, timeStyle: .NoStyle)
    }

    self.messageBody = messageThread.map {
      $0.lastMessage.body.stringByReplacingOccurrencesOfString("\n", withString: " ")
    }

    self.participantAvatarURL = messageThread.map { NSURL(string: $0.participant.avatar.medium) }

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
    self.unreadIndicatorHidden = messageThread.map { $0.unreadMessagesCount == 0 }
  }

  private let messageThreadProperty = MutableProperty<MessageThread?>(nil)
  public func configureWith(messageThread messageThread: MessageThread) {
    self.messageThreadProperty.value = messageThread
  }

  public let date: Signal<String, NoError>
  public let dateAccessibilityLabel: Signal<String, NoError>
  public let messageBody: Signal<String, NoError>
  public let participantAvatarURL: Signal<NSURL?, NoError>
  public let participantName: Signal<String, NoError>
  public let projectName: Signal<String, NoError>
  public let replyIndicatorHidden: Signal<Bool, NoError>
  public let unreadIndicatorHidden: Signal<Bool, NoError>

  public var inputs: MessageThreadCellViewModelInputs { return self }
  public var outputs: MessageThreadCellViewModelOutputs { return self }
}
