// swiftlint:disable force_unwrapping
import KsApi
import Prelude
import XCTest
@testable import Library

private func KSRAssertMatch(_ expected: Navigation?,
                            _ path: String,
                            file: StaticString = #file,
                            line: UInt = #line) {

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
    KSRAssertMatch(.checkout(1, .payments(.new)),
                   "/checkouts/1/payments/new")

    KSRAssertMatch(.checkout(1, .payments(.root)),
                   "/checkouts/1/payments")

    KSRAssertMatch(.checkout(1, .payments(.useStoredCard)),
                   "/checkouts/1/payments/use_stored_card")

    KSRAssertMatch(.project(.slug("project"), .root, refTag: nil),
                   "/projects/creator/project")

    KSRAssertMatch(nil, "/projects/creator/project?token=4")

    KSRAssertMatch(nil, "/projects/creator/project?ref=discovery&token=4")

    KSRAssertMatch(.project(.slug("project"), .checkout(1, .thanks(racing: nil)), refTag: nil),
                   "/projects/creator/project/checkouts/1/thanks")

    KSRAssertMatch(.project(.slug("project"), .checkout(1, .thanks(racing: true)), refTag: nil),
                   "/projects/creator/project/checkouts/1/thanks?racing=1")

    KSRAssertMatch(.project(.slug("project"), .root, refTag: .discovery),
                   "/projects/creator/project?ref=discovery")

    KSRAssertMatch(.project(.slug("project"), .comments, refTag: nil),
                   "/projects/creator/project/comments")

    KSRAssertMatch(.project(.slug("project"), .creatorBio, refTag: nil),
                   "/projects/creator/project/creator_bio")

    KSRAssertMatch(.project(.slug("project"), .root, refTag: nil),
                   "/projects/creator/project/description")

    KSRAssertMatch(.project(.slug("project"), .faqs, refTag: nil),
                   "/projects/creator/project/faqs")

    KSRAssertMatch(.project(.slug("project"), .friends, refTag: nil),
                   "/projects/creator/project/friends")

    KSRAssertMatch(.project(.slug("project"), .pledge(.bigPrint), refTag: nil),
                   "/projects/creator/project/pledge/big_print")

    KSRAssertMatch(.project(.slug("project"), .pledge(.changeMethod), refTag: nil),
                   "/projects/creator/project/pledge/change_method")

    KSRAssertMatch(.project(.slug("project"), .pledge(.destroy), refTag: nil),
                   "/projects/creator/project/pledge/destroy")

    KSRAssertMatch(.project(.slug("project"), .pledge(.edit), refTag: nil),
                   "/projects/creator/project/pledge/edit")

    KSRAssertMatch(.project(.slug("project"), .pledge(.new), refTag: nil),
                   "/projects/creator/project/pledge/new")

    KSRAssertMatch(.project(.slug("project"), .pledge(.root), refTag: nil),
                   "/projects/creator/project/pledge")

    KSRAssertMatch(.project(.slug("project"), .updates, refTag: nil),
                   "/projects/creator/project/posts")

    KSRAssertMatch(.project(.slug("project"), .update(1, .root), refTag: nil),
                   "/projects/creator/project/posts/1")

    KSRAssertMatch(.project(.slug("project"), .update(2, .comments), refTag: nil),
                   "/projects/creator/project/posts/2/comments")

    KSRAssertMatch(.project(.slug("project"), .survey(3), refTag: nil),
                   "/projects/creator/project/surveys/3")

    KSRAssertMatch(.signup,
                   "/signup")

    KSRAssertMatch(.tab(.discovery(["sort": "newest"])), "/discover?sort=newest")

    KSRAssertMatch(.tab(.discovery(nil)), "/discover/advanced")

    KSRAssertMatch(.tab(.discovery(["category_id": "a"])),
                   "/discover/categories/a")

    KSRAssertMatch(.tab(.discovery(["category_id": "c", "parent_category_id": "b"])),
                   "/discover/categories/b/c")

    KSRAssertMatch(.tab(.search),
                   "/search")

    KSRAssertMatch(.tab(.activity),
                   "/activity")

    KSRAssertMatch(.tab(.me),
                   "/profile/me")

    KSRAssertMatch(.tab(.login),
                   "/authorize")

    KSRAssertMatch(.project(.slug("project"), .messageCreator, refTag: nil),
                   "/projects/creator/project/messages/new")

    KSRAssertMatch(.tab(.dashboard(project: .slug("project"))),
                   "/projects/creator/project/dashboard")

    KSRAssertMatch(.user(.slug("self"), .survey(3)),
                   "/users/self/surveys/3")
  }

  func testRecognizesEmailClickUrls() {
    let url = URL(string: "https://email.kickstarter.com/mpss/c/2gA/Oiw/t.25j/deadbeef/h1/dead-beef")!
    XCTAssertEqual(.emailClick, Navigation.match(url))

    XCTAssertEqual(.emailClick,
                   Navigation.match(URL(string: "https://click.em.kickstarter.com/wf/click?upn=deadbeef")!))

    XCTAssertEqual(.emailClick,
                   Navigation.match(URL(string: "https://emails.kickstarter.com/anything/?qs=deadbeef")!))

    XCTAssertEqual(.emailClick,
                   Navigation.match(URL(string: "https://email.kickstarter.com/garbage/?random=deadbeef")!))

    XCTAssertEqual(.emailClick,
                   Navigation.match(URL(string: "https://e2.kickstarter.com/anypath/?b=deadbeef")!))

    XCTAssertEqual(.emailClick,
                   Navigation.match(URL(string: "https://e3.kickstarter.com/wildcard")!))

    XCTAssertNil(
      Navigation.match(URL(string: "https://notemailhost.kickstarter.com/wf/click?upn=deadbeef")!)
    )
  }

  func testRecognizesKsrUrlScheme() {
    let projectRoute = Navigation
      .match(URL(string: "ksr://www.kickstarter.com/projects/creator/project")!)

    XCTAssertNotNil(projectRoute)
    XCTAssertEqual(.project(.slug("project"), .root, refTag: nil), projectRoute)
  }
}
