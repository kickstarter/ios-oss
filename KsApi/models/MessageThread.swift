import Argo
import Curry
import Runes

public struct MessageThread {
  public private(set) var backing: Backing?
  public private(set) var closed: Bool
  public private(set) var id: Int
  public private(set) var lastMessage: Message
  public private(set) var participant: User
  public private(set) var project: Project
  public private(set) var unreadMessagesCount: Int
}

extension MessageThread: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<MessageThread> {
    let create = curry(MessageThread.init)
    let tmp = create
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
