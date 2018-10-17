import Foundation

public struct GraphUserEmail: Swift.Decodable {

  public let email: String

  public struct Me: Swift.Decodable {
    public let email: String
  }

  public init (email: String) {
    self.email = email
  }
}

extension GraphUserEmail {

  private enum CodingKeys: String, CodingKey {
    case me, email
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.email = try values.decode(GraphUserEmail.Me.self, forKey: .me).email
  }
}
