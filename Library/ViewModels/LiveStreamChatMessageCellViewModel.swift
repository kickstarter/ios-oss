import LiveStream
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol LiveStreamChatMessageCellViewModelType {
  var inputs: LiveStreamChatMessageCellViewModelInputs { get }
  var outputs: LiveStreamChatMessageCellViewModelOutputs { get }
}

public protocol LiveStreamChatMessageCellViewModelInputs {
  /// Call to configure with the chat message.
  func configureWith(chatMessage: LiveStreamChatMessage)

  /// Call with the respective creator's user ID
  func setCreatorUserId(creatorUserId: Int)
}

public protocol LiveStreamChatMessageCellViewModelOutputs {
  /// Emits the avatar image url
  var avatarImageUrl: Signal<URL?, NoError> { get }

  /// Emits when creator-related views should be hidden
  var creatorViewsHidden: Signal<Bool, NoError> { get }

  /// Emits the message
  var message: Signal<String, NoError> { get }

  /// Emits the sender's name
  var name: Signal<String, NoError> { get }
}

public final class LiveStreamChatMessageCellViewModel: LiveStreamChatMessageCellViewModelType,
LiveStreamChatMessageCellViewModelInputs, LiveStreamChatMessageCellViewModelOutputs {

  public init() {
    self.avatarImageUrl = self.chatMessageProperty.signal.skipNil().map {
      URL(string: $0.profilePictureUrl)
    }

    self.creatorViewsHidden = Signal.merge(
      self.chatMessageProperty.signal.skipNil().mapConst(true),
      Signal.combineLatest(
        self.chatMessageProperty.signal.skipNil(),
        self.creatorUserIdProperty.signal.skipNil()
        )
        .map {
          $0.userId != $1
      }
    )

    self.message = self.chatMessageProperty.signal.skipNil().map { $0.message }

    self.name = self.chatMessageProperty.signal.skipNil().map { $0.name }
  }

  private let chatMessageProperty = MutableProperty<LiveStreamChatMessage?>(nil)
  public func configureWith(chatMessage: LiveStreamChatMessage) {
    self.chatMessageProperty.value = chatMessage
  }

  private let creatorUserIdProperty = MutableProperty<Int?>(nil)
  public func setCreatorUserId(creatorUserId: Int) {
    self.creatorUserIdProperty.value = creatorUserId
  }

  public let avatarImageUrl: Signal<URL?, NoError>
  public let creatorViewsHidden: Signal<Bool, NoError>
  public let message: Signal<String, NoError>
  public let name: Signal<String, NoError>

  public var inputs: LiveStreamChatMessageCellViewModelInputs { return self }
  public var outputs: LiveStreamChatMessageCellViewModelOutputs { return self }
}
