import KDS
import Kingfisher
import SwiftUI

struct ImageBlock: View {
  var photo: RichTextElement.Photo
  @Environment(\.richTextStyle) var style: any RichTextStyle

  private var imageURL: URL? {
    guard let urlString = photo.url, !urlString.isEmpty else {
      return nil
    }
    return URL(string: urlString)
  }

  public var body: some View {
    Group {
      if let imageURL {
        KFAnimatedImage(imageURL)
          .placeholder { _ in
            Color(self.style.mediaPlaceholderColor.swiftUIColor())
              .aspectRatio(16 / 9, contentMode: .fill)
          }
          .clipShape(RoundedRectangle(cornerRadius: self.style.mediaCornerRadius))
          .accessibilityLabel(self.photo.altText ?? "")
      } else {
        Color.clear
          .frame(maxWidth: .infinity)
          .accessibilityLabel(self.photo.altText ?? "")
      }
    }
  }
}
