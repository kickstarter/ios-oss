import Curry
import Foundation
import Runes

public struct Message {
  public let body: String
  public let createdAt: TimeInterval
  public let id: Int
  public let recipient: User
  public let sender: User
}

extension Message: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case body = "body"
    case createdAt = "created_at"
    case id = "id"
    case recipient = "recipient"
    case sender = "sender"
  }
}

extension Message: Decodable {
  public static func decode(_ json: JSON) -> Decoded<Message> {
    return curry(Message.init)
      <^> json <| "body"
      <*> json <| "created_at"
      <*> json <| "id"
      <*> ((json <| "recipient" >>- tryDecodable) as Decoded<User>)
      <*> ((json <| "sender" >>- tryDecodable) as Decoded<User>)
  }
}
