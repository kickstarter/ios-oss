import Foundation

public struct GraphUser: Swift.Decodable {

  public let email: String

  public struct Me: Swift.Decodable {
    public let email: String
  }

  public init (email: String) {
    self.email = email
  }
}

extension GraphUser {

  private enum CodingKeys: String, CodingKey {
    case me, email
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.email = try values.decode(GraphUser.Me.self, forKey: .me).email
  }
}
