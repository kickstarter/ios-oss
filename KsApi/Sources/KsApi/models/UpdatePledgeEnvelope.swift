

public struct UpdatePledgeEnvelope {
  public let newCheckoutUrl: String?
  public let status: Int
}

extension UpdatePledgeEnvelope: Decodable {
  private enum CodingKeys: String, CodingKey {
    case data
    case status
  }

  enum NestedCodingKeys: String, CodingKey {
    case newCheckoutUrl = "new_checkout_url"
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    if let nestedValues = try? values.nestedContainer(keyedBy: NestedCodingKeys.self, forKey: .data) {
      self.newCheckoutUrl = try nestedValues.decodeIfPresent(String.self, forKey: .newCheckoutUrl)
    } else {
      self.newCheckoutUrl = nil
    }
    if let stringStatus = try? values.decode(String.self, forKey: .status) {
      self.status = stringToIntOrZero(stringStatus)
    } else {
      self.status = try values.decode(Int.self, forKey: .status)
    }
  }
}

private func stringToIntOrZero(_ string: String) -> Int {
  return
    Double(string).flatMap(Int.init)
      ?? Int(string)
      ?? 0
}
