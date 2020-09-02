@testable import KsApi
import XCTest

final class Project_GraphProjectTests: XCTestCase {
  func test() {
    // TODO: consider testing more variations
    XCTAssertNotNil(Project.project(from: .template))
  }
}
