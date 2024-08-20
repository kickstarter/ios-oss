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
  @EnvironmentObject var style: PPOCardStyles

  var body: some View {
    HStack {
      KFImage(self.imageUrl)
        .resizable()
        .clipShape(self.style.projectDetails.imageShape)
        .aspectRatio(
          self.style.projectDetails.imageAspectRatio,
          contentMode: self.style.projectDetails.imageContentMode
        )
        .frame(width: self.leadingColumnWidth)
      Spacer()
        .frame(width: self.style.projectDetails.spacing)
      VStack {
        if let title {
          Text(title)
            .font(Font(self.style.projectDetails.titleFont))
            .foregroundStyle(Color(self.style.projectDetails.titleTextColor))
            .frame(
              maxWidth: self.style.projectDetails.textMaxWidth,
              alignment: self.style.projectDetails.textAlignment
            )
            .lineLimit(self.style.projectDetails.titleLineLimit)
        }
        if let symbol = pledge.symbol, let amount = pledge.amount {
          // TODO: Localize
          Text("\(symbol)\(amount) pledged")
            .font(Font(self.style.projectDetails.subtitleFont))
            .foregroundStyle(Color(self.style.projectDetails.subtitleTextColor))
            .frame(
              maxWidth: self.style.projectDetails.textMaxWidth,
              alignment: self.style.projectDetails.textAlignment
            )
            .lineLimit(self.style.projectDetails.subtitleLineLimit)
        }
      }
    }
    .fixedSize(horizontal: false, vertical: true)
    .frame(maxWidth: .infinity)
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
  .environmentObject(PPOCardStyles())
}
