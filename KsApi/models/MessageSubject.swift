public enum MessageSubject: Equatable {
  case backing(Backing)
  case messageThread(MessageThread)
  case project(Project)

  public var backing: Backing? {
    if case let .backing(backing) = self {
      return backing
    }
    return nil
  }

  public var messageThread: MessageThread? {
    if case let .messageThread(messageThread) = self {
      return messageThread
    }
    return nil
  }

  public var project: Project? {
    if case let .project(project) = self {
      return project
    }
    return nil
  }
}
