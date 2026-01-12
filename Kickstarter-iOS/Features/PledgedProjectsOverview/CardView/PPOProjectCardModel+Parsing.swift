import Foundation
import GraphAPI
import Kingfisher
import KsApi
import Library

private struct PPOParsedAction {
  let action: PPOProjectCardModel.ButtonAction?
  let tierType: PPOTierType
}

extension PPOProjectCardModel {
  init?(node: GraphAPI.FetchPledgedProjectsQuery.Data.PledgeProjectsOverview.Pledges.Edge.Node) {
    let card = node.fragments.pPOCardFragment
    let backing = card.backing?.fragments.pPOBackingFragment
    let ppoProject = backing?.project?.fragments.pPOProjectFragment

    let image = ppoProject?.image
      .flatMap { URL(string: $0.url) }
      .map { Kingfisher.Source.network($0) }

    let projectName = ppoProject?.name
    let projectId = ppoProject?.pid
    let pledgeFragment = backing?.amount.fragments.moneyFragment
    let formattedPledge = pledgeFragment.flatMap { Format.currency($0) }
    let creatorName = ppoProject?.creator?.name

    let addressId: String? = backing?.deliveryAddress?.id
    let addressWithoutName = Self.addressWithoutName(deliveryAddress: backing?.deliveryAddress)
    let displayAddress = Self.displayAddress(
      card: card,
      name: backing?.deliveryAddress?.recipientName,
      addressWithoutName: addressWithoutName
    )

    let alerts: [PPOProjectCardModel.Alert] = card.flags?
      .compactMap { PPOProjectCardModel.Alert(flag: $0) } ?? []

    guard let cardTierType = card.tierType, let tierType = PPOTierType(rawValue: cardTierType)
    else {
      return nil
    }
    let action: PPOParsedAction?
    switch tierType {
    case .fixPayment:
      action = Self.actionForPaymentFailed()
    case .confirmAddress:
      action = Self.actionForConfirmAddress(
        showAddress: card.showShippingAddress,
        address: addressWithoutName,
        addressId: addressId
      )
    case .openSurvey:
      action = Self.actionForSurvey()
    case .authenticateCard:
      action = Self.actionForAuthentication(clientSecret: backing?.clientSecret)
    case .pledgeManagement:
      action = Self.actionForPledgeManagement()
    case .surveySubmitted, .pledgeCollected, .addressConfirmed, .awaitingReward, .rewardReceived:
      action = PPOParsedAction(action: nil, tierType: tierType)
    }

    let projectAnalyticsFragment = backing?.project?.fragments.projectAnalyticsFragment

    // Show the reward toggle if the backend says to show it and the v2 feature flag is on.
    let showRewardToggle = featurePledgedProjectsOverviewV2Enabled() && card.showRewardReceivedToggle
    let toggleState: PPORewardToggleState
    if !showRewardToggle {
      toggleState = .hidden
    } else if backing?.backerCompleted == true {
      toggleState = .rewardReceived
    } else {
      toggleState = .notReceived
    }

    // Let backingDetailsUrl default to the card-specific webviewUrl.
    // TODO(MBL-2540): Only set this field for cards that need it, once the open backing details
    // action is replaced by a open project page action instead.
    let webviewUrl = card.webviewUrl
    let backingDetailsUrl = webviewUrl ?? backing?.backingDetailsPageRoute

    let backingId = backing.flatMap { decompose(id: $0.id) }
    let backingGraphId = backing?.id

    if let image, let projectName, let projectId, let formattedPledge, let creatorName, let action,
       let projectAnalyticsFragment, let backingDetailsUrl, let backingId, let backingGraphId {
      self.init(
        isUnread: true,
        alerts: alerts,
        image: image,
        projectName: projectName,
        projectId: projectId,
        pledge: formattedPledge,
        creatorName: creatorName,
        address: displayAddress,
        rewardReceivedToggleState: toggleState,
        action: action.action,
        tierType: action.tierType,
        backingDetailsUrl: backingDetailsUrl,
        backingId: backingId,
        backingGraphId: backingGraphId,
        projectAnalytics: projectAnalyticsFragment
      )
    } else {
      return nil
    }
  }

  private static func addressWithoutName(deliveryAddress: PPOBackingFragment.DeliveryAddress?) -> String? {
    guard let deliveryAddress else { return nil }
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

  private static func displayAddress(
    card: PPOCardFragment,
    name: String?,
    addressWithoutName: String?
  ) -> PPOProjectCardModel.DisplayAddress {
    guard let addressWithoutName else { return .hidden }
    if !card.showShippingAddress { return .hidden }

    let address = (name ?? "") + "\n" + addressWithoutName

    if card.showEditAddressAction {
      return .editable(address: address)
    }
    return .locked(address: address)
  }

  private static func actionForPaymentFailed() -> PPOParsedAction {
    PPOParsedAction(
      action: .fixPayment,
      tierType: .fixPayment
    )
  }

  private static func actionForConfirmAddress(showAddress: Bool, address: String?, addressId: String?)
    -> PPOParsedAction? {
    guard showAddress == true,
          let address = address,
          let addressId = addressId else {
      return PPOParsedAction(
        action: .completeSurvey,
        tierType: .confirmAddress
      )
    }

    return PPOParsedAction(
      action: .confirmAddress(address: address, addressId: addressId),
      tierType: .confirmAddress
    )
  }

  private static func actionForSurvey() -> PPOParsedAction {
    PPOParsedAction(
      action: .completeSurvey,
      tierType: .openSurvey
    )
  }

  private static func actionForPledgeManagement() -> PPOParsedAction {
    PPOParsedAction(
      action: .managePledge,
      tierType: .pledgeManagement
    )
  }

  private static func actionForAuthentication(clientSecret: String?)
    -> PPOParsedAction? {
    guard let clientSecret = clientSecret else { return nil }

    return PPOParsedAction(
      action: .authenticateCard(clientSecret: clientSecret),
      tierType: .authenticateCard
    )
  }
}
