// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class RichTextVideo: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.RichTextVideo
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<RichTextVideo>>

  public struct MockFields {
    @Field<String>("altText") public var altText
    @Field<AttachedVideo>("asset") public var asset
    @Field<String>("caption") public var caption
    @Field<String>("url") public var url
  }
}

public extension Mock where O == RichTextVideo {
  convenience init(
    altText: String? = nil,
    asset: Mock<AttachedVideo>? = nil,
    caption: String? = nil,
    url: String? = nil
  ) {
    self.init()
    _setScalar(altText, for: \.altText)
    _setEntity(asset, for: \.asset)
    _setScalar(caption, for: \.caption)
    _setScalar(url, for: \.url)
  }
}
