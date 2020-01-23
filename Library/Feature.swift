import Foundation

public enum Feature: String {
  case goRewardless = "ios_go_rewardless"
  case qualtrics = "ios_qualtrics"
}

extension Feature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .goRewardless: return "Go Rewardless"
    case .qualtrics: return "Qualtrics"
    }
  }
}
