// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class AttachedVideo: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.AttachedVideo
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<AttachedVideo>>

  public struct MockFields {
    @Field<[AttachedVideoFormat?]>("formats") public var formats
    @Field<GraphAPI.ID>("id") public var id
    @Field<String>("poster") public var poster
  }
}

public extension Mock where O == AttachedVideo {
  convenience init(
    formats: [Mock<AttachedVideoFormat>?]? = nil,
    id: GraphAPI.ID? = nil,
    poster: String? = nil
  ) {
    self.init()
    _setList(formats, for: \.formats)
    _setScalar(id, for: \.id)
    _setScalar(poster, for: \.poster)
  }
}
