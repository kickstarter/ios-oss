// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class Video: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.Video
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Video>>

  public struct MockFields {
    @Field<GraphAPI.ID>("id") public var id
    @Field<String>("previewImageUrl") public var previewImageUrl
    @Field<VideoSources>("videoSources") public var videoSources
  }
}

public extension Mock where O == Video {
  convenience init(
    id: GraphAPI.ID? = nil,
    previewImageUrl: String? = nil,
    videoSources: Mock<VideoSources>? = nil
  ) {
    self.init()
    _setScalar(id, for: \.id)
    _setScalar(previewImageUrl, for: \.previewImageUrl)
    _setEntity(videoSources, for: \.videoSources)
  }
}
