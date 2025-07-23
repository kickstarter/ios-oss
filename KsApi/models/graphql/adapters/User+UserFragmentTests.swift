import ApolloTestSupport
import Foundation
import GraphAPI
import GraphAPITestMocks
@testable import KsApi
import XCTest

final class User_UserFragmentTests: XCTestCase {
  func testUserCreation_FromFragment_Success() {
    let user = User.user(from: self.mockUserFragment())

    XCTAssertEqual(user?.id, 47)
    XCTAssertEqual(user?.avatar.large, "http://www.kickstarter.com/image.jpg")
    XCTAssertEqual(user?.avatar.medium, "http://www.kickstarter.com/image.jpg")
    XCTAssertEqual(user?.avatar.small, "http://www.kickstarter.com/image.jpg")
    XCTAssertEqual(user?.isCreator, true)
    XCTAssertEqual(user?.name, "Billy Bob")
    XCTAssertEqual(user?.erroredBackingsCount, 1)
    XCTAssertTrue(user!.facebookConnected!)
    XCTAssertTrue(user!.isFriend!)
    XCTAssertFalse(user!.isAdmin!)
    XCTAssertEqual(user!.location?.country, "US")
    XCTAssertEqual(user!.location?.displayableName, "Las Vegas, NV")
    XCTAssertEqual(user!.location?.name, "Las Vegas")
    XCTAssertEqual(user!.location?.id, decompose(id: "TG9jYXRpb24tMjQzNjcwNA=="))
    XCTAssertEqual(user!.unseenActivityCount, 1)
    XCTAssertTrue(user!.needsFreshFacebookToken!)
    XCTAssertTrue(user!.showPublicProfile!)
    XCTAssertTrue(user!.optedOutOfRecommendations!)
    XCTAssertEqual(user!.stats.backedProjectsCount!, 1)
    XCTAssertEqual(user!.stats.createdProjectsCount!, 16)
    XCTAssertNil(user!.stats.draftProjectsCount)
    XCTAssertNil(user!.stats.memberProjectsCount)
    XCTAssertEqual(user!.stats.starredProjectsCount!, 11)
    XCTAssertEqual(user!.stats.unansweredSurveysCount!, 2)
    XCTAssertEqual(user!.stats.unreadMessagesCount!, 0)
    XCTAssertTrue(user!.notifications.messages!)
    XCTAssertTrue(user!.notifications.mobileMessages!)
    XCTAssertFalse(user!.notifications.backings!)
    XCTAssertTrue(user!.notifications.mobileBackings!)
    XCTAssertTrue(user!.notifications.creatorDigest!)
    XCTAssertTrue(user!.notifications.updates!)
    XCTAssertTrue(user!.notifications.follower!)
    XCTAssertTrue(user!.notifications.mobileFollower!)
    XCTAssertTrue(user!.notifications.friendActivity!)
    XCTAssertFalse(user!.notifications.mobileFriendActivity!)
    XCTAssertTrue(user!.notifications.comments!)
    XCTAssertTrue(user!.notifications.mobileComments!)
    XCTAssertTrue(user!.notifications.commentReplies!)
    XCTAssertTrue(user!.notifications.mobileComments!)
    XCTAssertTrue(user!.notifications.creatorDigest!)
    XCTAssertFalse(user!.notifications.mobileMarketingUpdate!)
    XCTAssertTrue(user!.newsletters.arts!)
    XCTAssertFalse(user!.newsletters.films!)
    XCTAssertFalse(user!.newsletters.music!)
    XCTAssertFalse(user!.newsletters.invent!)
    XCTAssertFalse(user!.newsletters.games!)
    XCTAssertFalse(user!.newsletters.publishing!)
    XCTAssertFalse(user!.newsletters.promo!)
    XCTAssertFalse(user!.newsletters.weekly!)
    XCTAssertFalse(user!.newsletters.happening!)
    XCTAssertTrue(user!.newsletters.alumni!)
  }

