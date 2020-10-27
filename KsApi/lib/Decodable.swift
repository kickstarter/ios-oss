import Foundation

public extension Decodable {
  /**
   Decode a JSON dictionary into a `Decoded` type.

   - parameter json: A dictionary with string keys.

   - returns: A decoded value.
   */
  static func decodeJSONDictionary(_ json: [String: Any]) -> Decoded<DecodedType> {
    return Self.decode(JSON(json))
  }
}

public extension Swift.Decodable {
  
  static func decodeJSONDictionary(_ json: [String: Any]) throws -> Self {
    let data = try JSONSerialization.data(withJSONObject: json, options: [])
    let value = try JSONDecoder().decode(Self.self, from: data)
    return value
  }
  
  static func decodeJSONDictionary(_ json: [String: Any]) -> Self? {
    if let data = try? JSONSerialization.data(withJSONObject: json, options: []),
       let value = try? JSONDecoder().decode(Self.self, from: data){
      return value
    }
    return nil
  }
}
