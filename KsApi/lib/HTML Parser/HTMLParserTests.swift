@testable import KsApi
import XCTest

final class HTMLParserTests: XCTestCase {
  let htmlParser = HTMLParser()

  func testHTMLParser_WithValidNonGIFImage_Success() {
    let viewElements = self.htmlParser.parse(bodyHtml: HTMLParserTemplates.validNonGIFImage.data)

    guard let viewElement = viewElements.first as? ImageViewElement else {
      XCTFail("image view element should be created.")

      return
    }

    XCTAssertEqual(
      viewElement.src,
      "https://ksr-qa-ugc.imgix.net/assets/033/981/078/6a3036d55ab3c3d6f271ab0b5c532912_original.png?ixlib=rb-4.0.2&w=700&fit=max&v=1624426643&auto=format&gif-q=50&lossless=true&s=aaa772a0ea57e4697c14311f1f2e0086"
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
      "https://ksr-qa-ugc.imgix.net/assets/033/915/794/8dca97fb0636aeb1a4a937025f369e7e_original.gif?ixlib=rb-4.0.2&w=700&fit=max&v=1623894386&auto=format&gif-q=50&q=92&s=cde086d146601f4d9c6fe07e0d93bb84"
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
      "https://ksr-qa-ugc.imgix.net/assets/035/418/752/b1fe3dc3ff2aa64161aaf7cd6def0b97_original.jpg?ixlib=rb-4.0.2&w=700&fit=max&v=1635677740&auto=format&gif-q=50&q=92&s=6f32811c554177afaafc447642d83788"
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
      "https://ksr-qa-ugc.imgix.net/assets/034/488/736/c35446a93f1f9faedd76e9db814247bf_original.gif?ixlib=rb-4.0.2&w=700&fit=max&v=1628654686&auto=format&gif-q=50&q=92&s=061483d5e8fac13bd635b67e2ae8a258"
    )

    XCTAssertEqual(
      viewElement.href,
      "https://producthype.co/most-powerful-crowdfunding-newsletter/?utm_source=ProductHype&utm_medium=Banner&utm_campaign=Homi"
    )

    guard let existingCaption = viewElement.caption else {
      XCTFail("image caption should exist")

      return
    }

    XCTAssertEqual(existingCaption, "Viktor Pushkarev using lino-cutting to create the cover art.")
  }

  func testHTMLParser_WithValidVideoHigh_Success() {
    let viewElements = self.htmlParser.parse(bodyHtml: HTMLParserTemplates.validVideoHigh.data)

    guard let viewElement = viewElements.first as? AudioVideoViewElement else {
      XCTFail("audio video view element should be created.")

      return
    }

    XCTAssertEqual(
      viewElement.sourceURLString,
      "https://v.kickstarter.com/1642030675_192c029616b9f219c821971712835747963f13cc/assets/035/455/706/2610a2ac226ce966cc74ff97c8b6344d_h264_high.mp4"
    )

    XCTAssertEqual(
      viewElement.thumbnailURLString,
      "https://dr0rfahizzuzj.cloudfront.net/assets/035/455/706/2610a2ac226ce966cc74ff97c8b6344d_h264_high.jpg?2021"
    )

    XCTAssertEqual(viewElement.seekPosition, .zero)
  }

  func testHTMLParser_WithValidVideo_Success() {
    let viewElements = self.htmlParser.parse(bodyHtml: HTMLParserTemplates.validVideo.data)

    guard let viewElement = viewElements.first as? AudioVideoViewElement else {
      XCTFail("audio video view element should be created.")

      return
    }

    XCTAssertEqual(
      viewElement.sourceURLString,
      "https://v.kickstarter.com/1642030675_192c029616b9f219c821971712835747963f13cc/assets/035/455/706/2610a2ac226ce966cc74ff97c8b6344d_h264_base.mp4"
    )

    XCTAssertEqual(
      viewElement.thumbnailURLString,
      "https://dr0rfahizzuzj.cloudfront.net/assets/035/455/706/2610a2ac226ce966cc74ff97c8b6344d_h264_high.jpg?2021"
    )

    XCTAssertEqual(viewElement.seekPosition, .zero)
  }

