import Library
import SwiftUI

struct EstimatedShippingCheckoutView: View {
  let estimatedCost: String
  let aboutConversion: String

  private enum Constants {
    public static let maxHeight = 125.0
    public static let defaultSpacing = Styles.grid(1)
    public static let verticalPadding = Styles.grid(2)
    public static let horizontalPadding = Styles.grid(4)
  }

  // TODO: Update strings with translations [mbl-1667](https://kickstarter.atlassian.net/browse/MBL-1667)
  var body: some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading, spacing: Constants.defaultSpacing) {
        Text("Estimated Shipping")
          .font(Font(UIFont.ksr_subhead(size: 16)))
          .bold()
        Text(
          "This is meant to give you an idea of what shipping might cost. Once the creator is ready to fulfill your reward, you’ll return to pay shipping and applicable taxes."
        )
        .font(Font(UIFont.ksr_subhead(size: 11)))
      }

      VStack(alignment: .leading, spacing: Constants.defaultSpacing) {
        Text(self.estimatedCost)
          .font(Font(UIFont.ksr_subhead()))
          .bold()
        Text(self.aboutConversion)
          .font(Font(UIFont.ksr_subhead(size: 12)))
      }
    }
    .frame(maxHeight: Constants.maxHeight)
    .padding(.vertical, Constants.verticalPadding)
    .padding(.horizontal, Constants.horizontalPadding)
  }
}
