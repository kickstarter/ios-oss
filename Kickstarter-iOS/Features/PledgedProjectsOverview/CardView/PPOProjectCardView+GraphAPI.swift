import Foundation
import KsApi

extension PPOProjectCardViewModel {
  convenience init?(node: GraphAPI.FetchPledgedProjectsQuery.Data.PledgeProjectsOverview.Pledge.Edge.Node) {
    // TODO
    let isUnread = true

    let imageURL = node.fragments.ppoCardFragment
      .backing?.fragments.ppoBackingFragment
      .project?.fragments.ppoProjectFragment
      .image?.url
      .flatMap({ URL(string: $0 )})

    let title = node.fragments.ppoCardFragment
      .backing?.fragments.ppoBackingFragment
      .project?.fragments.ppoProjectFragment
      .name

    let pledge = node.fragments.ppoCardFragment
      .backing?.fragments.ppoBackingFragment
      .amount.fragments.moneyFragment

    let creatorName = node.fragments.ppoCardFragment
      .backing?.fragments.ppoBackingFragment
      .project?.fragments.ppoProjectFragment
      .creator?.name

    // TODO
    let address: String? = nil

    // TODO
    let alerts: [PPOProjectCardViewModel.Alert] = []

    // TODO
    let action = PPOProjectCardViewModel.Action.confirmAddress

    if let imageURL, let title, let pledge, let creatorName {
      self.init(isUnread: isUnread, alerts: alerts, imageURL: imageURL, title: title, pledge: pledge, creatorName: creatorName, address: address, actions: (action, nil))
    } else {
      return nil
    }
  }
}
