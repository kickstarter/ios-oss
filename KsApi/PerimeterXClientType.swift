import Foundation

public protocol PerimeterXClientType: ErrorHandler {
  /**
   Returns a dictionary of `[String: String]`, representing httpHeaders from Perimeter X.
   */
  func headers() -> [String: String]
}
