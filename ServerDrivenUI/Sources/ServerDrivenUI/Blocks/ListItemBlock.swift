import KDS
import SwiftUI

struct ListItemBlock: View {
  var text: RichTextElement.Text
  @Environment(\.richTextStyle) var style: any RichTextStyle

  public var body: some View {
    HStack(spacing: 0) {
      Text("•")
        .lineLimit(nil)
        .font(self.style.bodyFont)
        .foregroundStyle(self.style.bodyColor.swiftUIColor())
        .frame(maxWidth: self.style.listIndentation, maxHeight: .infinity, alignment: .topLeading)
      TextBlock(text: self.text, header: nil)
    }
    .background(self.style.backgroundColor.swiftUIColor())
  }
}
