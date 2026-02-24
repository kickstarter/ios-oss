@testable import ServerDrivenUI
import SwiftUI
import Testing

@Test func darkRichTextStyle_hasExpectedValues() async throws {
  let style = DarkRichTextStyle()
  #expect(style.linkUnderlined == true)
  #expect(style.blockSpacing > 0)
  #expect(style.listIndentation > 0)
  #expect(style.contentHorizontalPadding > 0)
  #expect(style.mediaCornerRadius >= 0)
}
