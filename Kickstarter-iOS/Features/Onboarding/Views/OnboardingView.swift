import KDS
import Library
import Lottie
import SwiftUI

private enum Constants {
  static let animationDuration: Double = 0.35
  static let closeIconPadding = Spacing.unit_02
  static let ctaBottomPadding: CGFloat = 60
  static let horizontalPadding = Spacing.unit_05
  static let lottieViewTopPadding = Spacing.unit_04
  static let progressViewHeight = Spacing.unit_02
  static let rootStackViewCornerRadius = Spacing.unit_05
  static let rootStackViewTopPadding = Spacing.unit_05
  static let titleSubtitleSpacing = Spacing.unit_03
  static let verticalPadding = Spacing.unit_05
  static let verticalSpacing = Spacing.unit_06
}

public struct OnboardingView: View {
  @SwiftUI.Environment(\.dismiss) private var dismiss
  @ObservedObject var viewModel: OnboardingViewModel
  @Namespace private var animation
  @State private var currentIndex: Int = 0
  @State private var contentHeight: CGFloat = 1
  @State private var onboardingItems: [OnboardingItem] = []

  private var progress: Double {
    let onboardingItemsCount = self.onboardingItems.isEmpty ? 1 : Double(self.onboardingItems.count)
    return Double(self.currentIndex + 1) / onboardingItemsCount
  }

  public init(viewModel: OnboardingViewModel) {
    self.viewModel = viewModel
  }

  public var body: some View {
    ZStack {
      OnboardingStyles.backgroundColor.ignoresSafeArea()

      Image(OnboardingStyles.backgroundImage)
        .resizable()
        .scaledToFit()
        .ignoresSafeArea()

      VStack {
        self.ProgressBarView()
          .accessibilityElement(children: .combine)

        /// Scale down view only if its height exceeds available height
        GeometryReader { proxy in
          let availableHeight = proxy.size.height
          /// Compute how much to scale down the view to fit the available height.
          /// - min(1, …) - don't scale up beyond 100% (full view height)
          /// - max(0.86, …) - don’t let it shrink past 86% (keep tap targets accessible)
          /// - availableHeight / max(contentHeight, 1) - fit ratio
          let scale = min(1, max(0.86, availableHeight / max(self.contentHeight, 1)))

          ZStack {
            ForEach(Array(self.onboardingItems.enumerated()), id: \.element.id) { index, item in
              if index == self.currentIndex {
                OnboardingItemView(
                  item: item,
                  progress: self.progress,
                  onPrimaryTap: { self.handlePrimaryTap(for: item) },
                  onSecondaryTap: { self.handleSecondaryTap(for: item) }
                )
                .transition(.asymmetric(
                  insertion: .move(edge: .trailing).combined(with: .opacity),
                  removal: .move(edge: .leading).combined(with: .opacity)
                ))
              }
            }
          }
          /// Get the view content's height.
          .background(
            GeometryReader { geo in
              Color.clear
                .onAppear {
                  self.contentHeight = geo.size.height
                }
                .onChange(of: geo.size.height) { height in
                  withAnimation {
                    self.contentHeight = height
                  }
                }
            }
          )
          /// scale down  just enough to fit on screen and achor to  top
          .scaleEffect(
            scale,
            anchor: .top
          )
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .animation(.easeInOut(duration: Constants.animationDuration), value: self.currentIndex)
      }
      .padding(.vertical)
    }
    .onAppear {
      self.viewModel.inputs.onAppear()

      /// Bind onboarding items
      self.viewModel.outputs.onboardingItems.startWithValues { items in
        self.onboardingItems = items
      }
      /// Handle push notification system dialog completion
      self.viewModel.outputs.didCompletePushNotificationSystemDialog
        .observeForUI()
        .observeValues {
          UNUserNotificationCenter.current().getNotificationSettings { settings in
            self.viewModel.inputs.didCompletePushNotificationsDialog(with: settings.authorizationStatus)
          }

          self.goToNextItem()
        }

      /// Trigger app tracking permission popup
      self.viewModel.outputs.triggerAppTrackingTransparencyPopup.observeValues {
        self.presentAppTrackingPopup()
      }
    }
  }

  // MARK: - ViewBuilders

  private func ProgressBarView() -> some View {
    HStack {
      ProgressView(value: self.progress)
        .background(.white)
        .progressViewStyle(LinearProgressViewStyle(tint: OnboardingStyles.progressBarTintColor))
        .scaleEffect(x: 1, y: 2)
        .animation(.easeInOut(duration: Constants.animationDuration), value: self.progress)
        .frame(height: Constants.progressViewHeight)
        .clipShape(RoundedRectangle(cornerRadius: Constants.rootStackViewCornerRadius))

      Button(action: {
        withAnimation {
          self.handleClose()
        }
      }) {
        Image(OnboardingStyles.closeImage)
          .font(Font(OnboardingStyles.subtitle))
          .foregroundColor(.black)
          .padding(Constants.closeIconPadding)
          .clipShape(Circle())
          // TODO: Update hardcoded strings with translations [mbl-2417](https://kickstarter.atlassian.net/browse/MBL-2417)
          .accessibilityLabel("FPO: Close onboarding modal.")
          .accessibilityHint("FPO: Closes the onboarding view.")
          .accessibilityAddTraits(.isButton)
      }
    }
    .padding(.horizontal, Constants.horizontalPadding)
  }

  // MARK: - Helpers

  private func handlePrimaryTap(for item: OnboardingItem) {
    switch item.type {
    case .welcome, .saveProjects:
      self.goToNextItem()
    case .enableNotifications:
      self.viewModel.inputs.getNotifiedTapped()
    case .allowTracking:
      self.viewModel.inputs.allowTrackingTapped()
    case .loginSignUp:
      /// Triggers the `goToLoginFromOnboarding` notification to inform the AppDelegate to dismiss this view and launch the login/signup flow.
      NotificationCenter.default.post(name: .ksr_goToLoginFromOnboarding, object: nil)
      self.viewModel.inputs.goToLoginSignupTapped()
    }
  }

  private func handleSecondaryTap(for item: OnboardingItem) {
    switch item.type {
    case .welcome, .saveProjects, .enableNotifications, .allowTracking:
      self.goToNextItem()
    case .loginSignUp:
      self.handleClose()
    }
  }

  private func handleClose() {
    self.viewModel.inputs.onboardingFlowEnded()
    self.hasSeenOnboarding()
    self.dismiss()
  }

  private func goToNextItem() {
    guard self.currentIndex < self.onboardingItems.count - 1 else { return }

    self.currentIndex += 1

    self.viewModel.inputs.goToNextItemTapped(item: self.onboardingItems[self.currentIndex])
  }

  private func presentAppTrackingPopup() {
    Library.AppEnvironment.current.appTrackingTransparency.requestAndSetAuthorizationStatus { authStatus in
      self.viewModel.inputs.didCompleteAppTrackingDialog(with: authStatus)
      self.goToNextItem()
    }
  }

  private func hasSeenOnboarding() {
    AppEnvironment.current.userDefaults.set(true, forKey: AppKeys.hasSeenOnboarding.rawValue)
  }
}
