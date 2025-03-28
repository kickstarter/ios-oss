import Foundation
import Kingfisher
import KsApi
import Library

private struct PPOParsedAction {
  let primaryAction: PPOProjectCardModel.Action
  let secondaryAction: PPOProjectCardModel.Action?
  let tierType: PPOProjectCardModel.TierType
}

private enum PPOProjectCardModelConstants {
  static let paymentFailed = "Tier1PaymentFailed"
  static let confirmAddress = "Tier1AddressLockingSoon"
  static let completeSurvey = "Tier1OpenSurvey"
  static let authenticationRequired = "Tier1PaymentAuthenticationRequired"
}

extension PPOProjectCardModel {
  init?(node: GraphAPI.FetchPledgedProjectsQuery.Data.PledgeProjectsOverview.Pledge.Edge.Node) {
    let card = node.fragments.ppoCardFragment
    let backing = card.backing?.fragments.ppoBackingFragment
    let ppoProject = backing?.project?.fragments.ppoProjectFragment

    let image = ppoProject?.image
      .flatMap { URL(string: $0.url) }
      .map { Kingfisher.Source.network($0) }

    let projectName = ppoProject?.name
    let projectId = ppoProject?.pid
    let pledgeFragment = backing?.amount.fragments.moneyFragment
    let formattedPledge = pledgeFragment.flatMap { Format.currency($0) }
    let creatorName = ppoProject?.creator?.name

    let addressId: String? = backing?.deliveryAddress?.id
    let addressWithoutName: String? = backing?.deliveryAddress.flatMap { deliveryAddress in
      let cityRegionFields: [String?] = [
        deliveryAddress.city,
        deliveryAddress.region.flatMap { ", \($0)" },
        deliveryAddress.postalCode.flatMap { " \($0)" }
      ]
      let fields: [String?] = [
        deliveryAddress.addressLine1,
        deliveryAddress.addressLine2,
        cityRegionFields.compactMap { $0 }.joined(),
        deliveryAddress.countryCode.rawValue,
        deliveryAddress.phoneNumber
      ]
      // Create address from all fields that are not nil and not the empty string.
      return fields.compactMap { ($0 ?? "").isEmpty ? nil : $0 }.joined(separator: "\n")
    }
    let addressWithName = addressWithoutName.flatMap { address in
      guard let name = backing?.deliveryAddress?.recipientName else {
        return address
      }
      return name + "\n" + address
    }

    let alerts: [PPOProjectCardModel.Alert] = card.flags?
      .compactMap { PPOProjectCardModel.Alert(flag: $0) } ?? []

    let actions: PPOParsedAction?
    switch card.tierType {
    case PPOProjectCardModelConstants.paymentFailed:
      actions = Self.actionsForPaymentFailed()
    case PPOProjectCardModelConstants.confirmAddress:
      actions = Self.actionsForConfirmAddress(address: addressWithoutName, addressId: addressId)
    case PPOProjectCardModelConstants.completeSurvey:
      actions = Self.actionsForSurvey()
    case PPOProjectCardModelConstants.authenticationRequired:
      actions = Self.actionsForAuthentication(clientSecret: backing?.clientSecret)
    default:
      return nil
    }

    let projectAnalyticsFragment = backing?.project?.fragments.projectAnalyticsFragment

    // For v1 of PPO we're just using the same url for surveys and the backing details page.
    // This specifically links to the survey tab.
    let backingDetailsUrl = backing?.backingDetailsPageRoute
    let backingId = backing.flatMap { decompose(id: $0.id) }
    let backingGraphId = backing?.id

    if let image, let projectName, let projectId, let formattedPledge, let creatorName, let actions,
       let projectAnalyticsFragment, let backingDetailsUrl, let backingId, let backingGraphId {
      self.init(
        isUnread: true,
        alerts: alerts,
        image: image,
        projectName: projectName,
        projectId: projectId,
        pledge: formattedPledge,
        creatorName: creatorName,
        address: addressWithName,
        actions: (actions.primaryAction, actions.secondaryAction),
        tierType: actions.tierType,
        backingDetailsUrl: backingDetailsUrl,
        backingId: backingId,
        backingGraphId: backingGraphId,
        projectAnalytics: projectAnalyticsFragment
      )
    } else {
      return nil
    }
  }

  private static func actionsForPaymentFailed() -> PPOParsedAction {
    PPOParsedAction(
      primaryAction: .fixPayment,
      secondaryAction: nil,
      tierType: .fixPayment
    )
  }

  private static func actionsForConfirmAddress(address: String?, addressId: String?)
    -> PPOParsedAction? {
    guard let address = address,
          let addressId = addressId else {
      return PPOParsedAction(
        primaryAction: .completeSurvey,
        secondaryAction: nil,
        tierType: .confirmAddress
      )
    }

    return PPOParsedAction(
      primaryAction: .confirmAddress(address: address, addressId: addressId),
      secondaryAction: .editAddress,
      tierType: .confirmAddress
    )
  }

  private static func actionsForSurvey() -> PPOParsedAction {
    PPOParsedAction(
      primaryAction: .completeSurvey,
      secondaryAction: nil,
      tierType: .openSurvey
    )
  }

  private static func actionsForAuthentication(clientSecret: String?)
    -> PPOParsedAction? {
    guard let clientSecret = clientSecret else { return nil }

    return PPOParsedAction(
      primaryAction: .authenticateCard(clientSecret: clientSecret),
      secondaryAction: nil,
      tierType: .authenticateCard
    )
  }
}
