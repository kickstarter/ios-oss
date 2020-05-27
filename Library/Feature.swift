import Foundation

public enum Feature: String {
  case qualtrics = "ios_qualtrics"
}

extension Feature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .qualtrics: return "Qualtrics"
    }
  }
}
