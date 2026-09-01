import KDS
import Library
import SwiftUI

struct VideoFeedSharePreviewCard<Thumbnail: View>: View {
  private enum Constants {
    static var kickstarterWordmarkAssetName: String { "share-kickstarter-wordmark" }
  }

  let item: VideoFeedItem
  @ViewBuilder let thumbnail: () -> Thumbnail

  var body: some View {
    VStack(alignment: .leading, spacing: 32) {
      Color.clear
        .aspectRatio(16 / 9, contentMode: .fit)
        .overlay(self.thumbnail())
        .clipped()

      VStack(alignment: .leading, spacing: 8) {
        Text(self.item.title)
          .font(Font(UIFont.ksr_subhead().bolded))
          .foregroundColor(Color(Colors.Text.constantPrimary.uiColor()))
          .lineLimit(2)

        Text(self.item.creator)
          .font(Font(UIFont.ksr_caption1()))
          .foregroundColor(Color(Colors.Text.constantPrimary.uiColor()))
      }

      if let image = Library.image(named: Constants.kickstarterWordmarkAssetName) {
        Image(uiImage: image)
          .resizable()
          .scaledToFit()
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .padding(12)
    .background(Color(Colors.Icon.light.uiColor()))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}
