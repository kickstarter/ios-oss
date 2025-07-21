import Library
import Lottie
import SwiftUI

private enum Constants {
  static let animationDuration: Double = 0.35
  static let rootStackViewBottomPadding: CGFloat = 80
  static let horizontalPadding: CGFloat = 20
  static let lottieViewTopPadding: CGFloat = 16
  static let rootStackViewTopPadding: CGFloat = 20
  static let titleSubtitleSpacing: CGFloat = 12
  static let verticalSpacing: CGFloat = 24
}

struct OnboardingItemView: View {
  let item: OnboardingItem
  let progress: Double
  let onPrimaryTap: () -> Void
  let onSecondaryTap: () -> Void
  let onLoginSignup: () -> Void

  var body: some View {
    VStack {
      VStack(spacing: Constants.titleSubtitleSpacing) {
        Text(self.item.title)
          .font(Font(OnboardingStyles.title))
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)

        Text(self.item.subtitle)
          .font(Font(OnboardingStyles.subtitle))
          .lineLimit(4)
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)
      }
      .padding(.horizontal, Constants.horizontalPadding)
      .fixedSize(horizontal: false, vertical: true)

      ResizableLottieView(onboardingItem: self.item, isVisible: true)
        .frame(maxWidth: .infinity)
        .padding(.top, Constants.lottieViewTopPadding)

      Spacer()

      CallToActionView(
        item: self.item,
        animationDuration: Constants.animationDuration,
        onPrimaryTap: self.onPrimaryTap,
        onSecondaryTap: self.onSecondaryTap,
        onLoginSignup: self.onLoginSignup
      )
      .padding(.horizontal, Constants.horizontalPadding)
    }
    .padding(.top, Constants.rootStackViewTopPadding)
    .padding(.bottom, Constants.rootStackViewBottomPadding)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
