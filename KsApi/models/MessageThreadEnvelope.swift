import Curry
import Runes

public struct MessageThreadEnvelope {
  public let participants: [User]
  public let messages: [Message]
  public let messageThread: MessageThread
}

extension MessageThreadEnvelope: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case participants = "participants"
    case messages = "messages"
    case messageThread = "message_thread"
  }
}

/*
extension MessageThreadEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<MessageThreadEnvelope> {
    return curry(MessageThreadEnvelope.init)
      <^> json <|| "participants"
      <*> json <|| "messages"
      <*> json <| "message_thread"
  }
}
 */
