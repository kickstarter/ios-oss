import Library
import SwiftUI

struct EstimatedShippingCheckoutView: View {
  let estimatedCost: String
  let aboutConversion: String

  private enum Constants {
    /// Spacing & Padding
    public static let defaultSpacing = Styles.grid(1)
    public static let verticalPadding = Styles.grid(2)
    public static let horizontalPadding = Styles.grid(4)
    public static let maxViewHeight = 125.0
    /// Font
    public static let headerFontSize = 16.0
    public static let subHeaderFontSize = 11.0
    public static let conversionSubHeaderFontSize = 12.0
    public static let headerFont = Font(UIFont.ksr_subhead(size: Constants.headerFontSize))
    public static let subHeaderFont = Font(UIFont.ksr_subhead(size: Constants.subHeaderFontSize))
    public static let conversionHeaderFont = Font(UIFont.ksr_subhead())
    public static let conversionSubHeaderFont = Font(
      UIFont
        .ksr_subhead(size: Constants.conversionSubHeaderFontSize)
    )
  }

  // TODO: Update strings with translations [mbl-1667](https://kickstarter.atlassian.net/browse/MBL-1667)
  var body: some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading, spacing: Constants.defaultSpacing) {
        Text("Estimated Shipping")
          .font(Constants.headerFont)
          .bold()
        Text(
          "This is meant to give you an idea of what shipping might cost. Once the creator is ready to fulfill your reward, you’ll return to pay shipping and applicable taxes."
        )
        .font(Constants.subHeaderFont)
        .foregroundStyle(Color(UIColor.ksr_support_400))
      }

      VStack(alignment: .trailing, spacing: Constants.defaultSpacing) {
        Text(self.estimatedCost)
          .font(Constants.conversionHeaderFont)
          .bold()
        Text(self.aboutConversion)
          .font(Constants.conversionSubHeaderFont)
          .foregroundStyle(Color(UIColor.ksr_support_400))
      }
    }
    .frame(maxHeight: Constants.maxViewHeight)
    .padding(.vertical, Constants.verticalPadding)
    .padding(.horizontal, Constants.horizontalPadding)
  }
}
