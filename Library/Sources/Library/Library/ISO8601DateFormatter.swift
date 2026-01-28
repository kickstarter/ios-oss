import Foundation

public extension ISO8601DateFormatter {
  private static var currentCachedFormatter: ISO8601DateFormatter?
  static func cachedFormatter() -> ISO8601DateFormatter {
    let formatter = self.currentCachedFormatter ?? ISO8601DateFormatter()
    self.currentCachedFormatter = formatter
    return formatter
  }
}