  func testHTMLParser_WithValidAudio_Success() {
    let viewElements = self.htmlParser.parse(bodyHtml: HTMLParserTemplates.validAudio.data)

    guard let viewElement = viewElements.first as? AudioVideoViewElement else {
      XCTFail("audio video view element should be created.")

      return
    }

    XCTAssertEqual(
      viewElement.sourceURLString,
      "https://d15chbti7ht62o.cloudfront.net/assets/002/236/466/f17de99e2a9e76a4954418c16d963f9b_mp3.mp3?2015"
    )

    XCTAssertTrue(viewElement.thumbnailURLString!.isEmpty)
    XCTAssertEqual(viewElement.seekPosition, .zero)
  }

  func testHTMLParser_WithValidHiddenVideo_Success() {
    let viewElements = self.htmlParser.parse(bodyHtml: HTMLParserTemplates.validHiddenVideo.data)

    guard let viewElement = viewElements.first as? AudioVideoViewElement else {
      XCTFail("video view element should be created.")

      return
    }

    XCTAssertEqual(
      viewElement.sourceURLString,
      "https://v.kickstarter.com/1642030675_192c029616b9f219c821971712835747963f13cc/assets/035/455/706/2610a2ac226ce966cc74ff97c8b6344d_h264_base.mp4"
    )

    XCTAssertEqual(
      viewElement.thumbnailURLString,
      "https://dr0rfahizzuzj.cloudfront.net/assets/035/455/706/2610a2ac226ce966cc74ff97c8b6344d_h264_high.jpg?2021"
    )

    XCTAssertEqual(viewElement.seekPosition, .zero)
  }

  func testHTMLParser_WithExternalSource_Success() {
    let viewElements = self.htmlParser.parse(bodyHtml: HTMLParserTemplates.validIFrame.data)

    guard let viewElement = viewElements.first as? ExternalSourceViewElement else {
      XCTFail("external source view element should be created.")

      return
    }

    XCTAssertEqual(
      viewElement.embeddedURLString,
      "https://www.youtube.com/embed/GcoaQ3LlqWI?start=8&feature=oembed&wmode=transparent"
    )
    XCTAssertEqual(viewElement.embeddedURLContentHeight, 200)
  }

  func testHTMLParser_WithExternalEmbeddedSource_Success() {
    let viewElements = self.htmlParser.parse(bodyHtml: HTMLParserTemplates.validIFrameWithEmbeddedSource.data)

    guard let viewElement = viewElements.first as? ExternalSourceViewElement else {
      XCTFail("external source view element should be created.")

      return
    }

    XCTAssertEqual(viewElement.embeddedURLString, "https://www.tiktok.com/embed/v2/7056148230324653359")
    XCTAssertEqual(viewElement.embeddedURLContentHeight, 400)
  }

  func testHTMLParser_WithTextHeadline_Success() {
    let viewElements = self.htmlParser.parse(bodyHtml: HTMLParserTemplates.validHeaderText.data)

    guard let viewElement = viewElements.first as? TextViewElement else {
      XCTFail("text view element should be created.")

      return
    }

    guard viewElement.components.count == 1 else {
      XCTFail()

      return
    }

    XCTAssertEqual(
      viewElement.components[0].text,
      "Please participate in helping me finish my film! Just pick a level in the right hand column and click to donate — it only takes a minute."
    )
    XCTAssertNil(viewElement.components[0].link)
    XCTAssertEqual(viewElement.components[0].styles, [TextComponent.TextStyleType.header])
  }

