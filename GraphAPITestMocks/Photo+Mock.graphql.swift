// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class Photo: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.Photo
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Photo>>

  public struct MockFields {
    @Field<String>("altText") public var altText
    @Field<GraphAPI.ID>("id") public var id
    @Field<String>("url") public var url
  }
}

public extension Mock where O == Photo {
  convenience init(
    altText: String? = nil,
    id: GraphAPI.ID? = nil,
    url: String? = nil
  ) {
    self.init()
    _setScalar(altText, for: \.altText)
    _setScalar(id, for: \.id)
    _setScalar(url, for: \.url)
  }
}
