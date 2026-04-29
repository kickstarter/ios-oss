// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class VideoFeedItem: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.VideoFeedItem
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<VideoFeedItem>>

  public struct MockFields {
    @Field<[Badge]>("badges") public var badges
    @Field<Project>("project") public var project
  }
}

public extension Mock where O == VideoFeedItem {
  convenience init(
    badges: [Mock<Badge>]? = nil,
    project: Mock<Project>? = nil
  ) {
    self.init()
    _setList(badges, for: \.badges)
    _setEntity(project, for: \.project)
  }
}
