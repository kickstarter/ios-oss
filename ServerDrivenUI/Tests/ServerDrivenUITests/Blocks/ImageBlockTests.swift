@testable import ServerDrivenUI
import ServerDrivenUITestHelpers
import SwiftUI
import ViewInspector
import XCTest

@MainActor
final class ImageBlockTests: XCTestCase {
  func testImageBlockWithValidURL_hasAccessibilityLabel() throws {
    let photo = makePhoto(
      altText: "Test image",
      url: testImageURL().absoluteString
    )

    let view = imageBlock(photo: photo, colorScheme: .light)

    XCTAssertNoThrow(
      try view.inspect().find(viewWithAccessibilityLabel: "Test image"),
      "Expected ImageBlock to expose accessibility label 'Test image' when URL is valid."
    )
  }

  func testImageBlockWithValidURL_exposesPhoto() throws {
    let photo = makePhoto(
      altText: "Test image",
      url: testImageURL().absoluteString
    )

    let view = imageBlock(photo: photo, colorScheme: .light)
    let imageBlock = try view.inspect().find(ImageBlock.self).actualView()

    XCTAssertEqual(
      imageBlock.photo.altText,
      "Test image",
      "ImageBlock.photo.altText should equal the provided alt text when URL is valid."
    )
    XCTAssertEqual(
      imageBlock.photo.url,
      photo.url,
      "ImageBlock.photo.url should equal the provided photo URL."
    )
  }

  func testImageBlockWithoutURL_rendersClearPlaceholder() throws {
    let photo = makePhoto(altText: "Missing image", url: nil)

    let view = imageBlock(photo: photo, colorScheme: .light)

    XCTAssertNoThrow(
      try view.inspect().find(ViewType.Color.self),
      "Expected a clear Color placeholder when photo URL is nil."
    )
    XCTAssertNoThrow(
      try view.inspect().find(viewWithAccessibilityLabel: "Missing image"),
      "Expected accessibility label 'Missing image' even when URL is nil."
    )
  }

  func testImageBlockWithEmptyURL_rendersClearPlaceholder() throws {
    let photo = makePhoto(altText: "Missing image", url: "")

    let view = imageBlock(photo: photo, colorScheme: .light)

    XCTAssertNoThrow(
      try view.inspect().find(ViewType.Color.self),
      "Expected a clear Color placeholder when photo URL is empty."
    )
    XCTAssertNoThrow(
      try view.inspect().find(viewWithAccessibilityLabel: "Missing image"),
      "Expected accessibility label 'Missing image' even when URL is empty."
    )
  }

  func testImageBlockWithNilAltText_hasEmptyAccessibilityLabel() throws {
    let photo = makePhoto(altText: nil, url: testImageURL().absoluteString)

    let view = imageBlock(photo: photo, colorScheme: .light)

    XCTAssertNoThrow(
      try view.inspect().find(viewWithAccessibilityLabel: ""),
      "Expected empty accessibility label when altText is nil."
    )
  }

