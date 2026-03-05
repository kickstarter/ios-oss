@testable import ServerDrivenUI
import ServerDrivenUITestHelpers
import SwiftUI
import Testing

@Test func automaticRichTextStyle_hasExpectedValues() async throws {
  let style = AutomaticRichTextStyle()
  #expect(style.linkUnderlined == true)
  #expect(style.blockSpacing > 0)
  #expect(style.listIndentation > 0)
  #expect(style.contentHorizontalPadding > 0)
  #expect(style.mediaCornerRadius >= 0)
}

@Test func lightAndDarkRichTextStyle_bodyColorsDiffer() async throws {
  let light = LightRichTextStyle()
  let dark = DarkRichTextStyle()
  #expect(light.bodyColor.uiColor() != dark.bodyColor.uiColor())
}
