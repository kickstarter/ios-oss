import Foundation
import Kingfisher
import KsApi

/// Represents a project that is similar to the currently viewed project.
public protocol ProjectCardProperties: ProjectPamphletMainCellConfiguration {
  /// The identifier for the project.
  var projectID: Int { get }

  var image: Kingfisher.Source { get }

  var name: String { get }

  var isLaunched: Bool { get }
  var isPrelaunchActivated: Bool { get }
  var isInPostCampaignPledgingPhase: Bool { get }
  var isPostCampaignPledgingEnabled: Bool { get }

  var launchedAt: Date? { get }
  var deadlineAt: Date? { get }
  var percentFunded: Int { get }

  var state: Project.State { get }
  var goal: Money? { get }
  var pledged: Money? { get }
}

extension ProjectCardProperties {
  var shouldDisplayPrelaunch: Bool {
    self.isPrelaunchActivated && self.state == .submitted
  }
}

extension ProjectCardProperties {
  public var projectPageParam: ProjectPageParam {
    ProjectPageParamBox(
      param: Param.id(self.projectID),
      initialProject: self
    )
  }
}
