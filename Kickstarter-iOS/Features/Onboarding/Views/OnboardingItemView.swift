import KDS
import Library
import Lottie
import SwiftUI

private enum Constants {
  static let animationDuration: Double = 0.35
  static let rootStackViewBottomPadding = Spacing.unit_20
  static let horizontalPadding = Spacing.unit_05
  static let lottieViewTopPadding = Spacing.unit_04
  static let rootStackViewTopPadding = Spacing.unit_01
  static let titleSubtitleSpacing = Spacing.unit_03
  static let verticalSpacing = Spacing.unit_06
}

struct OnboardingItemView: View {
  let item: OnboardingItem
  let progress: Double
  let onPrimaryTap: () -> Void
  let onSecondaryTap: () -> Void

  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: Constants.titleSubtitleSpacing) {
        Text(self.item.title)
          .font(Font(OnboardingStyles.title))
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)
          .accessibilityAddTraits(.isHeader)
          .accessibilityLabel(Text(self.accessibilityLabel(for: self.item)))

        Text(self.item.subtitle)
          .font(Font(OnboardingStyles.subtitle))
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)
          .accessibilityLabel(Text(self.accessibilityLabel(for: self.item)))
      }
      .padding(.horizontal, Constants.horizontalPadding)
      .fixedSize(horizontal: false, vertical: true)

      ResizableLottieView(onboardingItem: self.item, isVisible: true)
        .frame(maxWidth: .infinity)
        .padding(.top, Constants.lottieViewTopPadding)
    }
    .padding(.top, Constants.rootStackViewTopPadding)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .safeAreaInset(edge: .bottom, spacing: 0) {
      CallToActionView(
        item: self.item,
        animationDuration: Constants.animationDuration,
        onPrimaryTap: self.onPrimaryTap,
        onSecondaryTap: self.onSecondaryTap
      )
      .padding(.horizontal, Constants.horizontalPadding)
      .ignoresSafeArea(.all)
    }
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
