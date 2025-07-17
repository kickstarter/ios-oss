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
  let onLoginSignup: () -> Void

  var body: some View {
    // TODO: Update hardcoded strings with translations [mbl-2417](https://kickstarter.atlassian.net/browse/MBL-2417)
    VStack(spacing: Constants.rootStackViewSpacing) {
      switch self.item.type {
      case .welcome, .saveProjects:
        self.primaryButton(title: "Onboarding: Next", action: self.onPrimaryTap)
        /// Empty secondary button allows the primary button to be in the same position througout the onboarding flow.
        self.secondaryButton(title: "", action: {})
      case .enableNotifications:
        self.primaryButton(title: "Onboarding: Get notified", action: self.onPrimaryTap)
        self.secondaryButton(title: "Onboarding: Not right now", action: self.onSecondaryTap)

      case .allowTracking:
        self.primaryButton(title: "Onboarding: Allow tracking", action: self.onPrimaryTap)
        self.secondaryButton(title: "Onboarding: Not right now", action: self.onSecondaryTap)

      case .loginSignUp:
        self.primaryButton(title: "Onboarding: Sign up or log in", action: self.onLoginSignup)
        self.secondaryButton(title: "Onboarding: Explore the app", action: self.onSecondaryTap)
      }
    }
    .padding(.horizontal, Constants.rootStackViewHorizontalPadding)
    .animation(.easeInOut(duration: self.animationDuration), value: self.item.id)
    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    .id(self.item.id)
  }

  @ViewBuilder
  private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(title)
        .font(Font(OnboardingStyles.ctaFont))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(.black)
        .cornerRadius(Constants.ctaCornerRadius)
    }
  }

  @ViewBuilder
  private func secondaryButton(title: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(title)
        .font(Font(OnboardingStyles.ctaFont))
        .foregroundColor(.black)
        .frame(maxWidth: .infinity)
        .padding()
    }
  }
}