  func testImageBlockWithValidURL_lightAndDarkStyles() throws {
    let photo = makePhoto(
      altText: "Styled image",
      url: testImageURL().absoluteString
    )

    for colorScheme in [ColorScheme.light, ColorScheme.dark] {
      let view = imageBlock(photo: photo, colorScheme: colorScheme)
      let imageBlock = try view.inspect().find(ImageBlock.self).actualView()

      XCTAssertEqual(
        imageBlock.photo.altText,
        "Styled image",
        "ImageBlock.photo.altText should equal 'Styled image' for color scheme \(colorScheme)."
      )
      XCTAssertNoThrow(
        try view.inspect().find(viewWithAccessibilityLabel: "Styled image"),
        "Expected accessibility label 'Styled image' for color scheme \(colorScheme)."
      )
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

    XCTAssertNil(
      aspectRatio.aspectRatio,
      "Expected no explicit aspectRatio value when using .fit content mode."
    )
    XCTAssertEqual(
      aspectRatio.contentMode,
      .fit,
      "Expected image content mode to be .fit when URL is valid and no container size is provided."
    )
  }

  func testImageBlockWithoutURL_expandsToMaximumWidth() throws {
    let photo = makePhoto(altText: "Missing image", url: nil)

    let view = imageBlock(photo: photo, colorScheme: .light, width: nil, height: nil)
    let placeholder = try view.inspect().find(ViewType.Color.self)
    let frame = try placeholder.flexFrame()

    XCTAssertTrue(
      frame.maxWidth.isInfinite,
      "Expected placeholder to expand to maximum width when URL is nil."
    )
  }

  func testImageBlockWithEmptyURL_expandsToMaximumWidth() throws {
    let photo = makePhoto(altText: "Missing image", url: "")

    let view = imageBlock(photo: photo, colorScheme: .light, width: nil, height: nil)
    let placeholder = try view.inspect().find(ViewType.Color.self)
    let frame = try placeholder.flexFrame()

    XCTAssertTrue(
      frame.maxWidth.isInfinite,
      "Expected placeholder to expand to maximum width when URL is empty."
    )
  }

  func testImageBlockWithLink_wrapsImageInButton() throws {
    let photo = makePhoto(
      altText: "Linked image",
      url: testImageURL().absoluteString,
      link: URL(string: "https://backercrew.com/submit")
    )

    let view = imageBlock(photo: photo, colorScheme: .light)

    XCTAssertNoThrow(
      try view.inspect().find(ViewType.Button.self),
      "Expected ImageBlock to wrap its image in a Button when photo.link is set."
    )
  }

  func testImageBlockWithoutLink_doesNotWrapImageInButton() throws {
    let photo = makePhoto(
      altText: "Unlinked image",
      url: testImageURL().absoluteString
    )

    let view = imageBlock(photo: photo, colorScheme: .light)

    XCTAssertThrowsError(
      try view.inspect().find(ViewType.Button.self),
      "Expected ImageBlock not to wrap its image in a Button when photo.link is nil."
    )
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

    XCTAssertEqual(
      frame.width,
      containerWidth,
      "Expected ImageBlock width to respect the container width \(containerWidth). Actual: \(String(describing: frame.width))"
    )
    XCTAssertEqual(
      frame.height,
      containerHeight,
      "Expected ImageBlock height to respect the container height \(containerHeight). Actual: \(String(describing: frame.height))"
    )
  }

  func testImageBlockWithCaption_rendersCaptionText() throws {
    // Given a photo with a non-empty caption
    let photo = makePhoto(
      altText: "Test image",
      url: testImageURL().absoluteString,
      caption: "A descriptive caption"
    )

    // When rendering the ImageBlock
    let view = imageBlock(photo: photo, colorScheme: .light)

    // Then the caption should be present as a Text view with the expected string
    XCTAssertNoThrow(
      try view.inspect().find(text: "A descriptive caption"),
      "Expected ImageBlock to render the provided caption text."
    )
  }

  func testImageBlockWithoutCaption_doesNotRenderCaptionText() throws {
    // Given a photo whose caption is nil
    var photo = makePhoto(
      altText: "Test image",
      url: testImageURL().absoluteString,
      caption: nil
    )

    // When rendering the ImageBlock
    let view = imageBlock(photo: photo, colorScheme: .light)

    // Then no Text with an empty string or a placeholder should be found for caption
    XCTAssertThrowsError(
      try view.inspect().find(text: ""),
      "Expected ImageBlock not to render an empty caption Text when caption is nil."
    )
  }
}

private func makePhoto(
  altText: String?,
  url: String?,
  link: URL? = nil,
  caption: String? = "Test caption"
) -> RichTextElement.Photo {
  RichTextElement.Photo(
    altText: altText,
    assetID: "123",
    caption: caption,
    url: url,
    link: link
  )
}

private func testImageURL() -> URL {
  guard let imageURL = Bundle.module.url(forResource: "600x400", withExtension: "png") else {
    XCTFail("Expected bundled test image '600x400.png' to exist in test resources.")
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
