@testable import ServerDrivenUI
import ServerDrivenUITestHelpers
import SnapshotTesting
import SwiftUI
import XCTest

struct RichTextStylePreviewView: View {
  @Environment(\.richTextStyle) private var style

  var body: some View {
    VStack(alignment: .leading, spacing: self.style.blockSpacing) {
      Text("Body")
        .font(self.style.bodyFont)
        .foregroundStyle(self.style.bodyColor.swiftUIColor())

      Text("Heading 1")
        .font(self.style.heading1Font)
        .foregroundStyle(self.style.headingColor.swiftUIColor())

      Text("Heading 2")
        .font(self.style.heading2Font)
        .foregroundStyle(self.style.headingColor.swiftUIColor())

      Text("Heading 3")
        .font(self.style.heading3Font)
        .foregroundStyle(self.style.headingColor.swiftUIColor())

      Text("Heading 4")
        .font(self.style.heading4Font)
        .foregroundStyle(self.style.headingColor.swiftUIColor())

      Text("Link")
        .font(self.style.bodyFont)
        .foregroundStyle(self.style.linkColor.swiftUIColor())
        .underline(self.style.linkUnderlined)

      RoundedRectangle(cornerRadius: self.style.mediaCornerRadius)
        .fill(self.style.bodyColor.swiftUIColor())
        .frame(height: 40)

      VStack(alignment: .leading, spacing: 4) {
        Text("listIndentation: \(self.style.listIndentation, specifier: "%.0f")")
          .font(self.style.bodyFont)
          .foregroundStyle(self.style.bodyColor.swiftUIColor())
      }
    }
    .padding(self.style.contentHorizontalPadding)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(self.style.backgroundColor.swiftUIColor())
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
