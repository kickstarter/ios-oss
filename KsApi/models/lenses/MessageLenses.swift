import Prelude

extension Message {
  public enum lens {
    public static let id = Lens<Message, Int>(
      view: { $0.id },
      set: { Message(body: $1.body, createdAt: $1.createdAt, id: $0, recipient: $1.recipient,
        sender: $1.sender) }
    )

    public static let body = Lens<Message, String>(
      view: { $0.body },
      set: { Message(body: $0, createdAt: $1.createdAt, id: $1.id, recipient: $1.recipient,
        sender: $1.sender) }
    )

    public static let recipient = Lens<Message, User>(
      view: { $0.recipient },
      set: { Message(body: $1.body, createdAt: $1.createdAt, id: $1.id, recipient: $0,
                     sender: $1.sender) }
    )

    public static let sender = Lens<Message, User>(
      view: { $0.sender },
      set: { Message(body: $1.body, createdAt: $1.createdAt, id: $1.id, recipient: $1.recipient,
                     sender: $0) }
    )
  }
}
