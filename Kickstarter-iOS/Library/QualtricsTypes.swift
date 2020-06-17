import Foundation
import Library
import Qualtrics

public struct QualtricsConfigData: Equatable {
  public let brandId: String
  public let zoneId: String
  public let interceptId: String
  public let stringProperties: [String: String]
}

enum QualtricsIntercept {
  case survey

  var interceptId: String {
    switch AppEnvironment.current.environmentType {
    case .production:
      return "SI_eUKtARDK3785TQF"
    case .development, .local, .staging, .custom:
      return "SI_emv4HRmzWkde0Jf"
    }
  }
}

public protocol QualtricsResultType {
  func passed() -> Bool
}

@objc public protocol QualtricsPropertiesType {
  @objc func setNumber(number: Double, for key: String)
}

extension TargetingResult: QualtricsResultType {}
extension InitializationResult: QualtricsResultType {}
extension QualtricsProperties: QualtricsPropertiesType {}
