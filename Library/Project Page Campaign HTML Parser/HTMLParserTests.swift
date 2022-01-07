@testable import Library
import XCTest

final class HTMLParserTests: TestCase {
  let htmlParser = HTMLParser()

  func testHTMLParser_WithValidNonGifImage_Success() {
    let viewElements = self.htmlParser.parse(html: HTMLParserTemplates.validNonGIFImage.data)

    guard let viewElement = viewElements.first as? ImageViewElement else {
      XCTFail("image view element should be created.")

      return
    }

    XCTAssertEqual(
      viewElement.src,
      "https://ksr-qa-ugc.imgix.net/assets/033/981/078/6a3036d55ab3c3d6f271ab0b5c532912_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1624426643&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=aaa772a0ea57e4697c14311f1f2e0086"
    )
    XCTAssertNil(viewElement.href)

    guard let existingCaption = viewElement.caption else {
      XCTFail("image caption should exist")

      return
    }

    XCTAssertTrue(existingCaption.isEmpty)
  }
}
