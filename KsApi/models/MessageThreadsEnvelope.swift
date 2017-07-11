import Argo
import Curry
import Runes

public struct MessageThreadsEnvelope {
  public let messageThreads: [MessageThread]
  public let urls: UrlsEnvelope

  public struct UrlsEnvelope {
    public let api: ApiEnvelope

    public struct ApiEnvelope {
      public let moreMessageThreads: String
    }
  }
}

extension MessageThreadsEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<MessageThreadsEnvelope> {
    return curry(MessageThreadsEnvelope.init)
      <^> json <|| "message_threads"
      <*> json <| "urls"
  }
}

extension MessageThreadsEnvelope.UrlsEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<MessageThreadsEnvelope.UrlsEnvelope> {
    return curry(MessageThreadsEnvelope.UrlsEnvelope.init)
      <^> json <| "api"
  }
}

extension MessageThreadsEnvelope.UrlsEnvelope.ApiEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<MessageThreadsEnvelope.UrlsEnvelope.ApiEnvelope> {
    return curry(MessageThreadsEnvelope.UrlsEnvelope.ApiEnvelope.init)
      <^> json <| "more_message_threads"
  }
}
