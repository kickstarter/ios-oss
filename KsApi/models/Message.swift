import Argo
import Curry
import Runes
import Foundation

public struct Message {
  public let body: String
  public let createdAt: TimeInterval
  public let id: Int
  public let recipient: User
  public let sender: User
}

extension Message: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Message> {
    let create = curry(Message.init)
    return create
      <^> json <| "body"
      <*> json <| "created_at"
      <*> json <| "id"
      <*> json <| "recipient"
      <*> json <| "sender"
  }
}
