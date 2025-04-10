@testable import KsApi
@testable import Library
import XCTest

class ProjectURLBuilderTests: XCTestCase {
  
  func testGetProjectBackingDetailsURL() {
    
    let backingDetailsURL = getProjectBackingDetailsURL(with: Project.template)
    let url = "https://www.kickstarter.com/projects/1/a-fun-project/backing/details"
    
    XCTAssertNotNil(backingDetailsURL)
    XCTAssertEqual(backingDetailsURL?.absoluteString, url)
  }
}
