import KsApi

/**
 An enumeration of all the place a share flow can be started.

 - creatorDashboard: Sharing a creator's project from their dashboard.
 - discovery:        Sharing a project from the discovery page.
 - project:          Sharing a project from the project screen.
 - thanks:           Sharing a project from the checkout-thanks screen.
 - update:           Sharing an update from the update screen.
 */
public enum ShareContext {
  case creatorDashboard(Project)
  case discovery(Project)
  case project(Project)
  case thanks(Project)
  case update(Project, Update)

  public var isUpdateContext: Bool {
    if case .update = self {
      return true
    }
    return false
  }

  public var isThanksContext: Bool {
    if case .thanks = self {
      return true
    }
    return false
  }

  public var project: Project {
    switch self {
    case let .creatorDashboard(project): return project
    case let .discovery(project): return project
    case let .project(project): return project
    case let .thanks(project): return project
    case let .update(project, _): return project
    }
  }

  public var update: Update? {
    switch self {
    case let .update(_, update): return update
    default: return nil
    }
  }
}

extension ShareContext: Equatable {
  public static func == (lhs: ShareContext, rhs: ShareContext) -> Bool {
    switch (lhs, rhs) {
    case let (.creatorDashboard(lhs), .creatorDashboard(rhs)):
      return lhs == rhs
    case let (.discovery(lhs), .discovery(rhs)):
      return lhs == rhs
    case let (.project(lhs), .project(rhs)):
      return lhs == rhs
    case let (.thanks(lhs), .thanks(rhs)):
      return lhs == rhs
    case let (.update(lhsProject, lhsUpdate), .update(rhsProject, rhsUpdate)):
      return lhsProject == rhsProject && lhsUpdate == rhsUpdate
    case (.creatorDashboard, _), (.discovery, _), (.project, _), (.thanks, _), (.update, _):
      return false
    }
  }
}
