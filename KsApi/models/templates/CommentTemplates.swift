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
    replyCount: 2,
    status: .success
  )

  public static let collaboratorTemplate = Comment(
    author: Author(
      id: "ERShsfh7gsS34==",
      imageUrl: "https://ks_.imag/fedrico.jpg",
      isCreator: false,
      name: "Dre' Anata"
    ),
    authorBadges: [.collaborator],
    body: "I'm a collaborator.",
    createdAt: Date(timeIntervalSince1970: 1_475_361_415).timeIntervalSince1970,
    id: "89DJa89jdSDJ89sd8==",
    isDeleted: false,
    replyCount: 2,
    status: .success
  )

  public static let replyTemplate = Comment(
    author: Author(
      id: "1",
      imageUrl: "http://www.kickstarter.com/medium.jpg",
      isCreator: true,
      name: "Blob"
    ),
    authorBadges: [.creator],
    body: "Hello World",
    createdAt: Date(timeIntervalSince1970: 1_475_361_415).timeIntervalSince1970,
    id: "89DJa89jdSDJ89sd8==",
    isDeleted: false,
    parentId: "Q29tbWVudC0zMjY2NDAxMg==",
    replyCount: 0,
    status: .success
  )

  public static let replyFailedTemplate = Comment(
    author: Author(
      id: "1",
      imageUrl: "http://www.kickstarter.com/medium.jpg",
      isCreator: true,
      name: "Blob"
    ),
    authorBadges: [.superbacker],
    body: "Hello World",
    createdAt: Date(timeIntervalSince1970: 1_475_361_415).timeIntervalSince1970,
    id: "89DJa89jdS4J89sd8==",
    isDeleted: false,
    parentId: "Q29tbWVudC0zMjY2NDAxMg==",
    replyCount: 0,
    status: .failed
  )

  public static let replyRootCommentTemplate = Comment(
    author: Author(
      id: "AFD8hsfh7gsSf9==",
      imageUrl: "https://ks_.imag/fedrico.jpg",
      isCreator: true,
      name: "Federico Fellini"
    ),
    authorBadges: [.creator],
    body: "Hello World",
    createdAt: Date(timeIntervalSince1970: 1_475_361_415).timeIntervalSince1970,
    id: "Q29tbWVudC0zMjY2NDAxMg==",
    isDeleted: false,
    parentId: nil,
    replyCount: 2,
    status: .success
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
    replyCount: 2,
    status: .success
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
    replyCount: 10,
    status: .success
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
    replyCount: 0,
    status: .success
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
    replyCount: 15,
    status: .failed
  )

  public static let retryingTemplate = Comment(
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
    replyCount: 15,
    status: .retrying
  )

  public static let retrySuccessTemplate = Comment(
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
    replyCount: 4,
    status: .retrySuccess
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
  public static func template(for badge: AuthorBadge) -> Comment {
    switch badge {
    case .collaborator:
      return .collaboratorTemplate
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
