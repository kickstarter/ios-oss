// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class SignInWithApplePayload: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.SignInWithApplePayload
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<SignInWithApplePayload>>

  public struct MockFields {
    @Field<String>("apiAccessToken") public var apiAccessToken
    @Field<User>("user") public var user
  }
}

public extension Mock where O == SignInWithApplePayload {
  convenience init(
    apiAccessToken: String? = nil,
    user: Mock<User>? = nil
  ) {
    self.init()
    _setScalar(apiAccessToken, for: \.apiAccessToken)
    _setEntity(user, for: \.user)
  }
}
