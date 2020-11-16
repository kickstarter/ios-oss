import Foundation

public struct ClearUserUnseenActivityEnvelope {
  public var activityIndicatorCount: Int
}

extension ClearUserUnseenActivityEnvelope: Decodable {
  enum CodingKeys: String, CodingKey {
    case clearUserUnseenActivity
    case activityIndicatorCount
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.activityIndicatorCount = try values
      .nestedContainer(keyedBy: CodingKeys.self, forKey: .clearUserUnseenActivity)
      .decode(Int.self, forKey: .activityIndicatorCount)
  }
}
