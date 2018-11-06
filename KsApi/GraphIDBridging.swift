import Foundation

public protocol GraphIDBridging {
  static var modelName: String { get }
  var graphID: String { get }
  var id: Int { get }
}

extension GraphIDBridging {
  public var graphID: String {
    //swiftlint:disable:next force_unwrapping
    return "\(type(of: self).modelName)-\(self.id)".data(using: .utf8)!.base64EncodedString()
  }
}
