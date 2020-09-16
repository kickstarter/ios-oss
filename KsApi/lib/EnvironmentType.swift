import Foundation

public enum EnvironmentType: CaseIterable, CustomStringConvertible, Equatable {
  case custom(String?)
  case production
  case staging
  case development
  case local

  public init?(rawValue: String) {
    let allCases = EnvironmentType.allCases.filter { c -> Bool in
      if case .custom = c { return false }
      return true
    }

    for envCase in allCases where envCase.description == rawValue {
      self = envCase
      return
    }

    self = .custom(rawValue)
  }

  public var stripePublishableKey: String {
    switch self {
    case .production:
      return Secrets.StripePublishableKey.production
    case .staging, .development, .local, .custom:
      return Secrets.StripePublishableKey.staging
    }
  }

  public static var allCases: [EnvironmentType] {
    return [.custom(nil), .production, .staging, .development, .local]
  }

  public var description: String {
    switch self {
    case let .custom(url):
      return url ?? "Custom"
    case .production:
      return "Production"
    case .staging:
      return "Staging"
    case .development:
      return "Development"
    case .local:
      return "Local"
    }
  }
}
