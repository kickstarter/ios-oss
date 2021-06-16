import Foundation

public enum Feature: String, CaseIterable {
  case braze = "ios_braze"
  case segment = "ios_segment"
}

extension Feature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .braze: return "Braze"
    case .segment: return "Segment"
    }
  }
}
