import Argo
import Curry
import Runes

public struct MessageThreadEnvelope {
  public let participants: [User]
  public let messages: [Message]
  public let messageThread: MessageThread
}

extension MessageThreadEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<MessageThreadEnvelope> {
    return curry(MessageThreadEnvelope.init)
      <^> json <|| "participants"
      <*> json <|| "messages"
      <*> json <| "message_thread"
  }
}
