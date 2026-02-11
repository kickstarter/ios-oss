import Foundation

public extension TimeInterval {
  func toISO8601DateTimeString() -> String {
    return ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: self))
  }

  static func from(ISO8601DateTimeString string: String) -> TimeInterval? {
    return ISO8601DateFormatter().date(from: string)?.timeIntervalSince1970
  }
}
