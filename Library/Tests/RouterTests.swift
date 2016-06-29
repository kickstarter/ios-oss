import XCTest
import KsApi
@testable import Library

public final class RouterTests: XCTestCase {

  func testDoesNotRecognizeNonKickstarterURLs() {
    let projectRoute = Router.decodeProject(
      request: NSURLRequest(URL: NSURL(string: "http://www.face-kickstarter.com/projects/creator/project")!)
    )

    XCTAssertNil(projectRoute)
  }

  func testRecognizesProjectURLs() {
    let route = Router.decodeProject(
      request: NSURLRequest(
        URL: AppEnvironment.current.apiService.serverConfig.webBaseUrl
          .URLByAppendingPathComponent("/projects/creator/project")
      )
    )

    XCTAssertNotNil(route)
    XCTAssertEqual(Param?.Some(.slug("project")), route?.projectParam)
    XCTAssertNil(route?.refTag)
  }

  func testRecognizesProjectURLsWithRefTag() {
    let route = Router.decodeProject(
      request: NSURLRequest(
        URL: NSURL(string:
          AppEnvironment.current.apiService.serverConfig.webBaseUrl.absoluteString
            + "/projects/creator/project?ref_tag=discovery"
        )!
      )
    )

    XCTAssertNotNil(route)
    XCTAssertEqual(Param?.Some(.slug("project")), route?.projectParam)
    XCTAssertEqual(RefTag.discovery, route?.refTag)
  }

  func testRecognizesProjectCommentsURL() {
    let route = Router.decodeProjectComments(
      request: NSURLRequest(
        URL: AppEnvironment.current.apiService.serverConfig.webBaseUrl
          .URLByAppendingPathComponent("/projects/creator/project/comments")
      )
    )

    XCTAssertNotNil(route)
    XCTAssertEqual(Param?.Some(.slug("project")), route?.projectParam)
  }

  func testRecognizesUpdateURL() {
    let route = Router.decodeUpdate(
      request: NSURLRequest(
        URL: AppEnvironment.current.apiService.serverConfig.webBaseUrl
          .URLByAppendingPathComponent("/projects/creator/project/posts/123")
      )
    )

    XCTAssertNotNil(route)
    XCTAssertEqual(Param?.Some(.slug("project")), route?.projectParam)
    XCTAssertEqual(123, route?.updateId)
  }

  func testRecognizesUpdateCommentsURL() {
    let route = Router.decodeUpdateComments(
      request: NSURLRequest(
        URL: AppEnvironment.current.apiService.serverConfig.webBaseUrl
          .URLByAppendingPathComponent("/projects/creator/project/posts/123/comments")
      )
    )

    XCTAssertNotNil(route)
    XCTAssertEqual(Param?.Some(.slug("project")), route?.projectParam)
    XCTAssertEqual(123, route?.updateId)
  }
}
