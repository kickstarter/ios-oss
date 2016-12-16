import KsApi
import KsLive

/**
 An enumeration of all the place a share flow can be started.

 - creatorDashboard: Sharing a creator's project from their dashboard.
 - liveStream:       Sharing a live stream from the countdown or stream itself.
 - project:          Sharing a project from the project screen.
 - thanks:           Sharing a project from the checkout-thanks screen.
 - update:           Sharing an update from the update screen.
 */
public enum ShareContext {
  case creatorDashboard(Project)
  case liveStream(Project, LiveStreamEvent)
  case project(Project)
  case thanks(Project)
  case update(Project, Update)

  public var isLiveStreamContext: Bool {
    if case .liveStream = self {
      return true
    }
    return false
  }

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

  public var liveStreamEvent: LiveStreamEvent? {
    if case let .liveStream(_, liveStreamEvent) = self {
      return liveStreamEvent
    }
    return nil
  }

  public var project: Project {
    switch self {
    case let .creatorDashboard(project):  return project
    case let .liveStream(project, _):     return project
    case let .project(project):           return project
    case let .thanks(project):            return project
    case let .update(project, _):         return project
    }
  }

  public var update: Update? {
    switch self {
    case let .update(_, update):  return update
    default:    return nil
    }
  }
}
