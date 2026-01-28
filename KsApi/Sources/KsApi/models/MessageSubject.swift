public enum MessageSubject: Equatable {
  case messageThread(MessageThread)
  case project(id: Int, name: String)

  public var messageThread: MessageThread? {
    if case let .messageThread(messageThread) = self {
      return messageThread
    }
    return nil
  }

  public var project: (id: Int, name: String)? {
    if case let .project(id, name) = self {
      return (id, name)
    }
    return nil
  }
}
