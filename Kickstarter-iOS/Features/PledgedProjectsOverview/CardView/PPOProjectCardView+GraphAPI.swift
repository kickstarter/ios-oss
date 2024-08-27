import Foundation
import KsApi

extension PPOProjectCardViewModel {
  convenience init?(node: GraphAPI.FetchPledgedProjectsQuery.Data.PledgeProjectsOverview.Pledge.Edge.Node) {
    // TODO: Implement
    let isUnread = true

    let imageURL = node.fragments.ppoCardFragment
      .backing?.fragments.ppoBackingFragment
      .project?.fragments.ppoProjectFragment
      .image?.url
      .flatMap { URL(string: $0) }

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

    // TODO: Implement
    let address: String? = nil

    let alerts: [PPOProjectCardViewModel.Alert] = node.fragments.ppoCardFragment.flags?.compactMap { PPOProjectCardViewModel.Alert(flag: $0) } ?? []

    // TODO: Implement
    let action = PPOProjectCardViewModel.Action.confirmAddress

    if let imageURL, let title, let pledge, let creatorName {
      self.init(
        isUnread: isUnread,
        alerts: alerts,
        imageURL: imageURL,
        title: title,
        pledge: pledge,
        creatorName: creatorName,
        address: address,
        actions: (action, nil),
        parentSize: .zero
      )
    } else {
      return nil
    }
  }
}

extension PPOProjectCardViewModel.Alert {
  init?(flag: GraphAPI.PpoCardFragment.Flag) {
    let alertType: PPOProjectCardViewModel.Alert.AlertType? = switch flag.type {
    case "alert":
        .alert
    case "time":
        .time
    default:
        nil
    }

    let alertIcon: PPOProjectCardViewModel.Alert.AlertIcon? = switch flag.icon {
    case "alert":
        .alert
    case "warning":
        .warning
    default:
      nil
    }
    let message = flag.message

    guard let alertType, let alertIcon, let message else {
      return nil
    }

    self = .init(type: alertType, icon: alertIcon, message: message)
  }
}
