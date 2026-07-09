import Apollo
import Foundation
import GraphAPI
import Prelude
import ReactiveSwift

extension Project {
  public struct ProjectPamphletData: Decodable {
    let project: Project
    let backingId: Int?
  }

  static func projectProducer(
    from data: GraphAPI.FetchProjectByParamQuery.Data,
    configCurrency: String?
  ) -> SignalProducer<ProjectPamphletData, ErrorEnvelope> {
    let projectAndBackingId = Project.project(
      from: data,
      configCurrency: configCurrency
    )

    guard let project = projectAndBackingId.0 else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    let data = ProjectPamphletData(
      project: project,
      backingId: projectAndBackingId.1
    )

    return SignalProducer(value: data)
  }

  internal static func project(
    from data: GraphAPI.FetchProjectByParamQuery.Data,
    configCurrency: String?
  ) -> (Project?, Int?) {
    var projectBackingId: Int?

    if let backingId = data.project?.backing?.id {
      projectBackingId = decompose(id: backingId)
    }

    guard
      let fragment = data.project?.fragments.projectFragment,
      let noRewardFragment = data.project?.fragments.noRewardRewardFragment,
      let project = Project.project(
        from: fragment,
        flagging: data.project?.flagging != nil,
        rewards: [Reward.noRewardReward(from: noRewardFragment)],
        addOns: nil,
        backing: nil,
        currentUserChosenCurrency: data.me?.chosenCurrency ?? configCurrency
      )
    else { return (nil, nil) }

    return (project, projectBackingId)
  }
}
