// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class RichTextAudio: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.RichTextAudio
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<RichTextAudio>>

  public struct MockFields {
    @Field<String>("altText") public var altText
    @Field<AttachedAudio>("asset") public var asset
    @Field<String>("caption") public var caption
    @Field<String>("url") public var url
  }
}

public extension Mock where O == RichTextAudio {
  convenience init(
    altText: String? = nil,
    asset: Mock<AttachedAudio>? = nil,
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
