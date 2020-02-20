import Foundation

public enum OptimizelyExperiment {
  public enum Key: String {
    case pledgeCTACopy = "pledge_cta_copy"
    case nativeProjectPageCampaignDetails = "native_project_page_campaign_details"
  }

  public enum Variant: String, Equatable {
    case control
    case variant1 = "variant-1"
    case variant2 = "variant-2"
  }
}
