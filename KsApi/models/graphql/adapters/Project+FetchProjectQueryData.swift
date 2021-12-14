import Apollo
import Foundation
import Prelude
import ReactiveSwift

extension Project {
  public typealias ProjectPamphletData = (
    project: Project,
    backingId: Int?
  )

  static func projectProducer(
    from data: GraphAPI.FetchProjectByIdQuery.Data,
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

  static func projectProducer(from data: GraphAPI.FetchProjectBySlugQuery.Data,
                              configCurrency: String?) -> SignalProducer<ProjectPamphletData, ErrorEnvelope> {
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

  static func project(from data: GraphAPI.FetchProjectByIdQuery.Data,
                      configCurrency: String?) -> (Project?, Int?) {
    var projectBackingId: Int?

    if let backingId = data.project?.backing?.id {
      projectBackingId = decompose(id: backingId)
    }

    guard
      let fragment = data.project?.fragments.projectFragment,
      let project = Project.project(
        from: fragment,
        rewards: [noRewardReward(from: fragment)],
        addOns: nil,
        backing: nil,
        currentUserChosenCurrency: data.me?.chosenCurrency ?? configCurrency
      )
    else { return (nil, nil) }

    return (project, projectBackingId)
  }

  static func project(from data: GraphAPI.FetchProjectBySlugQuery.Data,
                      configCurrency: String?) -> (Project?, Int?) {
    var projectBackingId: Int?

    if let backingId = data.project?.backing?.id {
      projectBackingId = decompose(id: backingId)
    }

    guard
      let fragment = data.project?.fragments.projectFragment,
      let project = Project.project(
        from: fragment,
        rewards: [noRewardReward(from: fragment)],
        addOns: nil,
        backing: nil,
        currentUserChosenCurrency: data.me?.chosenCurrency ?? configCurrency
      )
    else { return (nil, nil) }

    return (project, projectBackingId)
  }

  /** FIXME: This is unfortunately a consequence of the no-reward reward being returned on v1 but not in GQL. Eventually we'll want to talk with backend about the possibility of returning a no-reward reward as part of the project query, just as they did with v1. The benefit of that is no reward reward doesn't have to be maintained locally. We want to show the rewards that the backend returns without modification to the raw data.
   */

  private static func noRewardReward(from fragment: GraphAPI.ProjectFragment?) -> Reward {
    let projectMinimumPledgeAmount: Int = fragment?.minPledge ?? 1
    let currentUsersCurrencyFXRate: Double = fragment?.fxRate ?? 1.0

    let convertedMinimumAmount = currentUsersCurrencyFXRate * Double(projectMinimumPledgeAmount)

    let emptyReward = Reward.noReward
      |> Reward.lens.minimum .~ Double(projectMinimumPledgeAmount)
      |> Reward.lens.convertedMinimum .~ convertedMinimumAmount

    return emptyReward
  }
}
