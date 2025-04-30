import Foundation
import Kingfisher
import KsApi

/// Represents a project that can be displayed in a project card.
public struct ProjectCardProperties {
  /// The identifier for the project.
  public let projectID: Int
  public let image: Kingfisher.Source
  public let name: String

  public let isLaunched: Bool
  public let isStarred: Bool
  public let isPrelaunchActivated: Bool
  public let isInPostCampaignPledgingPhase: Bool
  public let isPostCampaignPledgingEnabled: Bool

  public let launchedAt: Date?
  public let deadlineAt: Date?
  public let percentFunded: Int

  public let state: Project.State
  public let goal: Money?
  public let pledged: Money?
  public let url: String

  let projectAnalytics: any ProjectAnalyticsProperties
  let projectPamphletMainCell: any HasProjectPamphletMainCellProperties

  public init(
    projectID: Int,
    image: Kingfisher.Source,
    name: String,
    isLaunched: Bool,
    isStarred: Bool,
    isPrelaunchActivated: Bool,
    isInPostCampaignPledgingPhase: Bool,
    isPostCampaignPledgingEnabled: Bool,
    launchedAt: Date?,
    deadlineAt: Date?,
    percentFunded: Int,
    state: Project.State,
    goal: Money?,
    pledged: Money?,
    url: String,
    projectAnalytics: any ProjectAnalyticsProperties,
    projectPamphletMainCell: any HasProjectPamphletMainCellProperties
  ) {
    self.projectID = projectID
    self.image = image
    self.name = name
    self.isLaunched = isLaunched
    self.isStarred = isStarred
    self.isPrelaunchActivated = isPrelaunchActivated
    self.isInPostCampaignPledgingPhase = isInPostCampaignPledgingPhase
    self.isPostCampaignPledgingEnabled = isPostCampaignPledgingEnabled
    self.launchedAt = launchedAt
    self.deadlineAt = deadlineAt
    self.percentFunded = percentFunded
    self.state = state
    self.goal = goal
    self.pledged = pledged
    self.url = url
    self.projectAnalytics = projectAnalytics
    self.projectPamphletMainCell = projectPamphletMainCell
  }

  public var shouldDisplayPrelaunch: Bool {
    self.isPrelaunchActivated && self.state == .submitted
  }

  public var projectPageParam: ProjectPageParam {
    ProjectPageParamBox(
      param: Param.id(self.projectID),
      initialProject: self
    )
  }
}
