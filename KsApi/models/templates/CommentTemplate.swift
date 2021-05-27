import Foundation

extension Comment {
  public static let template = Comment(
    author: Author(
      id: "AFD8hsfh7gsSf9==",
      imageUrl: "https://ks_.imag/fedrico.jpg",
      isCreator: true,
      name: "Federico Fellini"
    ),
    authorBadges: [.creator],
    body: "Hello World",
    createdAt: Date(timeIntervalSince1970: 1_475_361_415).timeIntervalSince1970,
    id: "89DJa89jdSDJ89sd8==",
    isDeleted: false,
    uid: 12_345,
    replyCount: 2
  )

  public static let deletedTemplate = Comment(
    author: Author(
      id: "AFD8hsfh7gsSf9==",
      imageUrl: "https://ks_.imag/fedrico.jpg",
      isCreator: true,
      name: "Nandi Adams"
    ),
    authorBadges: [],
    body: "Hello World",
    createdAt: Date(timeIntervalSince1970: 1_475_361_315).timeIntervalSince1970,
    id: "89DJa89jdSDJ89sd8==",
    isDeleted: true,
    uid: 12_345,
    replyCount: 2
  )

  public static let superbackerTemplate = Comment(
    author: Author(
      id: "ADG8hsfh7gsSf7==",
      imageUrl: "https://ks_.imag/lemwer.jpg",
      isCreator: true,
      name: "KmewrcW"
    ),
    authorBadges: [.superbacker],
    body: "Hi Nimble! Where are you incorporated? Thank you!",
    createdAt: Date(timeIntervalSince1970: 1_475_361_215).timeIntervalSince1970,
    id: "78DJa89jdSDJ89sd8==",
    isDeleted: false,
    uid: 11_445,
    replyCount: 10
  )

  public static let backerTemplate = Comment(
    author: Author(
      id: "ADG8hYbp7gsDAZ==",
      imageUrl: "https://ks/img/cordero.jpg",
      isCreator: false,
      name: "Cordero"
    ),
    authorBadges: [],
    body: "@dave safeuniverse has some sort of obsession. Normal people would say their piece and let it go, and be a lot less hostile towards everyone.",
    createdAt: Date(timeIntervalSince1970: 1_475_361_115).timeIntervalSince1970,
    id: "BOD5af89jdDA4fG==",
    isDeleted: false,
    uid: 11_345,
    replyCount: 0
  )

  public static let failedTemplate = Comment(
    author: Author(
      id: "AKLEhYbp7CDO6E==",
      imageUrl: "https://ks_.img/johnson.jpg",
      isCreator: false,
      name: "Maribeth Bainbridge"
    ),
    authorBadges: [.you],
    body: "It is true what SafeUniverse is saying Doug. To do business in NY you have to be a registered business in NY even if you are registered in another state. What can Nimble provide to show they are registered in NY SafeUniverse?",
    createdAt: Date(timeIntervalSince1970: 1_475_361_100).timeIntervalSince1970,
    id: "78DJa89jdSDJ89sd8==",
    isDeleted: false,
    isFailed: true,
    uid: 11_245,
    replyCount: 15
  )

  public static let templates: [Comment] = [
    .template,
    .deletedTemplate,
    .superbackerTemplate,
    .backerTemplate,
    .failedTemplate
  ]
}

extension Comment {
  public static func template(for badge: Author.AuthorBadge) -> Comment {
    switch badge {
    case .creator:
      return .template
    case .backer:
      return .backerTemplate
    case .superbacker:
      return Comment.superbackerTemplate
    case .you:
      return Comment.failedTemplate
    }
  }
}

extension Comment.Author {
  public static let template = Comment.Author(
    id: "1",
    imageUrl: "http://www.kickstarter.com/large.jpg",
    isCreator: false,
    name: "Nino Teixeira"
  )
}
