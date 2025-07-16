// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class Notification: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.Notification
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Notification>>

  public struct MockFields {
    @Field<Bool>("email") public var email
    @Field<Bool>("mobile") public var mobile
    @Field<GraphQLEnum<GraphAPI.UserNotificationTopic>>("topic") public var topic
  }
}

public extension Mock where O == Notification {
  convenience init(
    email: Bool? = nil,
    mobile: Bool? = nil,
    topic: GraphQLEnum<GraphAPI.UserNotificationTopic>? = nil
  ) {
    self.init()
    _setScalar(email, for: \.email)
    _setScalar(mobile, for: \.mobile)
    _setScalar(topic, for: \.topic)
  }
}
