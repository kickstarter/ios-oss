

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
  enum CodingKeys: String, CodingKey {
    case contactsImported = "contacts_imported"
    case urls
    case users
  }
}

extension FindFriendsEnvelope.UrlsEnvelope: Decodable {}

extension FindFriendsEnvelope.UrlsEnvelope.ApiEnvelope: Decodable {
  enum CodingKeys: String, CodingKey {
    case moreUsers = "more_users"
  }
}
