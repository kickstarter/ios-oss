import KDS
import SwiftUI

public struct RichTextView: View {
  public var element: [RichTextElement]
  @Environment(\.richTextStyle) var style: any RichTextStyle

  public init(element: [RichTextElement]) {
    self.element = element
  }

  @ViewBuilder private func unimplemented(_ text: String) -> some View {
    Text("Unimplemented! \(text)")
      .font(.footnote)
      .foregroundStyle(Color.red)
      .frame(maxWidth: .infinity, alignment: .center)
      .padding()
      .backgroundStyle(Color.gray)
  }

  public var body: some View {
    LazyVStack(spacing: self.style.blockSpacing) {
      ForEach(Array(self.element.enumerated()), id: \.offset) { _, element in
        switch element {
        case let .text(text, header):
          TextBlock(text: text, header: header)
        case let .listItem(text):
          HStack(spacing: 0) {
            Text("•")
              .lineLimit(nil)
              .font(self.style.bodyFont)
              .foregroundStyle(self.style.bodyColor.swiftUIColor())
              .frame(maxWidth: self.style.listIndentation, maxHeight: .infinity, alignment: .topLeading)
            TextBlock(text: text, header: nil)
          }
        case .audio:
          self.unimplemented("Audio")
        case .photo:
          self.unimplemented("Photo")
        case .video:
          self.unimplemented("Video")
        case .oembed:
          self.unimplemented("Oembed")
        case .listItemOpen, .listItemClose:
          Group {}
        }
      }
    }
    .padding(.horizontal, self.style.contentHorizontalPadding)
  }
}
