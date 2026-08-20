import Foundation
@testable import ServerDrivenUI
import XCTest

final class RichTextElementNormalizingTests: XCTestCase {
  /* Text with no children is left unchanged */
  func testLeavesPlainTextUnchanged() throws {
    let element = RichTextElement.text(.init(text: "hello"), nil)
    let result = element.withNormalizedNestedElements()
    XCTAssertEqual(result, [element])
  }

  /* Text whose children contain no Photo is left unchanged */
  func testLeavesTextWithNonPhotoChildrenUnchanged() throws {
    let element = RichTextElement.text(
      .init(text: "", children: [.text(.init(text: "a"), nil), .text(.init(text: "b"), nil)]),
      nil
    )
    let result = element.withNormalizedNestedElements()
    XCTAssertEqual(result, [element])
  }

  /* Non-text elements are left unchanged */
  func testLeavesNonTextElementsUnchanged() throws {
    let photo = RichTextElement.Photo(altText: nil, assetID: nil, caption: nil, url: nil, link: nil)
    let element = RichTextElement.photo(photo)
    XCTAssertEqual(element.withNormalizedNestedElements(), [element])
  }

  /* Text/Photo/Text children split into three sibling elements */
  func testSplitsTextPhotoTextIntoThreeElements() throws {
    let photo = RichTextElement.Photo(
      altText: "alt",
      assetID: "1",
      caption: "cap",
      url: "https://img",
      link: nil
    )
    let element = RichTextElement.text(
      .init(text: "", children: [
        .text(.init(text: "Here's an image: "), nil),
        .photo(photo),
        .text(.init(text: " Isn't it nice?"), nil)
      ]),
      nil
    )

    let result = element.withNormalizedNestedElements()
    XCTAssertEqual(result.count, 3)

    guard case let .text(first, _) = result[0] else { return XCTFail("expected .text first") }
    XCTAssertEqual(first.children, [.text(.init(text: "Here's an image: "), nil)])

    guard case let .photo(middle) = result[1] else { return XCTFail("expected .photo second") }
    XCTAssertEqual(middle, photo)

    guard case let .text(last, _) = result[2] else { return XCTFail("expected .text third") }
    XCTAssertEqual(last.children, [.text(.init(text: " Isn't it nice?"), nil)])
  }

  /* Leading Photo with no preceding text does not produce an empty leading Text */
  func testLeadingPhotoProducesNoEmptyLeadingText() throws {
    let photo = RichTextElement.Photo(altText: nil, assetID: nil, caption: nil, url: nil, link: nil)
    let element = RichTextElement.text(
      .init(text: "", children: [.photo(photo), .text(.init(text: "after"), nil)]),
      nil
    )

    let result = element.withNormalizedNestedElements()
    XCTAssertEqual(result.count, 2)
    guard case .photo = result[0] else { return XCTFail("expected .photo first") }
    guard case let .text(last, _) = result[1] else { return XCTFail("expected .text second") }
    XCTAssertEqual(last.children, [.text(.init(text: "after"), nil)])
  }

  /* Trailing Photo with no following text does not produce an empty trailing Text */
  func testTrailingPhotoProducesNoEmptyTrailingText() throws {
    let photo = RichTextElement.Photo(altText: nil, assetID: nil, caption: nil, url: nil, link: nil)
    let element = RichTextElement.text(
      .init(text: "", children: [.text(.init(text: "before"), nil), .photo(photo)]),
      nil
    )

    let result = element.withNormalizedNestedElements()
    XCTAssertEqual(result.count, 2)
    guard case let .text(first, _) = result[0] else { return XCTFail("expected .text first") }
    XCTAssertEqual(first.children, [.text(.init(text: "before"), nil)])
    guard case .photo = result[1] else { return XCTFail("expected .photo second") }
  }

  /* Consecutive Photos produce no empty Text between them */
  func testConsecutivePhotosProduceNoEmptyTextBetween() throws {
    let photo1 = RichTextElement.Photo(altText: "1", assetID: nil, caption: nil, url: nil, link: nil)
    let photo2 = RichTextElement.Photo(altText: "2", assetID: nil, caption: nil, url: nil, link: nil)
    let element = RichTextElement.text(.init(text: "", children: [.photo(photo1), .photo(photo2)]), nil)

    let result = element.withNormalizedNestedElements()
    XCTAssertEqual(result, [.photo(photo1), .photo(photo2)])
  }

