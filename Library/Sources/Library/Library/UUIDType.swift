import Foundation

public protocol UUIDType {
  var uuidString: String { get }
  init()
}

extension UUID: UUIDType {}
