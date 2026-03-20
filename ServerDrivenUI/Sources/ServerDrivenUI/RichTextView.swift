import KDS
import SwiftUI

public struct RichTextView: View {
  public var element: [RichTextElement]
  @Environment(\.richTextStyle) var style: any RichTextStyle

  public init(element: [RichTextElement]) {
    self.element = element
  }

  private func font(for header: RichTextElement.HeaderLevel?) -> Font {
    switch header {
    case .none:
      return self.style.bodyFont
    case .some(.one):
      return self.style.heading1Font
    case .some(.two):
      return self.style.heading2Font
    case .some(.three):
      return self.style.heading3Font
    case .some(.four):
      return self.style.heading4Font
    }
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

  @ViewBuilder private func unimplemented(_ text: String) -> some View {
    Text("Unimplemented! \(text)")
      .font(.footnote)
      .foregroundStyle(Color.red)
      .frame(maxWidth: .infinity, alignment: .center)
      .padding()
      .backgroundStyle(Color.gray)
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

  func text(_ text: RichTextElement.Text, header: RichTextElement.HeaderLevel? = nil) -> some View {
    let attributedString = self.attributedText(text, header: header)
    return self.textView(attributedString, header: header)
  }

  @ViewBuilder
  func textView(
    _ attributedString: AttributedString,
    header: RichTextElement.HeaderLevel? = nil
  ) -> some View {
    Text(attributedString)
      .lineLimit(nil)
      .foregroundStyle(self.color(for: header).swiftUIColor())
      .frame(maxWidth: .infinity, alignment: .leading)
  }

  public var body: some View {
    LazyVStack(spacing: self.style.blockSpacing) {
      ForEach(Array(self.element.enumerated()), id: \.offset) { _, element in
        switch element {
        case let .text(text, header):
          self.text(text, header: header)
        case .listItemOpen:
          Group {}
        case .listItemClose:
          Group {}
        case let .listItem(listItem):
          HStack(spacing: 0) {
            Text("•")
              .lineLimit(nil)
              .font(self.style.bodyFont)
              .foregroundStyle(self.style.bodyColor.swiftUIColor())
              .frame(maxWidth: self.style.listIndentation, maxHeight: .infinity, alignment: .topLeading)
            self.text(listItem)
          }
        case .audio:
          self.unimplemented("Audio")
        case .photo:
          self.unimplemented("Photo")
        case .video:
          self.unimplemented("Video")
        case .oembed:
          self.unimplemented("Oembed")
        }
      }
    }
    .padding(.horizontal, self.style.contentHorizontalPadding)
  }
}