  /* The Text element's own text/link/styles are preserved as a leading segment */
  func testPreservesOwnTextAsLeadingSegment() throws {
    let photo = RichTextElement.Photo(altText: nil, assetID: nil, caption: nil, url: nil, link: nil)
    let link = URL(string: "https://kickstarter.com")
    let element = RichTextElement.text(
      .init(text: "prefix", link: link, styles: [.strong], children: [.photo(photo)]),
      nil
    )

    let result = element.withNormalizedNestedElements()
    XCTAssertEqual(result.count, 2)
    guard case let .text(first, _) = result[0] else { return XCTFail("expected .text first") }
    XCTAssertEqual(first.children, [.text(.init(text: "prefix", link: link, styles: [.strong]), nil)])
    guard case .photo = result[1] else { return XCTFail("expected .photo second") }
  }

  /* The enclosing text's link is applied to a Photo child, since RichTextPhoto itself has no
   * link field — the server represents a linkable image as a RichText node whose link wraps
   * a RichTextPhoto child. */
  func testAppliesEnclosingLinkToPhotoChild() throws {
    let photo = RichTextElement.Photo(altText: nil, assetID: nil, caption: nil, url: "https://img", link: nil)
    let link = URL(string: "https://backercrew.com/submit")
    let element = RichTextElement.text(.init(text: "", link: link, children: [.photo(photo)]), nil)

    let result = element.withNormalizedNestedElements()
    XCTAssertEqual(result.count, 1)
    guard case let .photo(linkedPhoto) = result[0] else { return XCTFail("expected .photo") }
    XCTAssertEqual(linkedPhoto.link, link)
    XCTAssertEqual(linkedPhoto.url, photo.url)
  }

  /* A Photo child is left without a link when the enclosing text has none */
  func testLeavesPhotoWithoutLinkWhenEnclosingTextHasNoLink() throws {
    let photo = RichTextElement.Photo(altText: nil, assetID: nil, caption: nil, url: "https://img", link: nil)
    let element = RichTextElement.text(.init(text: "", children: [.photo(photo)]), nil)

    let result = element.withNormalizedNestedElements()
    XCTAssertEqual(result.count, 1)
    guard case let .photo(unlinkedPhoto) = result[0] else { return XCTFail("expected .photo") }
    XCTAssertNil(unlinkedPhoto.link)
  }

  /* Header level is preserved across all split segments */
  func testPreservesHeaderLevelAcrossSplits() throws {
    let photo = RichTextElement.Photo(altText: nil, assetID: nil, caption: nil, url: nil, link: nil)
    let element = RichTextElement.text(
      .init(text: "", children: [.text(.init(text: "a"), nil), .photo(photo), .text(.init(text: "b"), nil)]),
      .two
    )

    let result = element.withNormalizedNestedElements()
    XCTAssertEqual(result.count, 3)
    guard case let .text(_, headerA) = result[0] else { return XCTFail("expected .text first") }
    XCTAssertEqual(headerA, .two)
    guard case let .text(_, headerB) = result[2] else { return XCTFail("expected .text third") }
    XCTAssertEqual(headerB, .two)
  }

  /* Array-level splitting flattens across multiple top-level elements, preserving surrounding elements */
  func testArraySplittingFlattensAcrossElements() throws {
    let photo = RichTextElement.Photo(altText: nil, assetID: nil, caption: nil, url: nil, link: nil)
    let textWithNestedPhoto = RichTextElement.text(
      .init(text: "", children: [.text(.init(text: "a"), nil), .photo(photo), .text(.init(text: "b"), nil)]),
      nil
    )
    let plainText = RichTextElement.text(.init(text: "plain"), nil)
    let elements: [RichTextElement] = [plainText, textWithNestedPhoto, .listItemOpen]

    let result = elements.withNormalizedNestedElements()

    XCTAssertEqual(result.count, 5)
    XCTAssertEqual(result[0], plainText)
    XCTAssertEqual(result[4], .listItemOpen)
  }
}
