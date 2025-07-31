import Library
import SwiftUI

private enum Constants {
  static let rootStackViewSpacing: CGFloat = 12
  static let rootStackViewHorizontalPadding: CGFloat = 20
  static let ctaCornerRadius: CGFloat = 12
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
        /// Empty secondary button allows the primary button to be in the same position througout the onboarding flow.
        self.secondaryButton(title: "", action: {})
      case .enableNotifications:
        self.primaryButton(title: Strings.Get_notified(), action: self.onPrimaryTap, for: self.item)
        self.secondaryButton(title: Strings.Not_right_now(), action: self.onSecondaryTap)

      case .allowTracking:
        self.primaryButton(title: Strings.Allow_tracking(), action: self.onPrimaryTap, for: self.item)
        self.secondaryButton(title: Strings.Not_right_now(), action: self.onSecondaryTap)

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
