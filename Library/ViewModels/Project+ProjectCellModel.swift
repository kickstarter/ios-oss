import Foundation
import KsApi

extension Project: BackerDashboardProjectCellViewModel.ProjectCellModel {
  public var fundingProgress: Float {
    return self.stats.fundingProgress
  }

  public var percentFunded: Int {
    return self.stats.percentFunded
  }

  public var imageURL: String? {
    return self.photo.full
  }

  public var launchedAt: TimeInterval? {
    return self.dates.launchedAt
  }

  public var deadline: TimeInterval? {
    return self.dates.deadline
  }

  public var isStarred: Bool? {
    self.personalization.isStarred
  }
}
