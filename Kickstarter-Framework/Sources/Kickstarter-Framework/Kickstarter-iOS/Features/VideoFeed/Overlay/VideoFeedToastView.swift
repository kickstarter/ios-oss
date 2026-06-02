import SwiftUI

/// A general-purpose toast for errors, confirmations, etc.
/// Displays a single line of text on a frosted glass background.
struct VideoFeedToastView: View {
  private enum Constants {
    static let height: CGFloat = 56
    static let horizontalPadding: CGFloat = 16
    static let cornerRadius: CGFloat = 12
    static let borderOpacity: CGFloat = 0.35
    static let background: Color = Color(red: 32 / 255, green: 32 / 255, blue: 32 / 255).opacity(0.95)
  }

  let message: String

  var body: some View {
    Text(self.message)
      .font(.subheadline)
      .foregroundStyle(.white)
      .frame(maxWidth: .infinity)
      .frame(height: Constants.height)
      .padding(.horizontal, Constants.horizontalPadding)
      .background(Constants.background)
      .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
      .overlay {
        RoundedRectangle(cornerRadius: Constants.cornerRadius)
          .strokeBorder(Color.white.opacity(Constants.borderOpacity), lineWidth: 1)
      }
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(self.message)
      /// Causes VoiceOver to announce the toast automatically when it appears, without requiring the user to navigate to it.
      .accessibilityAddTraits(.isStaticText)
      .accessibilityAddTraits(.updatesFrequently)
  }
}
