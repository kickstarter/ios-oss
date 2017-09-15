import Argo
import Curry
import Runes

public struct MessageThreadsEnvelope {
  public private(set) var messageThreads: [MessageThread]
  public private(set) var urls: UrlsEnvelope

  public struct UrlsEnvelope {
    public private(set) var api: ApiEnvelope

    public struct ApiEnvelope {
      public private(set) var moreMessageThreads: String
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
