import Foundation

public extension TimeInterval {
  func toISO8601DateTimeString() -> String {
    return ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: self))
  }
}
