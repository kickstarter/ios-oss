@testable import KsApi
import XCTest

final class ProjectPhotoTests: XCTestCase {
  func testJSONParsing_WithPartialData() {
    let photo: Project.Photo? = Project.Photo.decodeJSONDictionary([
      "full": "http://www.kickstarter.com/full.jpg",
      "med": "http://www.kickstarter.com/med.jpg"
    ])

    XCTAssertNil(photo)
  }

  func testJSONParsing_WithMissing1024() {
    let photo: Project.Photo = try! Project.Photo.decodeJSONDictionary([
      "full": "http://www.kickstarter.com/full.jpg",
      "med": "http://www.kickstarter.com/med.jpg",
      "small": "http://www.kickstarter.com/small.jpg"
    ])

    XCTAssertNotNil(photo)
    XCTAssertEqual(photo.full, "http://www.kickstarter.com/full.jpg")
    XCTAssertEqual(photo.med, "http://www.kickstarter.com/med.jpg")
    XCTAssertEqual(photo.small, "http://www.kickstarter.com/small.jpg")
    XCTAssertNil(photo.size1024x768)
  }

  func testJSONParsing_WithFullData() {
    let photo: Project.Photo = try! Project.Photo.decodeJSONDictionary([
      "full": "http://www.kickstarter.com/full.jpg",
      "med": "http://www.kickstarter.com/med.jpg",
      "small": "http://www.kickstarter.com/small.jpg",
      "1024x768": "http://www.kickstarter.com/1024x768.jpg"
    ])

    XCTAssertNotNil(photo)
    XCTAssertEqual(photo.full, "http://www.kickstarter.com/full.jpg")
    XCTAssertEqual(photo.med, "http://www.kickstarter.com/med.jpg")
    XCTAssertEqual(photo.small, "http://www.kickstarter.com/small.jpg")
    XCTAssertEqual(photo.size1024x768, "http://www.kickstarter.com/1024x768.jpg")
  }
}
