// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class RichText: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.RichText
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<RichText>>

  public struct MockFields {
    @Field<[RichTextItem]>("children") public var children
    @Field<String>("link") public var link
    @Field<[String]>("styles") public var styles
    @Field<String>("text") public var text
  }
}

public extension Mock where O == RichText {
  convenience init(
    children: [AnyMock]? = nil,
    link: String? = nil,
    styles: [String]? = nil,
    text: String? = nil
  ) {
    self.init()
    _setList(children, for: \.children)
    _setScalar(link, for: \.link)
    _setScalarList(styles, for: \.styles)
    _setScalar(text, for: \.text)
  }
}
