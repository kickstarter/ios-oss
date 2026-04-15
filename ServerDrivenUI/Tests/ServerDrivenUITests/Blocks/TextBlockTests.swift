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
        DynamicTypeSize.xSmall
      ]
    )
  )
  func testBasicText(
    text: RichTextElement.Text,
    properties: (ColorScheme, DynamicTypeSize),
  ) async throws {
    let (colorScheme, typeSize) = properties
    let view = TextBlock(text: text)
      .frame(width: 500)
      .frame(maxHeight: .infinity)
      .environment(\.colorScheme, colorScheme)
      .environment(\.dynamicTypeSize, typeSize)

    assertSnapshot(of: view, as: .image, named: "\(text.text.prefix(10))-\(colorScheme)-\(typeSize)")
  }

  @Test(
    "Test styled text rendering",
    .snapshots(record: .failed),
    arguments:
    [ /* Text contents */
      RichTextElement.Text(text: "", children: [
        .text(RichTextElement.Text(text: "Hello "), nil),
        .text(RichTextElement.Text(text: "world", styles: [.strong]), nil),
        .text(RichTextElement.Text(text: "!"), nil)
      ]),
      RichTextElement.Text(text: "", children: [
        .text(RichTextElement.Text(
          text: "Swift Testing has a "
        ), nil),
        .text(RichTextElement.Text(
          text: "clear",
          styles: [.strong],
        ), nil),
        .text(RichTextElement.Text(
          text: " and "
        ), nil),
        .text(RichTextElement.Text(
          text: "expressive",
          styles: [.emphasis]
        ), nil),
        .text(RichTextElement.Text(
          text: " API built using macros, so you can declare complex behaviors with a small amount of code."
        ), nil)
      ])
    ], orthogonalCombos(
      [ /* Color scheme */
        ColorScheme.dark,
        ColorScheme.light
      ], [ /* Content size */
        DynamicTypeSize.xSmall,
        DynamicTypeSize.large,
        DynamicTypeSize.xxxLarge,
        DynamicTypeSize.accessibility5
      ]
    )
  )
  func testStyles(
    text: RichTextElement.Text,
    properties: (ColorScheme, DynamicTypeSize),
  ) async throws {
    let (colorScheme, typeSize) = properties
    let view = TextBlock(text: text)
      .frame(width: 500)
      .frame(maxHeight: .infinity)
      .environment(\.colorScheme, colorScheme)
      .environment(\.dynamicTypeSize, typeSize)

    let fullText = text.children.compactMap {
      if case let .text(text, _) = $0 {
        return text
      } else {
        return nil
      }
    }
    let contents = fullText.map { $0.text }.joined()

    assertSnapshot(of: view, as: .image, named: "\(contents.prefix(10))-\(colorScheme)-\(typeSize)")
  }

  @Test(
    "Test list item text rendering",
    .snapshots(record: .failed),
    arguments:
    [ /* Text contents */
      RichTextElement.Text(text: "Hello world"),
      RichTextElement.Text(text: "", children: [
        .text(RichTextElement.Text(
          text: "Swift Testing has a "
        ), nil),
        .text(RichTextElement.Text(
          text: "clear",
          styles: [.strong],
        ), nil),
        .text(RichTextElement.Text(
          text: " and "
        ), nil),
        .text(RichTextElement.Text(
          text: "expressive",
          styles: [.emphasis]
        ), nil),
        .text(RichTextElement.Text(
          text: " API built using macros, so you can declare complex behaviors with a small amount of code."
        ), nil)
      ])
    ], orthogonalCombos(
      [ /* Color scheme */
        ColorScheme.dark,
        ColorScheme.light
      ], [ /* Content size */
        DynamicTypeSize.accessibility5,
        DynamicTypeSize.xxxLarge,
        DynamicTypeSize.large,
        DynamicTypeSize.xSmall
      ]
    )
  )
  func testListItemText(
    text: RichTextElement.Text,
    properties: (ColorScheme, DynamicTypeSize),
  ) async throws {
    let (colorScheme, typeSize) = properties
    let view = ListItemBlock(text: text)
      .frame(width: 500)
      .frame(maxHeight: .infinity)
      .environment(\.colorScheme, colorScheme)
      .environment(\.dynamicTypeSize, typeSize)

    assertSnapshot(of: view, as: .image, named: "\(text.text.prefix(10))-\(colorScheme)-\(typeSize)")
  }
}
