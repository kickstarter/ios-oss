import ApolloTestSupport
import GraphAPI
import GraphAPITestMocks
@testable import KsApi

extension GraphAPITestMocks.User {
  static var mock: Mock<GraphAPITestMocks.User> {
    let user = Mock<GraphAPITestMocks.User>()
    user.uid = "999"
    user.id = "dXNlci0xMjM0NQ=="
    user.name = "The Backer"
    user.imageUrl = "http://ksr.com/an-image.jpg"
    user.isFacebookConnected = false
    user.isFollowing = false
    user.isBlocked = false
    user.needsFreshFacebookToken = false
    user.backingsCount = 10
    user.createdProjects = Mock<UserCreatedProjectsConnection>(totalCount: 0)
    user.location = GraphAPITestMocks.Location.mock
    return user
  }
}
