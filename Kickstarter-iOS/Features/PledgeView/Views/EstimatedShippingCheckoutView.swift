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

  var body: some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading, spacing: Constants.defaultSpacing) {
        Text(Strings.Estimated_Shipping())
          .font(Constants.headerFont)
          .bold()
        Text(Strings.This_is_meant_to_give_you())
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
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(.vertical, Constants.verticalPadding)
    .padding(.horizontal, Constants.horizontalPadding)
  }
}
