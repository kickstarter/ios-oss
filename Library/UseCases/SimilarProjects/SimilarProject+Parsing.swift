import Foundation
import Kingfisher
import KsApi

internal struct SimilarProjectFragment: SimilarProject {
  let projectID: Int
  let image: Kingfisher.Source
  let name: String
  let isLaunched: Bool
  let isPrelaunchActivated: Bool
  let isInPostCampaignPledgingPhase: Bool
  let isPostCampaignPledgingEnabled: Bool
  let launchedAt: Date?
  let deadlineAt: Date?
  let percentFunded: Int
  let state: Project.State
  let goal: Money?
  let pledged: Money?

  init?(_ fragment: GraphAPI.ProjectCardFragment) {
    guard
      let imageURL = fragment.image.flatMap({ URL(string: $0.url) }),
      let state = Project.State(fragment.state)
    else {
      return nil
    }

    func timestamp(from: String?) -> Date? {
      from
        .flatMap { timestamp in Int(timestamp) }
        .flatMap { timestamp in Date(timeIntervalSince1970: TimeInterval(timestamp)) }
    }

    let launchedAt = timestamp(from: fragment.launchedAt)
    let deadlineAt = timestamp(from: fragment.deadlineAt)

    self.projectID = fragment.pid
    self.image = .network(imageURL)
    self.name = fragment.name
    self.isLaunched = fragment.isLaunched
    self.isPrelaunchActivated = fragment.prelaunchActivated
    self.isInPostCampaignPledgingPhase = fragment.isInPostCampaignPledgingPhase
    self.isPostCampaignPledgingEnabled = fragment.postCampaignPledgingEnabled
    self.launchedAt = launchedAt
    self.deadlineAt = deadlineAt
    self.percentFunded = fragment.percentFunded
    self.state = state
    self.goal = (fragment.goal?.fragments.moneyFragment).flatMap(Money.init)
    self.pledged = Money(fragment.pledged.fragments.moneyFragment)
  }
}
