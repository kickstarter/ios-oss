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
    // TODO: Update hardcoded strings with translations [mbl-2417](https://kickstarter.atlassian.net/browse/MBL-2417)
    VStack(spacing: Constants.rootStackViewSpacing) {
      switch self.item.type {
      case .welcome, .saveProjects:
        self.primaryButton(title: "FPO: Next", action: self.onPrimaryTap, for: self.item)
        /// Empty secondary button allows the primary button to be in the same position througout the onboarding flow.
        self.secondaryButton(title: "", action: {})
      case .enableNotifications:
        self.primaryButton(title: "FPO: Get notified", action: self.onPrimaryTap, for: self.item)
        self.secondaryButton(title: "FPO: Not right now", action: self.onSecondaryTap)

      case .allowTracking:
        self.primaryButton(title: "FPO: Allow tracking", action: self.onPrimaryTap, for: self.item)
        self.secondaryButton(title: "FPO: Not right now", action: self.onSecondaryTap)

      case .loginSignUp:
        self.primaryButton(title: "FPO: Sign up or log in", action: self.onPrimaryTap, for: self.item)
        self.secondaryButton(title: "FPO: Explore the app", action: self.onSecondaryTap)
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

  // TODO: Update hardcoded strings with translations [mbl-2417](https://kickstarter.atlassian.net/browse/MBL-2417)
  private func accessibilityLabel(for item: OnboardingItem) -> LocalizedStringKey {
    switch item.type {
    case .welcome:
      "FPO: Welcome"
    case .saveProjects:
      "FPO: Save Projects."
    case .enableNotifications:
      "FPO: Push Notifications."
    case .allowTracking:
      "FPO: App Tracking."
    case .loginSignUp:
      "FPO: Login or Sign Up."
    }
  }

  // TODO: Update hardcoded strings with translations [mbl-2417](https://kickstarter.atlassian.net/browse/MBL-2417)
  private func accessibilityHint(for item: OnboardingItem) -> LocalizedStringKey {
    switch item.type {
    case .welcome, .saveProjects:
      "FPO: Navigate to next oboarding view."
    case .enableNotifications:
      "FPO: Enable Push Notifications."
    case .allowTracking:
      "FPO: Allow App Tracking."
    case .loginSignUp:
      "FPO: Go to the Login and Sign Up screen."
    }
  }
}
