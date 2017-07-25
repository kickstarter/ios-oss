import Prelude

extension FindFriendsEnvelope {
  internal static let template = FindFriendsEnvelope(
    contactsImported: true,
    urls: FindFriendsEnvelope.UrlsEnvelope(
      api: FindFriendsEnvelope.UrlsEnvelope.ApiEnvelope(
        moreUsers: "http://somelink.com/more"
      )
    ),
    users: (1...3).map { User.template |> User.lens.id .~ $0 }
  )
}
