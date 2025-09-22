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

  public static func projectAlertTypes() -> [PPOTierType] {
    return [
      .fixPayment,
      .confirmAddress,
      .openSurvey,
      .authenticateCard,
      .pledgeManagement
    ]
  }
}
