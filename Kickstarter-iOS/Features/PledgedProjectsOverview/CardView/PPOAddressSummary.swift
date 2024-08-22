import Foundation
import SwiftUI

struct PPOAddressSummary: View {
  let address: String
  let leadingColumnWidth: CGFloat

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      // TODO: Localize
      Text("Shipping address")
        .font(Font(PPOCardStyles.title.font))
        .foregroundStyle(Color(PPOCardStyles.title.color))
        .frame(width: self.leadingColumnWidth, alignment: Constants.textAlignment)

      Text(self.address)
        .font(Font(PPOCardStyles.body.font))
        .foregroundStyle(Color(PPOCardStyles.body.color))
        .frame(maxWidth: Constants.maxWidth, alignment: Constants.textAlignment)
    }
    .frame(maxWidth: Constants.maxWidth)
  }

  private enum Constants {
    static let textAlignment = Alignment.leadingLastTextBaseline
    static let maxWidth = CGFloat.infinity
  }
}

#Preview {
  VStack(spacing: 28) {
    GeometryReader(content: { geometry in
      PPOAddressSummary(
        address: """
          Firsty Lasty
          123 First Street, Apt #5678
          Los Angeles, CA 90025-1234
          United States
        """,
        leadingColumnWidth: geometry.size.width / 4
      )
    })
  }
  .padding(28)
}
