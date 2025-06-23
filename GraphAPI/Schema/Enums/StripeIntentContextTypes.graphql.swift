// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension GraphAPI {
  /// Different contexts for which stripe intents can be created
  enum StripeIntentContextTypes: String, EnumType {
    case crowdfundingCheckout = "CROWDFUNDING_CHECKOUT"
    case postCampaignCheckout = "POST_CAMPAIGN_CHECKOUT"
    case projectBuild = "PROJECT_BUILD"
    case profileSettings = "PROFILE_SETTINGS"
  }

}