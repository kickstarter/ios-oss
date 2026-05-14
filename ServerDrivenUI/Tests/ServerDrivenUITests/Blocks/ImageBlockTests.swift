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

  func testImageBlockWithValidURL_usesAspectFit() throws {
    let photo = makePhoto(
      altText: "Test image",
      url: testImageURL().absoluteString
    )

    let view = imageBlock(photo: photo, colorScheme: .light, width: nil, height: nil)
    let image = try view.inspect().find(viewWithAccessibilityLabel: "Test image")
    let aspectRatio = try image.aspectRatio()

    XCTAssertNil(aspectRatio.aspectRatio)
    XCTAssertEqual(aspectRatio.contentMode, .fit)
  }

  func testImageBlockWithoutURL_expandsToMaximumWidth() throws {
    let photo = makePhoto(altText: "Missing image", url: nil)

    let view = imageBlock(photo: photo, colorScheme: .light, width: nil, height: nil)
    let placeholder = try view.inspect().find(ViewType.Color.self)
    let frame = try placeholder.flexFrame()

    XCTAssertTrue(frame.maxWidth.isInfinite)
  }

  func testImageBlockWithEmptyURL_expandsToMaximumWidth() throws {
    let photo = makePhoto(altText: "Missing image", url: "")

    let view = imageBlock(photo: photo, colorScheme: .light, width: nil, height: nil)
    let placeholder = try view.inspect().find(ViewType.Color.self)
    let frame = try placeholder.flexFrame()

    XCTAssertTrue(frame.maxWidth.isInfinite)
  }

  func testImageBlockWithValidURL_respectsContainerFrame() throws {
    let photo = makePhoto(
      altText: "Test image",
      url: testImageURL().absoluteString
    )
    let containerWidth: CGFloat = 300
    let containerHeight: CGFloat = 200

    let view = imageBlock(
      photo: photo,
      colorScheme: .light,
      width: containerWidth,
      height: containerHeight
    )
    let frame = try view.inspect().fixedFrame()

    XCTAssertEqual(frame.width, containerWidth)
    XCTAssertEqual(frame.height, containerHeight)
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

@ViewBuilder
private func imageBlock(
  photo: RichTextElement.Photo,
  colorScheme: ColorScheme,
  width: CGFloat? = 300,
  height: CGFloat? = 200
) -> some View {
  let block = ImageBlock(photo: photo)
    .environment(\.richTextStyle, richTextStyle(colorScheme))

  if let width, let height {
    block.frame(width: width, height: height)
  } else {
    block
  }
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