  func mockUserFragment() -> GraphAPI.UserFragment {
    let mock = Mock<GraphAPITestMocks.User>()

    mock.chosenCurrency = "USD"
    mock.backings = Mock<GraphAPITestMocks.UserBackingsConnection>(
      nodes: [
        Mock<GraphAPITestMocks.Backing>(
          errorReason: nil
        ),
        Mock<GraphAPITestMocks.Backing>(
          errorReason: "Something went wrong"
        ),
        Mock<GraphAPITestMocks.Backing>(
          errorReason: nil
        )
      ]
    )
    mock.backingsCount = 1
    mock.email = "m@example.com"
    mock.isAppleConnected = true
    mock.isBlocked = false
    mock.isEmailVerified = false
    mock.isDeliverable = true
    mock.isFacebookConnected = true
    mock.isKsrAdmin = false
    mock.isFollowing = true
    mock.hasPassword = false
    mock.location = Mock<GraphAPITestMocks.Location>(
      country: "US",
      countryName: "United States",
      displayableName: "Las Vegas, NV",
      id: "TG9jYXRpb24tMjQzNjcwNA==",
      name: "Las Vegas"
    )
    mock.isSocializing = true
    mock.notifications = [
      Mock<GraphAPITestMocks.Notification>(
        email: true,
        mobile: true,
        topic: .case(.messages)
      ),
      Mock<GraphAPITestMocks.Notification>(
        email: false,
        mobile: true,
        topic: .case(.backings)
      ),
      Mock<GraphAPITestMocks.Notification>(
        email: true,
        mobile: false,
        topic: .case(.creatorDigest)
      ),
      Mock<GraphAPITestMocks.Notification>(
        email: true,
        mobile: true,
        topic: .case(.updates)
      ),
      Mock<GraphAPITestMocks.Notification>(
        email: true,
        mobile: true,
        topic: .case(.follower)
      ),
      Mock<GraphAPITestMocks.Notification>(
        email: true,
        mobile: false,
        topic: .case(.friendActivity)
      ),
      Mock<GraphAPITestMocks.Notification>(
        email: true,
        mobile: true,
        topic: .case(.friendSignup)
      ),
      Mock<GraphAPITestMocks.Notification>(
        email: true,
        mobile: true,
        topic: .case(.comments)
      ),
      Mock<GraphAPITestMocks.Notification>(
        email: true,
        mobile: true,
        topic: .case(.commentReplies)
      ),
      Mock<GraphAPITestMocks.Notification>(
        email: true,
        mobile: true,
        topic: .case(.creatorEdu)
      ),
      Mock<GraphAPITestMocks.Notification>(
        email: true,
        mobile: false,
        topic: .case(.marketingUpdate)
      ),
      Mock<GraphAPITestMocks.Notification>(
        email: true,
        mobile: true,
        topic: .case(.projectLaunch)
      )
    ]
    mock.createdProjects = Mock<GraphAPITestMocks.UserCreatedProjectsConnection>(
      totalCount: 16
    )

    mock.savedProjects = Mock<GraphAPITestMocks.UserSavedProjectsConnection>(
      totalCount: 11
    )

    mock.showPublicProfile = true
    mock.id = "Q2F0ZWdvcnktNDc="
    mock.imageUrl = "http://www.kickstarter.com/image.jpg"
    mock.isCreator = true
    mock.name = "Billy Bob"
    mock.uid = "47"
    mock.hasUnreadMessages = false
    mock.hasUnseenActivity = true
    mock.surveyResponses = Mock<GraphAPITestMocks.SurveyResponsesConnection>(
      totalCount: 2
    )
    mock.optedOutOfRecommendations = true
    mock.needsFreshFacebookToken = true
    mock.newsletterSubscriptions = Mock<GraphAPITestMocks.NewsletterSubscriptions>(
      alumniNewsletter: true,
      artsCultureNewsletter: true,
      filmNewsletter: false,
      gamesNewsletter: false,
      happeningNewsletter: false,
      inventNewsletter: false,
      musicNewsletter: false,
      promoNewsletter: false,
      publishingNewsletter: false,
      weeklyNewsletter: false
    )

    return GraphAPI.UserFragment.from(mock)
  }
}
