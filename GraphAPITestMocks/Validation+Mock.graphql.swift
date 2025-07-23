// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class Validation: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.Validation
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Validation>>

  public struct MockFields {
    @Field<[String]>("messages") public var messages
    @Field<Bool>("valid") public var valid
  }
}

public extension Mock where O == Validation {
  convenience init(
    messages: [String]? = nil,
    valid: Bool? = nil
  ) {
    self.init()
    _setScalarList(messages, for: \.messages)
    _setScalar(valid, for: \.valid)
  }
}
