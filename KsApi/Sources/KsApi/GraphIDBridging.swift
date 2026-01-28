import Foundation

public protocol GraphIDBridging {
  static var modelName: String { get }
  var graphID: String { get }
  var id: Int { get }
}

extension GraphIDBridging {
  public var graphID: String {
    return Data("\(type(of: self).modelName)-\(self.id)".utf8).base64EncodedString()
  }
}
