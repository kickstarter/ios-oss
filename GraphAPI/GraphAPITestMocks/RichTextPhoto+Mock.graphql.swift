// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class RichTextPhoto: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.RichTextPhoto
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<RichTextPhoto>>

  public struct MockFields {
    @Field<String>("altText") public var altText
    @Field<Photo>("asset") public var asset
    @Field<String>("caption") public var caption
  }
}

public extension Mock where O == RichTextPhoto {
  convenience init(
    altText: String? = nil,
    asset: Mock<Photo>? = nil,
    caption: String? = nil
  ) {
    self.init()
    _setScalar(altText, for: \.altText)
    _setEntity(asset, for: \.asset)
    _setScalar(caption, for: \.caption)
  }
}
