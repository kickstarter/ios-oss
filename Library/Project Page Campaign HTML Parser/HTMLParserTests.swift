@testable import Library
import XCTest

final class HTMLParserTests: TestCase {
  let htmlParser = HTMLParser()

  func testHTMLParser_WithValidNonGIFImage_Success() {
    let viewElements = self.htmlParser.parse(bodyHtml: HTMLParserTemplates.validNonGIFImage.data)

    guard let viewElement = viewElements.first as? ImageViewElement else {
      XCTFail("image view element should be created.")

      return
    }

    XCTAssertEqual(
      viewElement.src,
      "https://ksr-qa-ugc.imgix.net/assets/033/981/078/6a3036d55ab3c3d6f271ab0b5c532912_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1624426643&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=aaa772a0ea57e4697c14311f1f2e0086"
        .htmlStripped()
    )
    XCTAssertNil(viewElement.href)

    guard let existingCaption = viewElement.caption else {
      XCTFail("image caption should exist")

      return
    }

    XCTAssertTrue(existingCaption.isEmpty)
  }

  func testHTMLParser_WithValidGIFImage_Success() {
    let viewElements = self.htmlParser.parse(bodyHtml: HTMLParserTemplates.validGIFImage.data)

    guard let viewElement = viewElements.first as? ImageViewElement else {
      XCTFail("image view element should be created.")

      return
    }

    XCTAssertEqual(
      viewElement.src,
      "https://ksr-qa-ugc.imgix.net/assets/033/915/794/8dca97fb0636aeb1a4a937025f369e7e_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623894386&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=cde086d146601f4d9c6fe07e0d93bb84"
        .htmlStripped()
    )
    XCTAssertNil(viewElement.href)

    guard let existingCaption = viewElement.caption else {
      XCTFail("image caption should exist")

      return
    }

    XCTAssertTrue(existingCaption.isEmpty)
  }

  func testHTMLParser_WithValidImageWithCaption_Success() {
    let viewElements = self.htmlParser.parse(bodyHtml: HTMLParserTemplates.validImageWithCaption.data)

    guard let viewElement = viewElements.first as? ImageViewElement else {
      XCTFail("image view element should be created.")

      return
    }

    XCTAssertEqual(
      viewElement.src,
      "https://ksr-qa-ugc.imgix.net/assets/035/418/752/b1fe3dc3ff2aa64161aaf7cd6def0b97_original.jpg?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1635677740&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=6f32811c554177afaafc447642d83788"
        .htmlStripped()
    )

    XCTAssertNil(viewElement.href)

    guard let existingCaption = viewElement.caption else {
      XCTFail("image caption should exist")

      return
    }

    XCTAssertEqual(existingCaption, "Viktor Pushkarev using lino-cutting to create the cover art.")
  }

  func testHTMLParser_WithValidImageWithCaptionAndLink_Success() {
    let viewElements = self.htmlParser.parse(bodyHtml: HTMLParserTemplates.validImageWithCaptionAndLink.data)

    guard let viewElement = viewElements.first as? ImageViewElement else {
      XCTFail("image view element should be created.")

      return
    }

    XCTAssertEqual(
      viewElement.src,
      "https://ksr-qa-ugc.imgix.net/assets/034/488/736/c35446a93f1f9faedd76e9db814247bf_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1628654686&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=061483d5e8fac13bd635b67e2ae8a258"
        .htmlStripped()
    )

    XCTAssertEqual(
      viewElement.href,
      "https://producthype.co/most-powerful-crowdfunding-newsletter/?utm_source=ProductHype&amp;utm_medium=Banner&amp;utm_campaign=Homi"
        .htmlStripped()
    )

    guard let existingCaption = viewElement.caption else {
      XCTFail("image caption should exist")

      return
    }

    XCTAssertEqual(existingCaption, "Viktor Pushkarev using lino-cutting to create the cover art.")
  }

  /**
   func testHTMLParser_WithValidVideo_Success() {
     let viewElements = self.htmlParser.parse(html: HTMLParserTemplates.validVideo.data)

     guard let viewElement = viewElements.first as? VideoViewElement else {
       XCTFail("image view element should be created.")

       return
     }

     XCTAssertEqual(
       viewElement.src, "https://ksr-qa-ugc.imgix.net/assets/034/488/736/c35446a93f1f9faedd76e9db814247bf_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1628654686&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=061483d5e8fac13bd635b67e2ae8a258".htmlStripped())

     XCTAssertEqual(viewElement.href, "https://producthype.co/most-powerful-crowdfunding-newsletter/?utm_source=ProductHype&amp;utm_medium=Banner&amp;utm_campaign=Homi")

     guard let existingCaption = viewElement.caption else {
       XCTFail("image caption should exist")

       return
     }

     XCTAssertEqual(existingCaption, "Viktor Pushkarev using lino-cutting to create the cover art.")
   }
   */
}
