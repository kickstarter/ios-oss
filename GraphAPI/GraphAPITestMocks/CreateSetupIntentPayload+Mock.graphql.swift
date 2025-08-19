// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class CreateSetupIntentPayload: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.CreateSetupIntentPayload
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CreateSetupIntentPayload>>

  public struct MockFields {
    @Field<String>("clientSecret") public var clientSecret
  }
}

public extension Mock where O == CreateSetupIntentPayload {
  convenience init(
    clientSecret: String? = nil
  ) {
    self.init()
    _setScalar(clientSecret, for: \.clientSecret)
  }
}
