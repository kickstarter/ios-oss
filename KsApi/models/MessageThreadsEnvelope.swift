import Curry
import Runes

public struct MessageThreadsEnvelope: Swift.Decodable {
  public let messageThreads: [MessageThread]
  public let urls: UrlsEnvelope

  enum CodingKeys: String, CodingKey {
    case messageThreads = "message_threads"
    case urls
  }

  public struct UrlsEnvelope: Swift.Decodable {
    public let api: ApiEnvelope

    public struct ApiEnvelope: Swift.Decodable {
      public let moreMessageThreads: String

      enum CodingKeys: String, CodingKey {
        case moreMessageThreads = "more_message_threads"
      }
    }
  }
}

/*
 extension MessageThreadsEnvelope: Decodable {
 public static func decode(_ json: JSON) -> Decoded<MessageThreadsEnvelope> {
   return curry(MessageThreadsEnvelope.init)
     <^> json <|| "message_threads"
     <*> json <| "urls"
 }
 }

 extension MessageThreadsEnvelope.UrlsEnvelope: Decodable {
 public static func decode(_ json: JSON) -> Decoded<MessageThreadsEnvelope.UrlsEnvelope> {
   return curry(MessageThreadsEnvelope.UrlsEnvelope.init)
     <^> json <| "api"
 }
 }

 extension MessageThreadsEnvelope.UrlsEnvelope.ApiEnvelope: Decodable {
 public static func decode(_ json: JSON) -> Decoded<MessageThreadsEnvelope.UrlsEnvelope.ApiEnvelope> {
   return curry(MessageThreadsEnvelope.UrlsEnvelope.ApiEnvelope.init)
     <^> json <| "more_message_threads"
 }
 }
 */
