// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class NewsletterSubscriptions: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.NewsletterSubscriptions
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<NewsletterSubscriptions>>

  public struct MockFields {
    @Field<Bool>("alumniNewsletter") public var alumniNewsletter
    @Field<Bool>("artsCultureNewsletter") public var artsCultureNewsletter
    @Field<Bool>("filmNewsletter") public var filmNewsletter
    @Field<Bool>("gamesNewsletter") public var gamesNewsletter
    @Field<Bool>("happeningNewsletter") public var happeningNewsletter
    @Field<Bool>("inventNewsletter") public var inventNewsletter
    @Field<Bool>("musicNewsletter") public var musicNewsletter
    @Field<Bool>("promoNewsletter") public var promoNewsletter
    @Field<Bool>("publishingNewsletter") public var publishingNewsletter
    @Field<Bool>("weeklyNewsletter") public var weeklyNewsletter
  }
}

public extension Mock where O == NewsletterSubscriptions {
  convenience init(
    alumniNewsletter: Bool? = nil,
    artsCultureNewsletter: Bool? = nil,
    filmNewsletter: Bool? = nil,
    gamesNewsletter: Bool? = nil,
    happeningNewsletter: Bool? = nil,
    inventNewsletter: Bool? = nil,
    musicNewsletter: Bool? = nil,
    promoNewsletter: Bool? = nil,
    publishingNewsletter: Bool? = nil,
    weeklyNewsletter: Bool? = nil
  ) {
    self.init()
    _setScalar(alumniNewsletter, for: \.alumniNewsletter)
    _setScalar(artsCultureNewsletter, for: \.artsCultureNewsletter)
    _setScalar(filmNewsletter, for: \.filmNewsletter)
    _setScalar(gamesNewsletter, for: \.gamesNewsletter)
    _setScalar(happeningNewsletter, for: \.happeningNewsletter)
    _setScalar(inventNewsletter, for: \.inventNewsletter)
    _setScalar(musicNewsletter, for: \.musicNewsletter)
    _setScalar(promoNewsletter, for: \.promoNewsletter)
    _setScalar(publishingNewsletter, for: \.publishingNewsletter)
    _setScalar(weeklyNewsletter, for: \.weeklyNewsletter)
  }
}
