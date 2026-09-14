// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class RichTextOembed: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.RichTextOembed
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<RichTextOembed>>

  public struct MockFields {
    @Field<Int>("height") public var height
    @Field<String>("iframeUrl") public var iframeUrl
    @Field<String>("originalUrl") public var originalUrl
    @Field<String>("title") public var title
    @Field<String>("type") public var type
    @Field<String>("version") public var version
    @Field<Int>("width") public var width
  }
}

public extension Mock where O == RichTextOembed {
  convenience init(
    height: Int? = nil,
    iframeUrl: String? = nil,
    originalUrl: String? = nil,
    title: String? = nil,
    type: String? = nil,
    version: String? = nil,
    width: Int? = nil
  ) {
    self.init()
    _setScalar(height, for: \.height)
    _setScalar(iframeUrl, for: \.iframeUrl)
    _setScalar(originalUrl, for: \.originalUrl)
    _setScalar(title, for: \.title)
    _setScalar(type, for: \.type)
    _setScalar(version, for: \.version)
    _setScalar(width, for: \.width)
  }
}
