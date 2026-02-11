import Foundation

public struct PledgeManager {
  public let id: Int
  public let acceptsNewBackers: Bool
}

extension PledgeManager: Decodable {
  enum CodingKeys: String, CodingKey {
    case id
    case acceptsNewBackers
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try values.decodeIfPresent(Int.self, forKey: .id) ?? 0
    self.acceptsNewBackers = try values.decodeIfPresent(Bool.self, forKey: .acceptsNewBackers) ?? false
  }
}
