// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class VideoSources: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.VideoSources
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<VideoSources>>

  public struct MockFields {
    @Field<VideoSourceInfo>("high") public var high
    @Field<VideoSourceInfo>("hls") public var hls
  }
}

public extension Mock where O == VideoSources {
  convenience init(
    high: Mock<VideoSourceInfo>? = nil,
    hls: Mock<VideoSourceInfo>? = nil
  ) {
    self.init()
    _setEntity(high, for: \.high)
    _setEntity(hls, for: \.hls)
  }
}
