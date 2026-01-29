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

    // Card-specific webview url is based on the card tier type.
    // Fall back to backingDetailsPageRoute if needed.
    let webviewUrl = card.webviewUrl ?? backing?.backingDetailsPageRoute

    let addressId: String? = backing?.deliveryAddress?.id
    let addressWithoutName = Self.addressWithoutName(deliveryAddress: backing?.deliveryAddress)
    let displayAddress = Self.displayAddress(
      card: card,
      name: backing?.deliveryAddress?.recipientName,
      addressWithoutName: addressWithoutName,
      webviewUrl: webviewUrl
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
      // Confirm address action will fall back to complete survey action if no address.
      action = Self.actionForConfirmAddress(
        showAddress: card.showShippingAddress,
        address: addressWithoutName,
        addressId: addressId
      ) ?? Self.actionForSurvey(url: webviewUrl)
    case .openSurvey:
      action = Self.actionForSurvey(url: webviewUrl)
    case .authenticateCard:
      action = Self.actionForAuthentication(clientSecret: backing?.clientSecret)
    case .pledgeManagement:
      action = Self.actionForPledgeManagement(url: webviewUrl)
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

    let backingId = backing.flatMap { decompose(id: $0.id) }
    let backingGraphId = backing?.id

    if let image, let projectName, let projectId, let formattedPledge, let creatorName, let action,
       let projectAnalyticsFragment, let backingId, let backingGraphId {
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
    addressWithoutName: String?,
    webviewUrl: String?
  ) -> PPOProjectCardModel.DisplayAddress {
    guard let addressWithoutName else { return .hidden }
    if !card.showShippingAddress { return .hidden }

    let address = (name ?? "") + "\n" + addressWithoutName

    if card.showEditAddressAction, let webviewUrl {
      return .editable(address: address, editUrl: webviewUrl)
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
      return nil
    }

    return PPOParsedAction(
      action: .confirmAddress(address: address, addressId: addressId),
      tierType: .confirmAddress
    )
  }

  private static func actionForSurvey(url: String?) -> PPOParsedAction? {
    guard let url else { return nil }
    return PPOParsedAction(
      action: .completeSurvey(url: url),
      tierType: .openSurvey
    )
  }

  private static func actionForPledgeManagement(url: String?) -> PPOParsedAction? {
    guard let url else { return nil }
    return PPOParsedAction(
      action: .managePledge(url: url),
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
