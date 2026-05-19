import SwiftUI

/// A general-purpose toast for errors, confirmations, etc.
/// Displays a single line of text on a frosted glass background.
struct VideoFeedToastView: View {
  private enum Constants {
    static let horizontalPadding: CGFloat = 24
    static let verticalPadding: CGFloat = 16
    static let cornerRadius: CGFloat = 14
  }

  let message: String

  var body: some View {
    Text(self.message)
      .font(.subheadline)
      .foregroundStyle(.white)
      .frame(maxWidth: .infinity)
      .padding(.horizontal, Constants.horizontalPadding)
      .padding(.vertical, Constants.verticalPadding)
      .background {
        FrostedGlassBackgroundView()
          .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
      }
  }
}
