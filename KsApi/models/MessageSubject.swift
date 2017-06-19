public enum MessageSubject {
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

extension MessageSubject: Equatable {}
public func == (lhs: MessageSubject, rhs: MessageSubject) -> Bool {
  switch (lhs, rhs) {
  case let (.backing(lhs), .backing(rhs)):
    return lhs == rhs
  case let (.messageThread(lhs), .messageThread(rhs)):
    return lhs == rhs
  case let (.project(lhs), .project(rhs)):
    return lhs == rhs
  default:
    return false
  }
}
