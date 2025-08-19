// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class Tag: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.Tag
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Tag>>

  public struct MockFields {
    @Field<String>("name") public var name
  }
}

public extension Mock where O == Tag {
  convenience init(
    name: String? = nil
  ) {
    self.init()
    _setScalar(name, for: \.name)
  }
}
