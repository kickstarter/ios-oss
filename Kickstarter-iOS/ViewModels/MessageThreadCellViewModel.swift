import Library
import Models
import ReactiveCocoa
import ReactiveExtensions
import Result

internal protocol MessageThreadCellViewModelInputs {
  func configureWith(messageThread messageThread: MessageThread)
}

internal protocol MessageThreadCellViewModelOutputs {
  var date: Signal<String, NoError> { get }
  var messageBody: Signal<String, NoError> { get }
  var participantAvatarURL: Signal<NSURL?, NoError> { get }
  var participantName: Signal<String, NoError> { get }
  var projectName: Signal<String, NoError> { get }
  var replyIndicatorHidden: Signal<Bool, NoError> { get }
  var unreadIndicatorHidden: Signal<Bool, NoError> { get }
}

internal protocol MessageThreadCellViewModelType {
  var inputs: MessageThreadCellViewModelInputs { get }
  var outputs: MessageThreadCellViewModelOutputs { get }
}

internal final class MessageThreadCellViewModel: MessageThreadCellViewModelType,
  MessageThreadCellViewModelInputs, MessageThreadCellViewModelOutputs {

  init() {
    let messageThread = self.messageThreadProperty.signal.ignoreNil()

    self.date = messageThread.map {
      Format.date(secondsInUTC: $0.lastMessage.createdAt, dateStyle: .ShortStyle, timeStyle: .NoStyle)
    }

    self.messageBody = messageThread.map {
      $0.lastMessage.body.stringByReplacingOccurrencesOfString("\n", withString: " ")
    }

    self.participantAvatarURL = messageThread.map { NSURL(string: $0.participant.avatar.medium) }

    self.participantName = messageThread
      .map { thread -> String in
        if thread.lastMessage.sender.id == AppEnvironment.current.currentUser?.id {
          let me = localizedString(key: "messages.me", defaultValue: "Me")
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
  internal func configureWith(messageThread messageThread: MessageThread) {
    self.messageThreadProperty.value = messageThread
  }

  internal let date: Signal<String, NoError>
  internal let messageBody: Signal<String, NoError>
  internal let participantAvatarURL: Signal<NSURL?, NoError>
  internal let participantName: Signal<String, NoError>
  internal let projectName: Signal<String, NoError>
  internal let replyIndicatorHidden: Signal<Bool, NoError>
  internal let unreadIndicatorHidden: Signal<Bool, NoError>

  internal var inputs: MessageThreadCellViewModelInputs { return self }
  internal var outputs: MessageThreadCellViewModelOutputs { return self }
}
