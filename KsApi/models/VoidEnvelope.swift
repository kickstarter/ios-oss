import Argo

public struct VoidEnvelope {
}

extension VoidEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<VoidEnvelope> {
    return .success(VoidEnvelope())
  }
}
