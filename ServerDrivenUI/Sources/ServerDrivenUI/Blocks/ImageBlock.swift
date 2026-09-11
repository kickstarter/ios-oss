import KDS
import Kingfisher
import SwiftUI

struct ImageBlock: View {
  var photo: RichTextElement.Photo
  @Environment(\.richTextStyle) var style: any RichTextStyle
  @Environment(\.openURL) private var openURL

  private var imageURL: URL? {
    guard let urlString = photo.url, !urlString.isEmpty else {
      return nil
    }
    return URL(string: urlString)
  }

  private var caption: AttributedString? {
    guard let caption = self.photo.caption else {
      return nil
    }

    var attributes = AttributeContainer()
    attributes.font = self.style.mediaCaptionFont
    attributes.foregroundColor = self.style.mediaCaptionColor.swiftUIColor()
    if let link = self.photo.link {
      attributes.link = link
      attributes.underlineStyle = self.style.linkUnderlined ? .single : .none
    }
    return AttributedString(caption, attributes: attributes)
  }

  @ViewBuilder private var image: some View {
    VStack {
      if let imageURL {
        KFAnimatedImage(imageURL)
          .placeholder { _ in
            Color(self.style.mediaPlaceholderColor.swiftUIColor())
              .aspectRatio(16 / 9, contentMode: .fill)
          }
          .aspectRatio(contentMode: .fit)
          .clipShape(RoundedRectangle(cornerRadius: self.style.mediaCornerRadius))
          .accessibilityElement()
          .accessibilityAddTraits(.isImage)
          .accessibilityLabel(self.photo.altText ?? "")
      } else {
        Color.clear
          .frame(maxWidth: .infinity)
          .accessibilityLabel(self.photo.altText ?? "")
      }
      if let caption = self.caption {
        Text(caption)
          .multilineTextAlignment(self.style.mediaCaptionAlignment)
      }
    }
  }

  public var body: some View {
    if let link = photo.link {
      Button {
        self.openURL(link)
      } label: {
        self.image
      }
      .buttonStyle(.plain)
    } else {
      self.image
    }
  }
}
