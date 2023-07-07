import Foundation
import PerimeterX_SDK

// MARK: - PerimeterXClientType

public protocol PerimeterXClientType: ErrorHandler {
  /// Returns an optional `HTTPCookie` for use in authenticating web views to Perimeter X.
  var cookie: HTTPCookie? { get }
//  
//  /// Returns an optional `String` cookie VID to Perimeter X.
//  var vid: String? { get }
//  
  /// Returns a dictionary of `[String: String]`, representing httpHeaders from Perimeter X.
  func getPXHeaders() -> [String: String]

  /// Calls the start method to configure the SDK with allowable domains
  func start(policyDomains: Set<String>)
}
