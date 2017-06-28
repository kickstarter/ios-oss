import Argo
import Curry
import Runes

public struct FindFriendsEnvelope {
  public let contactsImported: Bool
  public let urls: UrlsEnvelope
  public let users: [User]

  public struct UrlsEnvelope {
    public let api: ApiEnvelope

    public struct ApiEnvelope {
      public let moreUsers: String?
    }
  }
}

extension FindFriendsEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<FindFriendsEnvelope> {
    return curry(FindFriendsEnvelope.init)
      <^> json <|   "contacts_imported"
      <*> json <|   "urls"
      <*> (json <|| "users" <|> .success([]))
  }
}

extension FindFriendsEnvelope.UrlsEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<FindFriendsEnvelope.UrlsEnvelope> {
    return curry(FindFriendsEnvelope.UrlsEnvelope.init)
      <^> json <| "api"
  }
}

extension FindFriendsEnvelope.UrlsEnvelope.ApiEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<FindFriendsEnvelope.UrlsEnvelope.ApiEnvelope> {
    return curry(FindFriendsEnvelope.UrlsEnvelope.ApiEnvelope.init)
      <^> json <|? "more_users"
  }
}
