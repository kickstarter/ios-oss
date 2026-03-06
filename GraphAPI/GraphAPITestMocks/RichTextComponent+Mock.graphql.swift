// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class RichTextComponent: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.RichTextComponent
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<RichTextComponent>>

  public struct MockFields {
    @Field<[RichTextItem]>("items") public var items
  }
}

public extension Mock where O == RichTextComponent {
  convenience init(
    items: [AnyMock]? = nil
  ) {
    self.init()
    _setList(items, for: \.items)
  }
}
