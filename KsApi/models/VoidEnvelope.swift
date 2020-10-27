
public struct VoidEnvelope {}
/*
 extension VoidEnvelope: Decodable {
 public static func decode(_: JSON) -> Decoded<VoidEnvelope> {
   return .success(VoidEnvelope())
 }
 }
 */
extension VoidEnvelope: Swift.Decodable {}
