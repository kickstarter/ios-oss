

public struct BrazePushEnvelope {
  public let abURI: String?
}

extension BrazePushEnvelope: Decodable {
  enum CodingKeys: String, CodingKey {
    case abURI = "ab_uri"
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.abURI = try values.decodeIfPresent(String.self, forKey: .abURI)
  }
}
