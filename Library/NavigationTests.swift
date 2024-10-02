@testable import KsApi
@testable import Library
import Prelude
import XCTest

private func KSRAssertMatch(
  _ expected: Navigation?,
  _ path: String,
  file: StaticString = #file,
  line: UInt = #line
) {
  let baseUrl = AppEnvironment.current.apiService.serverConfig.webBaseUrl.absoluteString
  let match = URL(string: "\(baseUrl)\(path)")
    .flatMap(Navigation.match)

  XCTAssertEqual(expected, match, file: file, line: line)
}

public final class NavigationTests: XCTestCase {
  func testDoesNotRecognizeNonKickstarterURLs() {
    let projectRoute = Navigation
      .match(URL(string: "http://www.face-kickstarter.com/projects/creator/project")!)

    XCTAssertNil(projectRoute)
  }

  func testRecognizesURLs() {
    KSRAssertMatch(
      .checkout(1, .payments(.new)),
      "/checkouts/1/payments/new"
    )

    KSRAssertMatch(
      .checkout(1, .payments(.root)),
      "/checkouts/1/payments"
    )

    KSRAssertMatch(
      .checkout(1, .payments(.useStoredCard)),
      "/checkouts/1/payments/use_stored_card"
    )

    self.assertProjectMatch(path: "/projects/creator/project", navigation: .root)

    KSRAssertMatch(nil, "/projects/creator/project?token=4")

    KSRAssertMatch(nil, "/projects/creator/project?ref=discovery&token=4")

    self.assertProjectMatch(
      path: "/projects/creator/project/checkouts/1/thanks",
      navigation: .checkout(1, .thanks(racing: nil))
    )

    self.assertProjectMatch(
      path: "/projects/creator/project/checkouts/1/thanks?racing=1",
      navigation: .checkout(1, .thanks(racing: true))
    )

    self.assertProjectMatch(
      path: "/projects/creator/project?ref=discovery",
      navigation: .root,
      refTag: .discovery
    )

    self.assertProjectMatch(path: "/projects/creator/project/comments", navigation: .comments)

    self.assertProjectMatch(
      path: "/projects/creator/project/comments?comment=dead",
      navigation: .commentThread("dead", nil)
    )

    self.assertProjectMatch(
      path: "/projects/creator/project/comments?comment=dead&reply=beef",
      navigation: .commentThread("dead", "beef")
    )

    self.assertProjectMatch(path: "/projects/creator/project/creator_bio", navigation: .creatorBio)

    self.assertProjectMatch(path: "/projects/creator/project/description", navigation: .root)

    self.assertProjectMatch(path: "/projects/creator/project/friends", navigation: .friends)

    self.assertProjectMatch(
      path: "/projects/creator/project/pledge/big_print",
      navigation: .pledge(.bigPrint)
    )

    self.assertProjectMatch(
      path: "/projects/creator/project/pledge/change_method",
      navigation: .pledge(.changeMethod)
    )

    self.assertProjectMatch(
      path: "/projects/creator/project/pledge/destroy",
      navigation: .pledge(.destroy)
    )

    self.assertProjectMatch(path: "/projects/creator/project/pledge/edit", navigation: .pledge(.edit))

    self.assertProjectMatch(path: "/projects/creator/project/pledge/new", navigation: .pledge(.new))

    self.assertProjectMatch(path: "/projects/creator/project/pledge", navigation: .pledge(.root))

    self.assertProjectMatch(
      path: "/projects/creator/project/pledge?ref=ksr_email_backer_failed_transaction",
      navigation: .pledge(.manage),
      refTag: .emailBackerFailedTransaction
    )

    self.assertProjectMatch(path: "/projects/creator/project/posts", navigation: .updates)

    self.assertProjectMatch(path: "/projects/creator/project/posts/1", navigation: .update(1, .root))

    self.assertProjectMatch(
      path: "/projects/creator/project/posts/2/comments",
      navigation: .update(2, .comments)
    )

    self.assertProjectMatch(
      path: "/projects/creator/project/posts/2/comments?comment=dead",
      navigation: .update(2, .commentThread("dead", nil))
    )

    self.assertProjectMatch(
      path: "/projects/creator/project/posts/2/comments?comment=dead&reply=beef",
      navigation: .update(2, .commentThread("dead", "beef"))
    )

    withEnvironment(apiService: MockService(serverConfig: ServerConfig.production)) {
      self.assertProjectMatch(
        path: "/projects/creator/project/surveys/3",
        navigation: .surveyWebview("https://www.kickstarter.com/projects/creator/project/surveys/3")
      )
    }

    KSRAssertMatch(
      .signup,
      "/signup"
    )

    KSRAssertMatch(.tab(.discovery(["sort": "newest"])), "/discover?sort=newest")

    KSRAssertMatch(.tab(.discovery(nil)), "/discover/advanced")

    KSRAssertMatch(
      .tab(.discovery(["category_id": "a"])),
      "/discover/categories/a"
    )

    KSRAssertMatch(
      .tab(.discovery(["category_id": "c", "parent_category_id": "b"])),
      "/discover/categories/b/c"
    )

    KSRAssertMatch(
      .tab(.search),
      "/search"
    )

    KSRAssertMatch(
      .tab(.activity),
      "/activity"
    )

    KSRAssertMatch(
      .tab(.me),
      "/profile/me"
    )

    KSRAssertMatch(
      .tab(.login),
      "/authorize"
    )

    self.assertProjectMatch(path: "/projects/creator/project/messages/new", navigation: .messageCreator)

    KSRAssertMatch(
      .user(.slug("self"), .survey(3)),
      "/users/self/surveys/3"
    )

    KSRAssertMatch(
      .profile(.verifyEmail),
      "/profile/verify_email"
    )

    KSRAssertMatch(
      .settings(.notifications("notify_mobile_of_marketing_update", true)),
      "/settings/notify_mobile_of_marketing_update/true"
    )

    KSRAssertMatch(
      .settings(.notifications("notify_mobile_of_messages", false)),
      "/settings/notify_mobile_of_messages/false"
    )
  }

