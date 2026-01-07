import Foundation

public enum Feature: String, CaseIterable {
  case segment = "ios_segment"
}

extension Feature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .segment: return "Segment"
    }
  }
}
