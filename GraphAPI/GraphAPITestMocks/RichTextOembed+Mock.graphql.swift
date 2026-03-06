// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class RichTextOembed: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.RichTextOembed
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<RichTextOembed>>

  public struct MockFields {
    @Field<String>("authorName") public var authorName
    @Field<String>("authorUrl") public var authorUrl
    @Field<Int>("height") public var height
    @Field<String>("html") public var html
    @Field<String>("iframeUrl") public var iframeUrl
    @Field<String>("originalUrl") public var originalUrl
    @Field<String>("photoUrl") public var photoUrl
    @Field<String>("providerName") public var providerName
    @Field<String>("providerUrl") public var providerUrl
    @Field<Int>("thumbnailHeight") public var thumbnailHeight
    @Field<String>("thumbnailUrl") public var thumbnailUrl
    @Field<Int>("thumbnailWidth") public var thumbnailWidth
    @Field<String>("title") public var title
    @Field<String>("type") public var type
    @Field<String>("version") public var version
    @Field<Int>("width") public var width
  }
}

public extension Mock where O == RichTextOembed {
  convenience init(
    authorName: String? = nil,
    authorUrl: String? = nil,
    height: Int? = nil,
    html: String? = nil,
    iframeUrl: String? = nil,
    originalUrl: String? = nil,
    photoUrl: String? = nil,
    providerName: String? = nil,
    providerUrl: String? = nil,
    thumbnailHeight: Int? = nil,
    thumbnailUrl: String? = nil,
    thumbnailWidth: Int? = nil,
    title: String? = nil,
    type: String? = nil,
    version: String? = nil,
    width: Int? = nil
  ) {
    self.init()
    _setScalar(authorName, for: \.authorName)
    _setScalar(authorUrl, for: \.authorUrl)
    _setScalar(height, for: \.height)
    _setScalar(html, for: \.html)
    _setScalar(iframeUrl, for: \.iframeUrl)
    _setScalar(originalUrl, for: \.originalUrl)
    _setScalar(photoUrl, for: \.photoUrl)
    _setScalar(providerName, for: \.providerName)
    _setScalar(providerUrl, for: \.providerUrl)
    _setScalar(thumbnailHeight, for: \.thumbnailHeight)
    _setScalar(thumbnailUrl, for: \.thumbnailUrl)
    _setScalar(thumbnailWidth, for: \.thumbnailWidth)
    _setScalar(title, for: \.title)
    _setScalar(type, for: \.type)
    _setScalar(version, for: \.version)
    _setScalar(width, for: \.width)
  }
}
