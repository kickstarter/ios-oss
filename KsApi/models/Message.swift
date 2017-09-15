import Argo
import Curry
import Runes
import Foundation

public struct Message {
  public private(set) var body: String
  public private(set) var createdAt: TimeInterval
  public private(set) var id: Int
  public private(set) var recipient: User
  public private(set) var sender: User
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
