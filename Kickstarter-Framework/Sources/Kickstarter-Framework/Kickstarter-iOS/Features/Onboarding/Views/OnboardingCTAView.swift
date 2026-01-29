import KDS
import Library
import SwiftUI

private enum Constants {
  static let rootStackViewSpacing = Spacing.unit_03
  static let rootStackViewHorizontalPadding = Spacing.unit_05
  static let ctaCornerRadius = Spacing.unit_03
}

struct CallToActionView: View {
  let item: OnboardingItem
  let animationDuration: CGFloat
  let onPrimaryTap: () -> Void
  let onSecondaryTap: () -> Void

  var body: some View {
    VStack(spacing: Constants.rootStackViewSpacing) {
      switch self.item.type {
      case .welcome, .saveProjects:
        self.primaryButton(
          title: Strings.project_checkout_navigation_next(),
          action: self.onPrimaryTap,
          for: self.item
        )
        self.noSecondaryButton()
      case .enableNotifications:
        self.primaryButton(
          title: Strings.project_checkout_navigation_next(),
          action: self.onPrimaryTap,
          for: self.item
        )
        self.noSecondaryButton()
      case .allowTracking:
        self.primaryButton(
          title: Strings.project_checkout_navigation_next(),
          action: self.onPrimaryTap,
          for: self.item
        )
        self.noSecondaryButton()
      case .loginSignUp:
        self.primaryButton(title: Strings.Sign_up_or_log_in(), action: self.onPrimaryTap, for: self.item)
        self.secondaryButton(title: Strings.Explore_the_app(), action: self.onSecondaryTap)
      }
    }
    .padding(.horizontal, Constants.rootStackViewHorizontalPadding)
    .animation(.easeInOut(duration: self.animationDuration), value: self.item.id)
    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    .id(self.item.id)
  }

  @ViewBuilder
  private func primaryButton(
    title: String,
    action: @escaping () -> Void,
    for item: OnboardingItem
  ) -> some View {
    Button(action: action) {
      Text(title)
        .font(Font(OnboardingStyles.ctaFont))
        .foregroundColor(OnboardingStyles.primaryButtonForegroundColor)
        .frame(maxWidth: .infinity)
        .padding()
        .background(OnboardingStyles.primaryButtonBackgroundColor)
        .cornerRadius(Constants.ctaCornerRadius)
        .accessibilityLabel(self.accessibilityLabel(for: item))
        .accessibilityHint(self.accessibilityHint(for: item))
    }
  }

  @ViewBuilder
  private func secondaryButton(title: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(title)
        .font(Font(OnboardingStyles.ctaFont))
        .foregroundColor(OnboardingStyles.secondaryButtonForegroundColor)
        .frame(maxWidth: .infinity)
        .padding()
    }
  }

  /// Used to maintain primary button poistioning across the onboarding flow
  @ViewBuilder
  private func noSecondaryButton() -> some View {
    Button(action: {}) {
      Text("")
        .frame(maxWidth: .infinity)
        .padding()
    }
  }

  private func accessibilityLabel(for item: OnboardingItem) -> LocalizedStringKey {
    switch item.type {
    case .welcome, .saveProjects:
      LocalizedStringKey(stringLiteral: Strings.project_checkout_navigation_next())
    case .enableNotifications:
      LocalizedStringKey(stringLiteral: Strings.Get_notified())
    case .allowTracking:
      LocalizedStringKey(stringLiteral: Strings.Allow_tracking())
    case .loginSignUp:
      LocalizedStringKey(stringLiteral: Strings.Sign_up_or_log_in())
    }
  }

  // TODO: Add accessibility translations [mbl-2418]
  private func accessibilityHint(for item: OnboardingItem) -> LocalizedStringKey {
    switch item.type {
    case .welcome, .saveProjects:
      LocalizedStringKey(stringLiteral: Strings.project_checkout_navigation_next())
    case .enableNotifications:
      LocalizedStringKey(stringLiteral: Strings.Get_notified())
    case .allowTracking:
      LocalizedStringKey(stringLiteral: Strings.Allow_tracking())
    case .loginSignUp:
      LocalizedStringKey(stringLiteral: Strings.Sign_up_or_log_in())
    }
  }
}
