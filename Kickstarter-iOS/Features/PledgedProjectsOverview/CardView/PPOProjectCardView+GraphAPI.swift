import Foundation
import KsApi

extension PPOProjectCardViewModel {
  convenience init?(node: GraphAPI.FetchPledgedProjectsQuery.Data.PledgeProjectsOverview.Pledge.Edge.Node) {
    let card = node.fragments.ppoCardFragment
    let backing = card.backing?.fragments.ppoBackingFragment
    let project = backing?.project?.fragments.ppoProjectFragment

    let imageURL = project?.image?.url
      .flatMap { URL(string: $0) }

    let title = project?.name
    let pledge = backing?.amount.fragments.moneyFragment
    let creatorName = project?.creator?.name

    // TODO: Implement [MBL-1695]
    let address: String? = nil

    let alerts: [PPOProjectCardViewModel.Alert] = card.flags?
      .compactMap { PPOProjectCardViewModel.Alert(flag: $0) } ?? []

    let primaryAction: PPOProjectCardViewModel.Action
    let secondaryAction: PPOProjectCardViewModel.Action?
    switch card.tierType {
    case "Tier1PaymentFailed":
      primaryAction = .fixPayment
      secondaryAction = nil
    case "Tier1AddressLockingSoon":
      primaryAction = .confirmAddress
      secondaryAction = .editAddress
    case "Tier1OpenSurvey":
      primaryAction = .completeSurvey
      secondaryAction = nil
    case "Tier1PaymentAuthenticationRequired":
      primaryAction = .authenticateCard
      secondaryAction = nil
    case .some(_), .none:
      return nil
    }

    if let imageURL, let title, let pledge, let creatorName {
      self.init(
        isUnread: true,
        alerts: alerts,
        imageURL: imageURL,
        title: title,
        pledge: pledge,
        creatorName: creatorName,
        address: address,
        actions: (primaryAction, secondaryAction),
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
