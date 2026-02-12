import Foundation
import KDS
import Library
import SwiftUI

struct PPOAddressSummary: View {
  let address: String
  let leadingColumnWidth: CGFloat
  let editable: Bool

  var body: some View {
    HStack(alignment: .top, spacing: Spacing.unit_02) {
      Text(Strings.Shipping_address())
        .font(Font(PPOStyles.body.font).weight(.semibold))
        .multilineTextAlignment(.leading)
        .foregroundStyle(Color(PPOStyles.title.color))
        .frame(width: self.leadingColumnWidth, alignment: Constants.textAlignment)

      Text(self.address)
        .font(Font(PPOStyles.body.font))
        .multilineTextAlignment(.leading)
        .foregroundStyle(Color(PPOStyles.body.color))
        .frame(maxWidth: Constants.maxWidth, alignment: Constants.textAlignment)

      if self.editable {
        Image(PPOStyles.editAddressImage)
          .resizable()
          .scaledToFit()
          .frame(width: Constants.editIconSize, height: Constants.editIconSize)
          .background(Color(PPOStyles.background))
          .foregroundStyle(Color(Constants.iconColor))
      }
    }
    .frame(maxWidth: Constants.maxWidth)
    .accessibilityElement(children: .combine)
  }

  private enum Constants {
    static let textAlignment = Alignment.topLeading
    static let maxWidth = CGFloat.infinity
    static let editIconSize = Spacing.unit_06
    static let iconColor = PPOStyles.subtitle.color
  }
}

#Preview {
  GeometryReader(content: { geometry in
    VStack(spacing: 28) {
      PPOAddressSummary(
        address: """
          Firsty Lasty
          123 First Street, Apt #5678
          Los Angeles, CA 90025-1234
          United States
        """,
        leadingColumnWidth: geometry.size.width / 4,
        editable: true
      )
      PPOAddressSummary(
        address: """
          Final Address
          123 First Street, Apt #5678
          Los Angeles, CA 90025-1234
          United States
        """,
        leadingColumnWidth: geometry.size.width / 4,
        editable: false
      )
    }
  })
  .padding(28)
}
