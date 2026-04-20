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
    [helloWorldPlain, longTextPlain],
    orthogonalCombos(colorSchemes, contentSizes)
  )
  func testBasicText(
    text: RichTextElement.Text,
    properties: (ColorScheme, UIContentSizeCategory),
  ) async throws {
    let (colorScheme, contentSizeCategory) = properties
    UITraitCollection(preferredContentSizeCategory: contentSizeCategory).performAsCurrent {
      let view = TextBlock(text: text)
        .frame(width: 500)
        .frame(maxHeight: .infinity)
        .environment(\.colorScheme, colorScheme)

      assertSnapshot(
        of: view,
        as: .image,
        named: "\(text.text.prefix(10))-\(colorScheme)-\(contentSizeCategory)"
      )
    }
  }

  @Test(
    "Test styled text rendering",
    .snapshots(record: .failed),

    arguments:
    [helloWorldStyled, longTextStyled],
    orthogonalCombos(colorSchemes, contentSizes)
  )
  func testStyles(
    text: RichTextElement.Text,
    properties: (ColorScheme, UIContentSizeCategory),
  ) async throws {
    let (colorScheme, contentSizeCategory) = properties
    UITraitCollection(preferredContentSizeCategory: contentSizeCategory).performAsCurrent {
      let view = TextBlock(text: text)
        .frame(width: 500)
        .frame(maxHeight: .infinity)
        .environment(\.colorScheme, colorScheme)

      let fullText = text.children.compactMap {
        if case let .text(text, _) = $0 {
          return text
        } else {
          return nil
        }
      }
      let contents = fullText.map { $0.text }.joined()

      assertSnapshot(
        of: view,
        as: .image,
        named: "\(contents.prefix(10))-\(colorScheme)-\(contentSizeCategory)"
      )
    }
  }

  @Test(
    "Test list item text rendering",
    .snapshots(record: .failed),

    arguments:
    [helloWorldPlain, longTextStyled],
    orthogonalCombos(colorSchemes, contentSizes)
  )
  func testListItemText(
    text: RichTextElement.Text,
    properties: (ColorScheme, UIContentSizeCategory),
  ) async throws {
    let (colorScheme, contentSizeCategory) = properties
    UITraitCollection(preferredContentSizeCategory: contentSizeCategory).performAsCurrent {
      let view = ListItemBlock(text: text)
        .frame(width: 500)
        .frame(maxHeight: .infinity)
        .environment(\.colorScheme, colorScheme)

      assertSnapshot(
        of: view,
        as: .image,
        named: "\(text.text.prefix(10))-\(colorScheme)-\(contentSizeCategory)"
      )
    }
  }
}

private let colorSchemes = [ColorScheme.dark, ColorScheme.light]
private let contentSizes = [
  UIContentSizeCategory.accessibilityExtraExtraExtraLarge,
  UIContentSizeCategory.extraExtraExtraLarge,
  UIContentSizeCategory.large,
  UIContentSizeCategory.extraSmall
]

private let helloWorldPlain = makeText("Hello world")
private let helloWorldStyled = makeText(("Hello ", nil), ("world", .strong), ("!", nil))
private let longTextPlain =
  makeText(
    "Swift Testing has a clear and expressive API built using macros, so you can declare complex behaviors with a small amount of code."
  )
private let longTextStyled = makeText(
  ("Swift Testing has a ", nil),
  ("clear", .strong),
  (" and ", nil),
  ("expressive", .emphasis),
  (" API built using macros, so you can declare complex behaviors with a small amount of code.", nil)
)

private func makeText(_ text: String) -> RichTextElement.Text {
  RichTextElement.Text(text: text)
}

private func makeText(_ args: (String, RichTextElement.Text.Style?)...) -> RichTextElement.Text {
  RichTextElement.Text(text: "", children: args.map { text, style in
    .text(RichTextElement.Text(text: text, link: nil, styles: [style].compactMap { $0 }, children: []), nil)
  })
}
