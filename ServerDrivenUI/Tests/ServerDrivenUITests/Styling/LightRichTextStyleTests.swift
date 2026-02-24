@testable import ServerDrivenUI
import SwiftUI
import Testing

// MARK: - LightRichTextStyle

@Test func lightRichTextStyle_hasExpectedValues() async throws {
  let style = LightRichTextStyle()
  #expect(style.linkUnderlined == true)
  #expect(style.blockSpacing > 0)
  #expect(style.listIndentation > 0)
  #expect(style.contentHorizontalPadding > 0)
  #expect(style.mediaCornerRadius >= 0)
}
