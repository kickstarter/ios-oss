import Foundation
import Library
import SwiftUI

struct PPOAddressSummary: View {
  let address: String
  let leadingColumnWidth: CGFloat

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      Text(Strings.Shipping_address())
        .font(Font(PPOStyles.title.font))
        .foregroundStyle(Color(PPOStyles.title.color))
        .frame(width: self.leadingColumnWidth, alignment: Constants.textAlignment)

      Text(self.address)
        .font(Font(PPOStyles.body.font))
        .foregroundStyle(Color(PPOStyles.body.color))
        .frame(maxWidth: Constants.maxWidth, alignment: Constants.textAlignment)
    }
    .frame(maxWidth: Constants.maxWidth)
    .accessibilityElement(children: .combine)
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
