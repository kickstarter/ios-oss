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

  var body: some View {
    VStack {
      VStack(spacing: Constants.titleSubtitleSpacing) {
        Text(self.item.title)
          .font(Font(OnboardingStyles.title))
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)
          .accessibilityAddTraits(.isHeader)
          .accessibilityLabel(Text(self.accessibilityLabel(for: self.item)))

        Text(self.item.subtitle)
          .font(Font(OnboardingStyles.subtitle))
          .lineLimit(4)
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)
          .accessibilityLabel(Text(self.accessibilityLabel(for: self.item)))
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
        onSecondaryTap: self.onSecondaryTap
      )
      .padding(.horizontal, Constants.horizontalPadding)
    }
    .padding(.top, Constants.rootStackViewTopPadding)
    .padding(.bottom, Constants.rootStackViewBottomPadding)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .accessibilityElement(children: .contain)
  }

  // TODO: Add accessibility translations [mbl-2418]
  private func accessibilityLabel(for item: OnboardingItem)
    -> LocalizedStringKey {
    switch item.type {
    case .welcome, .saveProjects:
      LocalizedStringKey(
        stringLiteral: Strings
          .project_checkout_navigation_next()
      )
    case .enableNotifications:
      LocalizedStringKey(stringLiteral: Strings.Get_notified())
    case .allowTracking:
      LocalizedStringKey(stringLiteral: Strings.Allow_tracking())
    case .loginSignUp:
      LocalizedStringKey(stringLiteral: Strings.Sign_up_or_log_in())
    }
  }
}
