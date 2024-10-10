import Combine
import Foundation

public struct PledgedProjectOverviewCardsEnvelope {
  public let cards: [PledgedProjectOverviewCard]
  public let totalCount: Int
  public let cursor: String?
}

private enum PledgedProjectOverviewCardConstants {
  static let paymentFailed = "Tier1PaymentFailed"
  static let confirmAddress = "Tier1AddressLockingSoon"
  static let completeSurvey = "Tier1OpenSurvey"
  static let authenticationRequired = "Tier1PaymentAuthenticationRequired"
}

extension PledgedProjectOverviewCard {
  static func pledgedProjectOverviewCardsProducer(
    from data: GraphAPI.FetchPledgedProjectsQuery.Data
  ) -> AnyPublisher<PledgedProjectOverviewCardsEnvelope, ErrorEnvelope> {
    guard let envelope = PledgedProjectOverviewCard.pledgedProjectOverviewCards(from: data) else {
      return Fail(
        outputType: PledgedProjectOverviewCardsEnvelope.self,
        failure: ErrorEnvelope.couldNotParseJSON
      ).eraseToAnyPublisher()
    }

    return Just(envelope).setFailureType(to: ErrorEnvelope.self).eraseToAnyPublisher()
  }

  static func pledgedProjectOverviewCards(
    from data: GraphAPI.FetchPledgedProjectsQuery
      .Data
  ) -> PledgedProjectOverviewCardsEnvelope? {
    guard
      let pledges = data.pledgeProjectsOverview?.pledges,
      let edges = pledges.edges
    else {
      return nil
    }

    let totalCount = pledges.totalCount
    let cursor = pledges.pageInfo.hasNextPage ? pledges.pageInfo.endCursor : nil
    let cards = edges.compactMap { edge -> PledgedProjectOverviewCard? in
      guard let node = edge?.node else {
        return nil
      }

      let card = node.fragments.ppoCardFragment
      let backing = card.backing?.fragments.ppoBackingFragment
      let ppoProject = backing?.project?.fragments.ppoProjectFragment

      let imageURL = ppoProject?.image?.url
        .flatMap { URL(string: $0) }

      let title = ppoProject?.name
      let pledge = backing?.amount.fragments.moneyFragment
      let creatorName = ppoProject?.creator?.name

      // TODO: Implement [MBL-1695]
      let address: String? = nil

      let alerts: [PledgedProjectOverviewCard.Alert] = card.flags?
        .compactMap { PledgedProjectOverviewCard.Alert(flag: $0) } ?? []

      let primaryAction: PledgedProjectOverviewCard.Action
      let secondaryAction: PledgedProjectOverviewCard.Action?
      let tierType: PledgedProjectOverviewCard.TierType

      switch card.tierType {
      case PledgedProjectOverviewCardConstants.paymentFailed:
        primaryAction = .fixPayment
        secondaryAction = nil
        tierType = .fixPayment
      case PledgedProjectOverviewCardConstants.confirmAddress:
        primaryAction = .confirmAddress
        secondaryAction = .editAddress
        tierType = .confirmAddress
      case PledgedProjectOverviewCardConstants.completeSurvey:
        primaryAction = .completeSurvey
        secondaryAction = nil
        tierType = .openSurvey
      case PledgedProjectOverviewCardConstants.authenticationRequired:
        primaryAction = .authenticateCard
        secondaryAction = nil
        tierType = .authenticateCard
      case .some(_), .none:
        return nil
      }

      let projectAnalyticsFragment = backing?.project?.fragments.projectAnalyticsFragment

      if let imageURL, let title, let pledge, let creatorName, let projectAnalyticsFragment {
        return self.init(
          isUnread: true,
          alerts: alerts,
          imageURL: imageURL,
          title: title,
          pledge: pledge,
          creatorName: creatorName,
          address: address,
          actions: (primaryAction, secondaryAction),
          tierType: tierType,
          projectAnalytics: projectAnalyticsFragment
        )
      } else {
        return nil
      }
    }
    return PledgedProjectOverviewCardsEnvelope(
      cards: cards,
      totalCount: totalCount,
      cursor: cursor
    )
  }
}
