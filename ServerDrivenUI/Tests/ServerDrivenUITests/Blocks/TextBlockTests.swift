@testable import LibraryTestHelpers
@testable import ServerDrivenUI
import ServerDrivenUITestHelpers
import SnapshotTesting
import SwiftUI

@MainActor
final class TextBlockTests: TestCase {
  func testBasicText() throws {
    let texts: [RichTextElement.Text] = [helloWorldPlain, longTextPlain]

    for colorScheme in colorSchemes {
      for contentSizeCategory in contentSizes {
        for text in texts {
          UITraitCollection(preferredContentSizeCategory: contentSizeCategory).performAsCurrent {
            let view = TextBlock(text: text)
              .frame(width: 500)
              .frame(maxHeight: .infinity)
              .environment(\.richTextStyle, richTextStyle(colorScheme))

            assertSnapshot(
              of: view,
              as: .image,
              named: "\(shortName(text))-\(colorScheme)-\(contentSizeCategory.rawValue)"
            )
          }
        }
      }
    }
  }

  func testStyles() throws {
    let texts: [RichTextElement.Text] = [helloWorldStyled, longTextStyled]

    for colorScheme in colorSchemes {
      for contentSizeCategory in contentSizes {
        for text in texts {
          UITraitCollection(preferredContentSizeCategory: contentSizeCategory).performAsCurrent {
            let view = TextBlock(text: text)
              .frame(width: 500)
              .frame(maxHeight: .infinity)
              .environment(\.richTextStyle, richTextStyle(colorScheme))

            assertSnapshot(
              of: view,
              as: .image,
              named: "\(shortName(text))-\(colorScheme)-\(contentSizeCategory.rawValue)"
            )
          }
        }
      }
    }
  }

  func testListItemText() throws {
    let texts: [RichTextElement.Text] = [helloWorldPlain, longTextStyled]

    for colorScheme in colorSchemes {
      for contentSizeCategory in contentSizes {
        for text in texts {
          UITraitCollection(preferredContentSizeCategory: contentSizeCategory).performAsCurrent {
            let view = ListItemBlock(text: text)
              .frame(width: 500)
              .frame(maxHeight: .infinity)
              .environment(\.richTextStyle, richTextStyle(colorScheme))

            assertSnapshot(
              of: view,
              as: .image,
              named: "\(shortName(text))-\(colorScheme)-\(contentSizeCategory.rawValue)"
            )
          }
        }
      }
    }
  }
}

private let colorSchemes = [ColorScheme.dark, ColorScheme.light]
private let contentSizes = [
  UIContentSizeCategory.extraExtraExtraLarge,
  UIContentSizeCategory.large,
  UIContentSizeCategory.small
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

private func shortName(_ text: RichTextElement.Text) -> Substring {
  let fullText = text.children.compactMap {
    if case let .text(text, _) = $0 {
      return text
    } else {
      return nil
    }
  }
  let contents = text.text + (fullText.map { $0.text }.joined())
  return contents.prefix(12)
}
