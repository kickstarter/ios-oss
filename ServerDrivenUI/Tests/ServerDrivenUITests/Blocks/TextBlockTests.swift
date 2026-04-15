import LibraryTestHelpers
@testable import ServerDrivenUI
import ServerDrivenUITestHelpers
import SnapshotTesting
import SwiftUI
import Testing

@MainActor
@Suite("TextBlock", .tags(.serverDrivenUI))
struct TextBlockTests {
  @Test(
    "Test basic text rendering",
    .snapshots(record: .failed),
    arguments:
    [ /* Text contents */
      RichTextElement.Text(text: "Hello world"),
      RichTextElement
        .Text(
          text: "Swift Testing has a clear and expressive API built using macros, so you can declare complex behaviors with a small amount of code."
        )
    ], orthogonalCombos(
      [ /* Color scheme */
        ColorScheme.dark,
        ColorScheme.light
      ], [ /* Content size */
        DynamicTypeSize.accessibility5,
        DynamicTypeSize.xxxLarge,
        DynamicTypeSize.large,
        DynamicTypeSize.xSmall,
      ]
    )
  )
  func testBasicText(
    text: RichTextElement.Text,
    properties: (ColorScheme, DynamicTypeSize),
  ) async throws {
    let (colorScheme, typeSize) = properties
    let view = TextBlock(text: text)
      .frame(width: 300)
      .frame(maxHeight: .infinity)
      .environment(\.colorScheme, colorScheme)
      .environment(\.dynamicTypeSize, typeSize)

    assertSnapshot(of: view, as: .image, named: "\(text.text.prefix(10))-\(colorScheme)-\(typeSize)")
  }
}

/*
 init(text: String, link: URL?, styles: [Style], children: [RichTextElement]) {
   self.text = text
   self.link = link
   self.styles = styles
   self.children = children
 }
 */
