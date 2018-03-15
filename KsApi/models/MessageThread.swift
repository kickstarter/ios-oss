import Argo
import Curry
import Runes

public struct MessageThread {
  public let backing: Backing?
  public let closed: Bool
  public let id: Int
  public let lastMessage: Message
  public let participant: User
  public let project: Project
  public let unreadMessagesCount: Int
}

extension MessageThread: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<MessageThread> {
    let tmp = curry(MessageThread.init)
      <^> json <|? "backing"
      <*> json <| "closed"
      <*> json <| "id"
      <*> json <| "last_message"
    return tmp
      <*> json <| "participant"
      <*> json <| "project"
      <*> json <| "unread_messages_count"
  }
}

extension MessageThread: Equatable {}
public func == (lhs: MessageThread, rhs: MessageThread) -> Bool {
  return lhs.id == rhs.id
}
