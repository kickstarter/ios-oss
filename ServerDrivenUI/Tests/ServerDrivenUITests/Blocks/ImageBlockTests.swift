import Kingfisher
@testable import LibraryTestHelpers
@testable import ServerDrivenUI
import ServerDrivenUITestHelpers
import SnapshotTesting
import SwiftUI
import XCTest

@MainActor
final class ImageBlockTests: TestCase {
  func testImageBlock() throws {
    guard let imageURL = Bundle.module.url(forResource: "600x400", withExtension: "png") else {
      XCTFail("no test photo")
      return
    }
    let photo = RichTextElement.Photo(
      altText: "Test image",
      assetID: "123",
      caption: "Test caption",
      url: imageURL.absoluteString
    )

    let view = ImageBlock(photo: photo)
      .frame(width: 300, height: 200)

    assertSnapshot(
      of: view,
      as: .image
    )
  }
}

private let colorSchemes = [ColorScheme.dark, ColorScheme.light]
private let contentSizes = [
  UIContentSizeCategory.extraExtraExtraLarge,
  UIContentSizeCategory.large,
  UIContentSizeCategory.small
]
