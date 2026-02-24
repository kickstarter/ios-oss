@testable import ServerDrivenUI
import SnapshotTesting
import SwiftUI
import XCTest

struct RichTextStylePreviewView: View {
  @Environment(\.richTextStyle) private var style

  var body: some View {
    VStack(alignment: .leading, spacing: style.blockSpacing) {
      Text("Body")
        .font(style.bodyFont)
        .foregroundStyle(style.bodyColor)

      Text("Heading 1")
        .font(style.heading1Font)
        .foregroundStyle(style.headingColor)

      Text("Heading 2")
        .font(style.heading2Font)
        .foregroundStyle(style.headingColor)

      Text("Heading 3")
        .font(style.heading3Font)
        .foregroundStyle(style.headingColor)

      Text("Heading 4")
        .font(style.heading4Font)
        .foregroundStyle(style.headingColor)

      Text("Link")
        .font(style.bodyFont)
        .foregroundStyle(style.linkColor)
        .underline(style.linkUnderlined)

      RoundedRectangle(cornerRadius: style.mediaCornerRadius)
        .fill(style.bodyColor)
        .frame(height: 40)

      VStack(alignment: .leading, spacing: 4) {
        Text("listIndentation: \(style.listIndentation, specifier: "%.0f")")
          .font(style.bodyFont)
          .foregroundStyle(style.bodyColor)
      }
    }
    .padding(style.contentHorizontalPadding)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(style.backgroundColor)
  }
}


// MARK: - Snapshot tests

final class RichTextStyleSnapshotTests: XCTestCase {
  func testRichTextStylePreview_lightStyle() {
    let view = RichTextStylePreviewView()
      .environment(\.sizeCategory, ContentSizeCategory.medium)
      .environment(\.richTextStyle, LightRichTextStyle())
      .environment(\.colorScheme, .light)
      .frame(width: 375, height: 400)

    assertSnapshot(matching: view, as: .image, named: "light")
  }

  func testRichTextStylePreview_darkStyle() {
    let view = RichTextStylePreviewView()
      .environment(\.sizeCategory, ContentSizeCategory.medium)
      .environment(\.richTextStyle, DarkRichTextStyle())
      .environment(\.colorScheme, .dark)
      .frame(width: 375, height: 400)

    assertSnapshot(matching: view, as: .image, named: "dark")
  }
}
