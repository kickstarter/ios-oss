import Foundation
import SwiftUI

struct PPOAddressSummary: View {
  let address: String
  let leadingColumnWidth: CGFloat

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      // TODO: Localize
      Text("Shipping address")
        .lineLimit(nil)
        .font(Font(Constants.labelFont))
        .foregroundStyle(Color(Constants.labelColor))
        .frame(width: self.leadingColumnWidth, alignment: .leading)
        .multilineTextAlignment(.leading)

      Text(self.address)
        .lineLimit(nil)
        .multilineTextAlignment(.leading)
        .font(Font(Constants.addressFont))
        .foregroundStyle(Color(Constants.addressColor))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .frame(maxWidth: .infinity)
  }

  private enum Constants {
    static let labelFont = UIFont.ksr_caption1().bolded
    static let labelColor = UIColor.ksr_black
    static let addressFont = UIFont.ksr_caption1()
    static let addressColor = UIColor.ksr_black
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
