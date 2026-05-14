@testable import LibraryTestHelpers
@testable import ServerDrivenUI
import ServerDrivenUITestHelpers
import SwiftUI
import ViewInspector
import XCTest

@MainActor
final class ImageBlockTests: TestCase {
  func testImageBlockWithValidURL_hasAccessibilityLabel() throws {
    let photo = makePhoto(
      altText: "Test image",
      url: testImageURL().absoluteString
    )

    let view = imageBlock(photo: photo, colorScheme: .light)

    XCTAssertNoThrow(try view.inspect().find(viewWithAccessibilityLabel: "Test image"))
  }

  func testImageBlockWithValidURL_exposesPhoto() throws {
    let photo = makePhoto(
      altText: "Test image",
      url: testImageURL().absoluteString
    )

    let view = imageBlock(photo: photo, colorScheme: .light)
    let imageBlock = try view.inspect().find(ImageBlock.self).actualView()

    XCTAssertEqual(imageBlock.photo.altText, "Test image")
    XCTAssertEqual(imageBlock.photo.url, photo.url)
  }

  func testImageBlockWithoutURL_rendersClearPlaceholder() throws {
    let photo = makePhoto(altText: "Missing image", url: nil)

    let view = imageBlock(photo: photo, colorScheme: .light)

    XCTAssertNoThrow(try view.inspect().find(ViewType.Color.self))
    XCTAssertNoThrow(try view.inspect().find(viewWithAccessibilityLabel: "Missing image"))
  }

  func testImageBlockWithEmptyURL_rendersClearPlaceholder() throws {
    let photo = makePhoto(altText: "Missing image", url: "")

    let view = imageBlock(photo: photo, colorScheme: .light)

    XCTAssertNoThrow(try view.inspect().find(ViewType.Color.self))
    XCTAssertNoThrow(try view.inspect().find(viewWithAccessibilityLabel: "Missing image"))
  }

  func testImageBlockWithNilAltText_hasEmptyAccessibilityLabel() throws {
    let photo = makePhoto(altText: nil, url: testImageURL().absoluteString)

    let view = imageBlock(photo: photo, colorScheme: .light)

    XCTAssertNoThrow(try view.inspect().find(viewWithAccessibilityLabel: ""))
  }

  func testImageBlockWithValidURL_lightAndDarkStyles() throws {
    let photo = makePhoto(
      altText: "Styled image",
      url: testImageURL().absoluteString
    )

    for colorScheme in [ColorScheme.light, ColorScheme.dark] {
      let view = imageBlock(photo: photo, colorScheme: colorScheme)
      let imageBlock = try view.inspect().find(ImageBlock.self).actualView()

      XCTAssertEqual(imageBlock.photo.altText, "Styled image")
      XCTAssertNoThrow(try view.inspect().find(viewWithAccessibilityLabel: "Styled image"))
    }
  }
}

private func makePhoto(altText: String?, url: String?) -> RichTextElement.Photo {
  RichTextElement.Photo(
    altText: altText,
    assetID: "123",
    caption: "Test caption",
    url: url
  )
}

private func testImageURL() -> URL {
  guard let imageURL = Bundle.module.url(forResource: "600x400", withExtension: "png") else {
    XCTFail("no test photo")
    fatalError("no test photo")
  }
  return imageURL
}

private func imageBlock(photo: RichTextElement.Photo, colorScheme: ColorScheme) -> some View {
  ImageBlock(photo: photo)
    .frame(width: 300, height: 200)
    .environment(\.richTextStyle, richTextStyle(colorScheme))
}

private func richTextStyle(_ colorScheme: ColorScheme) -> any RichTextStyle {
  switch colorScheme {
  case .light:
    return LightRichTextStyle()
  case .dark:
    return DarkRichTextStyle()
  @unknown default:
    assertionFailure()
    return AutomaticRichTextStyle()
  }
}
