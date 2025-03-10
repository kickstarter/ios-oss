import Foundation
import KsApi

extension GraphAPI.BackerDashboardProjectCellFragment: BackerDashboardProjectCellViewModel.ProjectCellModel {
  public var id: Int {
    return Int(self.projectId) ?? -1
  }

  public var prelaunchActivated: Bool? {
    return Optional.some(self.projectPrelaunchActivated)
  }

  public var state: KsApi.Project.State {
    return Project.State(rawValue: self.projectState.rawValue.lowercased()) ?? Project.State.live
  }

  public var imageURL: String {
    self.image?.url ?? ""
  }

  public var fundingProgress: Float {
    let pledged = self.pledged.fragments.moneyFragment.amount.flatMap(Float.init) ?? 0

    let goal = self.goal?.fragments.moneyFragment.amount.flatMap(Float.init).flatMap(Int.init) ?? 0

    return goal == 0 ? 0.0 : Float(pledged) / Float(goal)
  }

  public var percentFunded: Int {
    return Int(floor(self.fundingProgress * 100.0))
  }

  public var displayPrelaunch: Bool? {
    return !self.isLaunched
  }

  public var launchedAt: TimeInterval? {
    return self.projectLaunchedAt.flatMap(TimeInterval.init)
  }

  public var deadline: TimeInterval? {
    return self.deadlineAt.flatMap(TimeInterval.init)
  }

  public var isStarred: Bool? {
    return self.isWatched
  }
}