  func testRecognizesEmailClickUrls() {
    XCTAssertEqual(
      .emailClick,
      Navigation.match(URL(string: "https://clicks.kickstarter.com/wf/click?upn=deadbeef")!)
    )

    XCTAssertEqual(
      .emailClick,
      Navigation.match(URL(string: "https://emails.kickstarter.com/anything/?qs=deadbeef")!)
    )

    XCTAssertNil(
      Navigation.match(URL(string: "https://notemailhost.kickstarter.com/wf/click?upn=deadbeef")!)
    )
  }

  func testRecognizesTruncatedUrl() {
    XCTAssertEqual(
      .profile(.verifyEmail),
      Navigation.match(URL(string: "https://kickstarter.com/profile/verify_email")!)
    )
  }

  func testRecognizesKsrUrlScheme() {
    let url = "ksr://www.kickstarter.com/projects/creator/project"
    let projectRoute = Navigation.match(URL(string: url)!)
    let refInfo = RefInfo(nil, deeplinkUrl: url)

    XCTAssertNotNil(projectRoute)
    XCTAssertEqual(.project(.slug("project"), .root, refInfo: refInfo), projectRoute)
  }

  // MARK: - Helpers

  private func refInfoFromPath(_ path: String, refTag: RefTag? = nil) -> RefInfo {
    let baseUrl = AppEnvironment.current.apiService.serverConfig.webBaseUrl.absoluteString
    let url = URL(string: "\(baseUrl)\(path)")
    return RefInfo(refTag, deeplinkUrl: url?.absoluteString)
  }

  private func assertProjectMatch(
    path: String,
    navigation: Navigation.Project,
    refTag: RefTag? = nil
  ) {
    KSRAssertMatch(
      .project(.slug("project"), navigation, refInfo: self.refInfoFromPath(path, refTag: refTag)),
      path
    )
  }
}
