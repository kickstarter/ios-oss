import Prelude

extension MessageThread {
  public enum lens {
    public static let id = Lens<MessageThread, Int>(
      view: { $0.id },
      set: { MessageThread(backing: $1.backing, closed: $1.closed, id: 0, lastMessage: $1.lastMessage,
        participant: $1.participant, project: $1.project, unreadMessagesCount: $1.unreadMessagesCount) }
    )

    public static let participant = Lens<MessageThread, User>(
      view: { $0.participant },
      set: { MessageThread(backing: $1.backing, closed: $1.closed, id: $0.id, lastMessage: $1.lastMessage,
        participant: $0, project: $1.project, unreadMessagesCount: $1.unreadMessagesCount) }
    )

    public static let project = Lens<MessageThread, Project>(
      view: { $0.project },
      set: { MessageThread(backing: $1.backing, closed: $1.closed, id: $0.id, lastMessage: $1.lastMessage,
        participant: $1.participant, project: $0, unreadMessagesCount: $1.unreadMessagesCount) }
    )

    public static let lastMessage = Lens<MessageThread, Message>(
      view: { $0.lastMessage },
      set: { .init(backing: $1.backing, closed: $1.closed, id: $0.id, lastMessage: $0,
                   participant: $1.participant, project: $1.project,
                   unreadMessagesCount: $1.unreadMessagesCount) }
    )

    public static let unreadMessagesCount  = Lens<MessageThread, Int>(
      view: { $0.unreadMessagesCount },
      set: { .init(backing: $1.backing, closed: $1.closed, id: $1.id, lastMessage: $1.lastMessage,
                   participant: $1.participant, project: $1.project, unreadMessagesCount: $0) }
    )
  }
}
