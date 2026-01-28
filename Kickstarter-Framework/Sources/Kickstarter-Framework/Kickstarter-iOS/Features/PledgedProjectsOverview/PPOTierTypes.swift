import Foundation
import GraphAPI
import Kingfisher
import KsApi
import Library

public enum PPOTierType: String {
  // Source of truth for enum values can be found at
  // https://github.com/kickstarter/kickstarter/blob/main/app/models/open_search/pledged_projects_overview.rb
  case fixPayment = "Tier1PaymentFailed"
  case confirmAddress = "Tier1AddressLockingSoon"
  case openSurvey = "Tier1OpenSurvey"
  case authenticateCard = "Tier1PaymentAuthenticationRequired"
  case pledgeManagement = "PledgeManagement"

  case surveySubmitted = "SurveySubmitted"
  case pledgeCollected = "PledgeCollected"
  case addressConfirmed = "AddressConfirmed"
  case awaitingReward = "AwaitingReward"
  case rewardReceived = "RewardReceived"

  public static func projectAlertTypes() -> [PPOTierType] {
    return [
      .fixPayment,
      .confirmAddress,
      .openSurvey,
      .authenticateCard,
      .pledgeManagement
    ]
  }

  public static func projectAlertGraphQLTypes() -> [PledgeProjectsOverviewSort] {
    return self.projectAlertTypes().map { $0.toPledgeProjectsOverviewSort() }
  }

  public static func fundedProjectTypes() -> [PPOTierType] {
    return self.projectAlertTypes() + [
      .surveySubmitted,
      .pledgeCollected,
      .addressConfirmed,
      .awaitingReward,
      .rewardReceived
    ]
  }

  public static func fundedProjectGraphQLTypes() -> [PledgeProjectsOverviewSort] {
    return self.fundedProjectTypes().map { $0.toPledgeProjectsOverviewSort() }
  }

  public func toPledgeProjectsOverviewSort() -> PledgeProjectsOverviewSort {
    switch self {
    case .fixPayment: return .tier1PaymentFailed
    case .confirmAddress: return .tier1AddressLockingSoon
    case .openSurvey: return .tier1OpenSurvey
    case .authenticateCard: return .tier1PaymentAuthenticationRequired
    case .pledgeManagement: return .pledgeManagement

    case .surveySubmitted: return .surveySubmitted
    case .pledgeCollected: return .pledgeCollected
    case .addressConfirmed: return .addressConfirmed
    case .awaitingReward: return .awaitingReward
    case .rewardReceived: return .rewardReceived
    }
  }
}
