import Argo

public extension Decodable {
  /**
   Decode a JSON dictionary into a `Decoded` type.

   - parameter json: A dictionary with string keys.

   - returns: A decoded value.
   */
  public static func decodeJSONDictionary(_ json: [String:Any]) -> Decoded<DecodedType> {
    return Self.decode(JSON(json))
  }
}