  func testHTMLParser_WithMultipleParagraphsLinksAndStyles_Success() {
    let viewElements = self.htmlParser
      .parse(bodyHtml: HTMLParserTemplates.validParagraphTextWithLinksAndStyles.data)

    guard let textElement1 = viewElements.first as? TextViewElement,
      let textElement2 = viewElements.last as? TextViewElement else {
      XCTFail("text view elements should be created.")

      return
    }

    guard textElement1.components.count == 1 else {
      XCTFail()

      return
    }

    XCTAssertEqual(textElement1.components[0].text, "What about a bold link to that same newspaper website?")
    XCTAssertEqual(textElement1.components[0].link, "http://record.pt/")
    XCTAssertEqual(
      textElement1.components[0].styles,
      [TextComponent.TextStyleType.bold, TextComponent.TextStyleType.link]
    )

    XCTAssertEqual(textElement2.components[0].text, "Maybe an italic one?")
    XCTAssertEqual(textElement2.components[0].link, "http://recordblabla.pt/")
    XCTAssertEqual(
      textElement2.components[0].styles,
      [TextComponent.TextStyleType.emphasis, TextComponent.TextStyleType.link]
    )
  }

  func testHTMLParser_WithParagraphAndStyles_Success() {
    let viewElements = self.htmlParser.parse(bodyHtml: HTMLParserTemplates.validParagraphTextWithStyles.data)

    guard let textElement = viewElements.first as? TextViewElement else {
      XCTFail("text view element should be created.")

      return
    }

    guard textElement.components.count == 2 else {
      XCTFail()

      return
    }

    XCTAssertEqual(
      textElement.components[0].text,
      "This is a paragraph about bacon – Bacon ipsum dolor amet ham chuck short ribs, shank flank cupim frankfurter chicken. Sausage frankfurter chicken ball tip, drumstick brisket pork chop turkey. Andouille bacon ham hock, pastrami sausage pork chop corned beef frankfurter shank chislic short ribs. Hamburger bacon pork belly, drumstick pork chop capicola kielbasa pancetta buffalo pork. Meatball doner pancetta ham ribeye. Picanha ham venison ribeye short loin beef, tail pig ball tip buffalo salami shoulder ground round chicken. Porchetta capicola drumstick, tongue fatback pork pork belly cow sirloin ham hock flank venison beef ribs."
    )
    XCTAssertNil(textElement.components[0].link)
    XCTAssertTrue(textElement.components[0].styles.isEmpty)
    XCTAssertEqual(textElement.components[1].text, "Bold word Italic word")
    XCTAssertNil(textElement.components[1].link)
    XCTAssertEqual(
      textElement.components[1].styles,
      [TextComponent.TextStyleType.emphasis, TextComponent.TextStyleType.bold]
    )
  }

  func testHTMLParser_OfListWithNestedLinks_Success() {
    let sampleLink = "https://www.meneame.net/"
    let viewElements = self.htmlParser.parse(bodyHtml: HTMLParserTemplates.validListWithNestedLinks.data)

    guard let textElement = viewElements.first as? TextViewElement else {
      XCTFail("text view element should be created.")

      return
    }

    guard textElement.components.count == 5 else {
      XCTFail()

      return
    }

    XCTAssertEqual(textElement.components[0].text, "•  ")
    XCTAssertNil(textElement.components[0].link)
    XCTAssertEqual(textElement.components[0].styles, [
      TextComponent.TextStyleType.bulletStart
    ])
    XCTAssertEqual(textElement.components[1].text, "Meneane")
    XCTAssertEqual(textElement.components[1].link, sampleLink)
    XCTAssertEqual(textElement.components[1].styles, [
      TextComponent.TextStyleType.bold,
      TextComponent.TextStyleType.emphasis,
      TextComponent.TextStyleType.link
    ])
    XCTAssertEqual(textElement.components[2].text, "Another URL in this list")
    XCTAssertEqual(textElement.components[2].link, sampleLink)
    XCTAssertEqual(textElement.components[2].styles, [TextComponent.TextStyleType.link])
    XCTAssertEqual(textElement.components[3].text, " and some text")
    XCTAssertNil(textElement.components[3].link)
    XCTAssertTrue(textElement.components[3].styles.isEmpty)
    XCTAssertTrue(textElement.components[4].text.isEmpty)
    XCTAssertNil(textElement.components[4].link)
    XCTAssertEqual(textElement.components[4].styles, [TextComponent.TextStyleType.bulletEnd])
  }
}
