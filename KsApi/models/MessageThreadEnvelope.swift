import Argo
import Curry
import Runes

public struct MessageThreadEnvelope {
  public private(set) var participants: [User]
  public private(set) var messages: [Message]
  public private(set) var messageThread: MessageThread
}

extension MessageThreadEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<MessageThreadEnvelope> {
    return curry(MessageThreadEnvelope.init)
      <^> json <|| "participants"
      <*> json <|| "messages"
      <*> json <| "message_thread"
  }
}
