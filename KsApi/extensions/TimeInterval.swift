import Foundation

public extension TimeInterval {
  static func from(ISO8601DateTimeString string: String) -> TimeInterval? {
    return ISO8601DateFormatter().date(from: string)?.timeIntervalSince1970
  }
}
