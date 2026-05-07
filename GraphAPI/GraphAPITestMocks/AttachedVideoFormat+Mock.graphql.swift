// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class AttachedVideoFormat: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.AttachedVideoFormat
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<AttachedVideoFormat>>

  public struct MockFields {
    @Field<String>("encoding") public var encoding
    @Field<String>("height") public var height
    @Field<String>("profile") public var profile
    @Field<String>("url") public var url
    @Field<String>("width") public var width
  }
}

public extension Mock where O == AttachedVideoFormat {
  convenience init(
    encoding: String? = nil,
    height: String? = nil,
    profile: String? = nil,
    url: String? = nil,
    width: String? = nil
  ) {
    self.init()
    _setScalar(encoding, for: \.encoding)
    _setScalar(height, for: \.height)
    _setScalar(profile, for: \.profile)
    _setScalar(url, for: \.url)
    _setScalar(width, for: \.width)
  }
}
