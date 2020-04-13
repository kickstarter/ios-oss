import Argo

public struct VoidEnvelope {}

extension VoidEnvelope: Argo.Decodable {
  public static func decode(_: JSON) -> Decoded<VoidEnvelope> {
    return .success(VoidEnvelope())
  }
}

extension VoidEnvelope: Swift.Decodable {}
