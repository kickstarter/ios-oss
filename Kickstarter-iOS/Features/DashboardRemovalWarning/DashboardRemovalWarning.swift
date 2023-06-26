import Library
import SwiftUI

@available(iOS 15.0, *)
struct DashboardRemovalWarning: View {
  var body: some View {
    HStack(spacing: 0) {
      Image("fix-icon")
        .resizable()
        .scaledToFit()
        .foregroundColor(Color(UIColor.ksr_white))
        .frame(width: 18, height: 18)
        .padding(.horizontal, 12)

      Text("After August 14, 2023, the Dashboard and Post Update features will only be available on our website.")
        .font(Font(UIFont.ksr_subhead(size: 15)))
        .foregroundColor(Color(UIColor.ksr_white))
        .lineLimit(nil)
        .padding(.vertical, 12)
        .padding(.trailing, 12)
    }
    .frame(maxWidth: .infinity, alignment: .center)
    .background(Color(UIColor.ksr_alert))
  }
}

@available(iOS 15.0, *)
struct DashboardRemovalWarning_Previews: PreviewProvider {
  static var previews: some View {
    DashboardRemovalWarning()
      .previewLayout(.sizeThatFits)
  }
}
