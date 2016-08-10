import XCTest
import KsApi
@testable import Library

private func KSRAssertMatch(expected: Navigation,
                            _ path: String,
                              file: StaticString = #file,
                              line: UInt = #line) {

  let base = AppEnvironment.current.apiService.serverConfig.webBaseUrl.absoluteString
  let url = NSURL(string: "\(base)\(path)")!

  XCTAssertEqual(expected,
                 Navigation.match(url), file: file, line: line)
}

public final class NavigationTests: XCTestCase {

  func testDoesNotRecognizeNonKickstarterURLs() {
    let projectRoute = Navigation
      .match(NSURL(string: "http://www.face-kickstarter.com/projects/creator/project")!)

    XCTAssertNil(projectRoute)
  }

  func testRecognizesURLs() {
    KSRAssertMatch(.project(.slug("project"), .root, refTag: nil),
                   "/projects/creator/project")

    KSRAssertMatch(.project(.slug("project"), .root, refTag: .discovery),
                   "/projects/creator/project?ref_tag=discovery")

    KSRAssertMatch(.project(.slug("project"), .comments, refTag: nil),
                   "/projects/creator/project/comments")

    KSRAssertMatch(.project(.slug("project"), .creatorBio, refTag: nil),
                   "/projects/creator/project/creator_bio")

    KSRAssertMatch(.project(.slug("project"), .description, refTag: nil),
                   "/projects/creator/project/description")

    KSRAssertMatch(.project(.slug("project"), .friends, refTag: nil),
                   "/projects/creator/project/friends")

    KSRAssertMatch(.project(.slug("project"), .updates, refTag: nil),
                   "/projects/creator/project/posts")

    KSRAssertMatch(.project(.slug("project"), .update(1, .root), refTag: nil),
                   "/projects/creator/project/posts/1")

    KSRAssertMatch(.project(.slug("project"), .update(2, .comments), refTag: nil),
                   "/projects/creator/project/posts/2/comments")

    KSRAssertMatch(.project(.slug("project"), .survey(3), refTag: nil),
                   "/projects/creator/project/surveys/3")

    KSRAssertMatch(.tab(.discovery(.root)),
                   "/discover")

    KSRAssertMatch(.tab(.discovery(.advanced)),
                   "/discover/advanced")

    KSRAssertMatch(.tab(.discovery(.category(category: .slug("a"), subcategory: nil))),
                   "/discover/categories/a")

    KSRAssertMatch(.tab(.discovery(.category(category: .slug("b"), subcategory: .slug("c")))),
                   "/discover/categories/b/c")

    KSRAssertMatch(.tab(.search),
                   "/search")

    KSRAssertMatch(.tab(.activity),
                   "/activity")

    KSRAssertMatch(.tab(.me),
                   "/profile/me")
  }
}
