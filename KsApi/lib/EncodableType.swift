import Foundation

/**
 A type that can encode itself into a `[String:Any]` dictionary, usually for then
 serializing to a JSON string.
*/
public protocol EncodableType {
  func encode() -> [String: Any]
}

public extension EncodableType {
  /**
   Returns `NSData` form of encoding.

   - returns: `NSData`
   */
  public func toJSONData() -> Data? {
    return try? JSONSerialization.data(withJSONObject: encode(), options: [])
  }

  /**
   Returns `String` form of encoding.

   - returns: `String`
   */
  public func toJSONString() -> String? {
    return self.toJSONData().flatMap { String(data: $0, encoding: .utf8) }
  }
}
