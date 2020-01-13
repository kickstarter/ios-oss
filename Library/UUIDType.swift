import Foundation

public protocol UUIDType {
  var uuidString: String { get }
}

extension UUID: UUIDType {}
