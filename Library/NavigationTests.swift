import KsApi
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

    KSRAssertMatch(
      .project(.slug("project"), .root, refInfo: nil),
      "/projects/creator/project"
    )

    KSRAssertMatch(nil, "/projects/creator/project?token=4")

    KSRAssertMatch(nil, "/projects/creator/project?ref=discovery&token=4")

    KSRAssertMatch(
      .project(.slug("project"), .checkout(1, .thanks(racing: nil)), refInfo: nil),
      "/projects/creator/project/checkouts/1/thanks"
    )

    KSRAssertMatch(
      .project(.slug("project"), .checkout(1, .thanks(racing: true)), refInfo: nil),
      "/projects/creator/project/checkouts/1/thanks?racing=1"
    )

    KSRAssertMatch(
      .project(.slug("project"), .root, refInfo: RefInfo(.discovery)),
      "/projects/creator/project?ref=discovery"
    )

    KSRAssertMatch(
      .project(.slug("project"), .comments, refInfo: nil),
      "/projects/creator/project/comments"
    )

    KSRAssertMatch(
      .project(.slug("project"), .commentThread("dead", nil), refInfo: nil),
      "/projects/creator/project/comments?comment=dead"
    )

    KSRAssertMatch(
      .project(.slug("project"), .commentThread("dead", "beef"), refInfo: nil),
      "/projects/creator/project/comments?comment=dead&reply=beef"
    )

    KSRAssertMatch(
      .project(.slug("project"), .creatorBio, refInfo: nil),
      "/projects/creator/project/creator_bio"
    )

    KSRAssertMatch(
      .project(.slug("project"), .root, refInfo: nil),
      "/projects/creator/project/description"
    )

    KSRAssertMatch(
      .project(.slug("project"), .friends, refInfo: nil),
      "/projects/creator/project/friends"
    )

    KSRAssertMatch(
      .project(.slug("project"), .pledge(.bigPrint), refInfo: nil),
      "/projects/creator/project/pledge/big_print"
    )

    KSRAssertMatch(
      .project(.slug("project"), .pledge(.changeMethod), refInfo: nil),
      "/projects/creator/project/pledge/change_method"
    )

    KSRAssertMatch(
      .project(.slug("project"), .pledge(.destroy), refInfo: nil),
      "/projects/creator/project/pledge/destroy"
    )

    KSRAssertMatch(
      .project(.slug("project"), .pledge(.edit), refInfo: nil),
      "/projects/creator/project/pledge/edit"
    )

    KSRAssertMatch(
      .project(.slug("project"), .pledge(.new), refInfo: nil),
      "/projects/creator/project/pledge/new"
    )

    KSRAssertMatch(
      .project(.slug("project"), .pledge(.root), refInfo: nil),
      "/projects/creator/project/pledge"
    )

    KSRAssertMatch(
      .project(.slug("project"), .pledge(.manage), refInfo: RefInfo(.emailBackerFailedTransaction)),
      "/projects/creator/project/pledge?ref=ksr_email_backer_failed_transaction"
    )

    KSRAssertMatch(
      .project(.slug("project"), .updates, refInfo: nil),
      "/projects/creator/project/posts"
    )

    KSRAssertMatch(
      .project(.slug("project"), .update(1, .root), refInfo: nil),
      "/projects/creator/project/posts/1"
    )

    KSRAssertMatch(
      .project(.slug("project"), .update(2, .comments), refInfo: nil),
      "/projects/creator/project/posts/2/comments"
    )

    KSRAssertMatch(
      .project(.slug("project"), .update(2, .commentThread("dead", nil)), refInfo: nil),
      "/projects/creator/project/posts/2/comments?comment=dead"
    )

    KSRAssertMatch(
      .project(.slug("project"), .update(2, .commentThread("dead", "beef")), refInfo: nil),
      "/projects/creator/project/posts/2/comments?comment=dead&reply=beef"
    )

    KSRAssertMatch(
      .project(.slug("project"), .survey(3), refInfo: nil),
      "/projects/creator/project/surveys/3"
    )

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

    KSRAssertMatch(
      .project(.slug("project"), .messageCreator, refInfo: nil),
      "/projects/creator/project/messages/new"
    )

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
    let projectRoute = Navigation
      .match(URL(string: "ksr://www.kickstarter.com/projects/creator/project")!)

    XCTAssertNotNil(projectRoute)
    XCTAssertEqual(.project(.slug("project"), .root, refInfo: nil), projectRoute)
  }
}
