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
