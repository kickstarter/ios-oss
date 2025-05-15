import Foundation
import Kingfisher
import KsApi
import Library
import SwiftUI

struct PPOProjectDetails: View {
  let image: Source?
  let title: String?
  let pledge: String
  let leadingColumnWidth: CGFloat

  var body: some View {
    HStack {
      KFImage(source: self.image)
        .placeholder {
          LegacyColors.ksr_support_200.swiftUIColor()
        }
        .resizable()
        .clipShape(Constants.imageShape)
        .aspectRatio(
          Constants.imageAspectRatio,
          contentMode: Constants.imageContentMode
        )
        .frame(width: self.leadingColumnWidth)
      Spacer()
        .frame(width: Constants.spacing)
      VStack {
        if let title {
          Text(title)
            .font(Font(PPOStyles.title.font))
            .background(Color(PPOStyles.background))
            .foregroundStyle(Color(PPOStyles.title.color))
            .frame(
              maxWidth: Constants.textMaxWidth,
              alignment: Constants.textAlignment
            )
            .lineLimit(Constants.titleLineLimit)
            .multilineTextAlignment(Constants.multilineTextAlignment)
        }
        Text(Strings.Pledge_amount_pledged(pledge_amount: self.pledge))
          .font(Font(PPOStyles.subtitle.font))
          .background(Color(PPOStyles.background))
          .foregroundStyle(Color(PPOStyles.subtitle.color))
          .frame(
            maxWidth: Constants.textMaxWidth,
            alignment: Constants.textAlignment
          )
          .lineLimit(Constants.subtitleLineLimit)
          .multilineTextAlignment(Constants.multilineTextAlignment)
      }
    }
    .fixedSize(horizontal: false, vertical: true)
    .frame(maxWidth: .infinity)
  }

  private enum Constants {
    static let spacing: CGFloat = Styles.grid(1)

    static let imageShape = RoundedRectangle(cornerRadius: Styles.cornerRadius)
    static let imageAspectRatio: CGFloat = 16 / 9
    static let imageContentMode = ContentMode.fit

    static let titleLineLimit = 2
    static let subtitleLineLimit: Int? = nil

    static let textMaxWidth = CGFloat.infinity
    static let textAlignment = Alignment.leading
    static let multilineTextAlignment = TextAlignment.leading
  }
}

#Preview {
  VStack {
    GeometryReader(content: { geometry in
      PPOProjectDetails(
        image: .network(URL(string: "http:///")!),
        title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
        pledge: "$50.00",
        leadingColumnWidth: geometry.size.width / 4
      )
    })
    GeometryReader(content: { geometry in
      PPOProjectDetails(
        image: .network(URL(string: "http:///")!),
        title: "One line",
        pledge: "$50.00",
        leadingColumnWidth: geometry.size.width / 4
      )
    })
  }
  .padding(28)
}
