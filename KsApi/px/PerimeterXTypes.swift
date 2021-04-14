import Foundation
import PerimeterX

// MARK: - PerimeterXClientType

public protocol PerimeterXClientType: ErrorHandler {
  /// Returns an optional `HTTPCookie` for use in authenticating web views to Perimeter X.
  var cookie: HTTPCookie? { get }

  /// Returns a dictionary of `[String: String]`, representing httpHeaders from Perimeter X.
  func headers() -> [String: String]
}

// MARK: - PerimeterXManagerType

public protocol PerimeterXManagerType {
  func checkError(_ responseJson: [AnyHashable: Any]!) -> PerimeterXBlockResponseType?
  func getVid() -> String!
  func httpHeaders() -> [AnyHashable: Any]!
}

extension PXManager: PerimeterXManagerType {
  public func checkError(_ responseJson: [AnyHashable: Any]!) -> PerimeterXBlockResponseType? {
    self.checkError(responseJson) as PerimeterXBlockResponseType
  }
}

// MARK: - PerimeterXBlockResponseType

public protocol PerimeterXBlockResponseType {
  var type: PXBlockType { get }
}

extension PXBlockResponse: PerimeterXBlockResponseType {}
