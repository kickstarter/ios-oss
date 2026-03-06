// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class RichTextListOpen: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.RichTextListOpen
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<RichTextListOpen>>

  public struct MockFields {
    @Field<Bool>("_present") public var _present
  }
}

public extension Mock where O == RichTextListOpen {
  convenience init(
    _present: Bool? = nil
  ) {
    self.init()
    _setScalar(_present, for: \._present)
  }
}
