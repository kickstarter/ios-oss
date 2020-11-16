

public struct MessageThread {
  public let backing: Backing?
  public let closed: Bool
  public let id: Int
  public let lastMessage: Message
  public let participant: User
  public let project: Project
  public let unreadMessagesCount: Int
}

extension MessageThread: Decodable {
  enum CodingKeys: String, CodingKey {
    case backing
    case closed
    case id
    case lastMessage = "last_message"
    case participant
    case project
    case unreadMessagesCount = "unread_messages_count"
  }
}

extension MessageThread: Equatable {}
public func == (lhs: MessageThread, rhs: MessageThread) -> Bool {
  return lhs.id == rhs.id
}
