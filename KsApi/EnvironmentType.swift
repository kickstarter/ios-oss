import Foundation

public enum EnvironmentType: String, CaseIterable {
  case production = "Production"
  case staging = "Staging"
  case development = "Development"
  case local = "Local"

  public var stripePublishableKey: String {
    switch self {
    case .production:
      return Secrets.StripePublishableKey.production
    case .staging, .development, .local:
      return Secrets.StripePublishableKey.staging
    }
  }
}
