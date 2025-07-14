// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class VideoSourceInfo: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.VideoSourceInfo
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<VideoSourceInfo>>

  public struct MockFields {
    @Field<String>("src") public var src
  }
}

public extension Mock where O == VideoSourceInfo {
  convenience init(
    src: String? = nil
  ) {
    self.init()
    _setScalar(src, for: \.src)
  }
}
