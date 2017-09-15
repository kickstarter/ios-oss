import Argo
import Curry
import Runes

public struct FindFriendsEnvelope {
  public private(set) var contactsImported: Bool
  public private(set) var urls: UrlsEnvelope
  public private(set) var users: [User]

  public struct UrlsEnvelope {
    public private(set) var api: ApiEnvelope

    public struct ApiEnvelope {
      public private(set) var moreUsers: String?
    }
  }
}

extension FindFriendsEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<FindFriendsEnvelope> {
    return curry(FindFriendsEnvelope.init)
      <^> json <|   "contacts_imported"
      <*> json <|   "urls"
      <*> (json <|| "users" <|> .success([]))
  }
}

extension FindFriendsEnvelope.UrlsEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<FindFriendsEnvelope.UrlsEnvelope> {
    return curry(FindFriendsEnvelope.UrlsEnvelope.init)
      <^> json <| "api"
  }
}

extension FindFriendsEnvelope.UrlsEnvelope.ApiEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<FindFriendsEnvelope.UrlsEnvelope.ApiEnvelope> {
    return curry(FindFriendsEnvelope.UrlsEnvelope.ApiEnvelope.init)
      <^> json <|? "more_users"
  }
}
