import Foundation
import Kingfisher
import KsApi
import Library
import SwiftUI

struct PPOProjectDetails: View {
  let imageUrl: URL?
  let title: String?
  let pledge: GraphAPI.MoneyFragment
  let leadingColumnWidth: CGFloat

  var body: some View {
    HStack {
      KFImage(self.imageUrl)
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
            .font(Font(PPOCardStyles.title.font))
            .foregroundStyle(Color(PPOCardStyles.title.color))
            .frame(
              maxWidth: Constants.textMaxWidth,
              alignment: Constants.textAlignment
            )
            .lineLimit(Constants.titleLineLimit)
        }
        if let symbol = pledge.symbol, let amount = pledge.amount {
          // TODO: Localize
          Text("\(symbol)\(amount) pledged")
            .font(Font(PPOCardStyles.subtitle.font))
            .foregroundStyle(Color(PPOCardStyles.subtitle.color))
            .frame(
              maxWidth: Constants.textMaxWidth,
              alignment: Constants.textAlignment
            )
            .lineLimit(Constants.subtitleLineLimit)
        }
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
    static let subtitleLineLimit = 1

    static let textMaxWidth = CGFloat.infinity
    static let textAlignment = Alignment.leading
  }
}

#Preview {
  VStack {
    GeometryReader(content: { geometry in
      PPOProjectDetails(
        imageUrl: URL(string: "http:///")!,
        title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
        pledge: GraphAPI.MoneyFragment(amount: "50.00", currency: .usd, symbol: "$"),
        leadingColumnWidth: geometry.size.width / 4
      )
    })
    GeometryReader(content: { geometry in
      PPOProjectDetails(
        imageUrl: URL(string: "http:///")!,
        title: "One line",
        pledge: GraphAPI.MoneyFragment(amount: "50.00", currency: .usd, symbol: "$"),
        leadingColumnWidth: geometry.size.width / 4
      )
    })
  }
  .padding(28)
}
