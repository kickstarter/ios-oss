import Foundation

public struct LastWave {
  public let id: Int
  public let active: Bool
}

extension LastWave: Decodable {
  enum CodingKeys: String, CodingKey {
    case id
    case active
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try values.decodeIfPresent(Int.self, forKey: .id) ?? 0
    self.active = try values.decodeIfPresent(Bool.self, forKey: .active) ?? false
  }
}
