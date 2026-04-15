import KDS
import SwiftUI

struct TextBlock: View {
  var text: RichTextElement.Text
  var header: RichTextElement.HeaderLevel?
  @Environment(\.richTextStyle) var style: any RichTextStyle
  @Environment(\.dynamicTypeSize) var dynamicTypeSize

  private func font(for header: RichTextElement.HeaderLevel?) -> Font {
    let baseFont = switch header {
    case .none:
      self.style.bodyFont
    case .some(.one):
      self.style.heading1Font
    case .some(.two):
      self.style.heading2Font
    case .some(.three):
      self.style.heading3Font
    case .some(.four):
      self.style.heading4Font
    }
    return baseFont.swiftUIFont(size: nil, dynamicTypeSize: self.dynamicTypeSize)
  }

  private func color(for header: RichTextElement.HeaderLevel?) -> any AdaptiveColor {
    switch header {
    case .none:
      return self.style.bodyColor
    case .some(.one),
         .some(.two),
         .some(.three),
         .some(.four):
      return self.style.headingColor
    }
  }

  func attributedText(
    _ text: RichTextElement.Text,
    header: RichTextElement.HeaderLevel? = nil
  ) -> AttributedString {
    var attributes = AttributeContainer()
    attributes.font = self.font(for: header)
    for style in text.styles {
      switch style {
      case .strong:
        attributes.font = (attributes.font.take() ?? self.font(for: header)).bold()
      case .emphasis:
        attributes.font = (attributes.font.take() ?? self.font(for: header)).italic()
      case .heading1:
        attributes.font = self.font(for: .one)
      case .heading2:
        attributes.font = self.font(for: .two)
      case .heading3:
        attributes.font = self.font(for: .three)
      case .heading4:
        attributes.font = self.font(for: .four)
      }
    }
    var baseAttributedString = AttributedString(text.text, attributes: attributes)
    for child in text.children {
      switch child {
      case let .text(childText, childHeaderLevel):
        let childAttributedString = self.attributedText(childText, header: childHeaderLevel)
        baseAttributedString.append(childAttributedString)
      case .photo:
        // TODO: MBL-2890
        break
      default:
        assertionFailure("Unimplemented child element type")
      }
    }
    return baseAttributedString
  }

  @ViewBuilder
  func textView(
    _ attributedString: AttributedString,
    header: RichTextElement.HeaderLevel? = nil
  ) -> some View {
    let accessiblityHeading: AccessibilityHeadingLevel = switch header {
    case .none: .unspecified
    case .one: .h1
    case .two: .h2
    case .three: .h3
    case .four: .h4
    }

    Text(attributedString)
      .lineLimit(nil)
      .fixedSize(horizontal: false, vertical: true)
      .background(self.style.backgroundColor.swiftUIColor(opacity: 1))
      .foregroundStyle(self.color(for: header).swiftUIColor())
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
      .accessibilityAddTraits((header != nil) ? .isHeader : .isStaticText)
      .accessibilityElement()
      .accessibilityHeading(accessiblityHeading)
  }

  public var body: some View {
    let attributedString = self.attributedText(self.text, header: self.header)
    return self.textView(attributedString, header: self.header)
  }
}
