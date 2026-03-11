// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class RichTextListClose: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.RichTextListClose
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<RichTextListClose>>

  public struct MockFields {
    @Field<Bool>("_present") public var _present
  }
}

public extension Mock where O == RichTextListClose {
  convenience init(
    _present: Bool? = nil
  ) {
    self.init()
    _setScalar(_present, for: \._present)
  }
}
