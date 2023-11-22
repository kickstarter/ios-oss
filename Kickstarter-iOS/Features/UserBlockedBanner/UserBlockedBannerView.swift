import Library
import SwiftUI

struct UserBlockedBannerView: View {
  private let contentPadding = 12.0
  private let imageSizeMultiplier = 1.5

  var body: some View {
    HStack {
      if let iconImage = image(named: "fix-icon", inBundle: Bundle.framework) {
        Image(uiImage: iconImage)
          .frame(width: contentPadding * imageSizeMultiplier)
          .scaledToFit()
          .foregroundColor(Color(UIColor.ksr_white))
          .padding(.horizontal, contentPadding)
      }

      Text(Strings.This_user_has_been_blocked())
        .font(Font(UIFont.ksr_subhead(size: 15)))
        .foregroundColor(Color(UIColor.ksr_white))
        .lineLimit(nil)
        .padding([.vertical, .trailing], contentPadding)
    }
    .frame(maxWidth: .infinity, alignment: .center)
    .background(Color(UIColor.ksr_alert))
  }
}
