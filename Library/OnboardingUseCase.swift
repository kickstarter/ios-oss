import Foundation
import KsApi
import Lottie
import ReactiveSwift

public enum OnboardingItemType {
  case welcome, saveProjects, enableNotifications, allowTracking, loginSignUp

  /// Used to send analytics around whether the user decided to skip the push notification or apptracking permission request dialogs.
  var isPermissionType: Bool {
    switch self {
    case .allowTracking, .enableNotifications:
      return true
    default:
      return false
    }
  }

  var lottieFileName: String {
    switch self {
    case .welcome:
      "onboarding-flow-welcome"
    case .allowTracking:
      "onboarding-flow-activity-tracking"
    case .enableNotifications:
      "onboarding-flow-enable-notifications"
    case .saveProjects:
      "onboarding-flow-save-projects"
    case .loginSignUp:
      "onboarding-flow-login-signup"
    }
  }
}

public struct OnboardingItem: Identifiable, Equatable {
  public let id: UUID = .init()
  public let title: String
  public let subtitle: String
  public var lottieView: LottieAnimationView = .init()
  public let type: OnboardingItemType
}

public protocol OnboardingUseCaseType {
  var uiInputs: OnboardingUseCaseUIInputs { get }
  var uiOutputs: OnboardingUseCaseUIOutputs { get }
  var outputs: OnboardingUseCaseOutputs { get }
}

public protocol OnboardingUseCaseUIInputs {
  /// Triggers the AppTrackingTransparency system dialog.
  func allowTrackingTapped()

  /// Call when a user taps on the "Next", "Not right now", or "Explore the app" buttons.
  func goToNextItemTapped(item: OnboardingItemType)

  func goToLoginSignupTapped()
}

public protocol OnboardingUseCaseUIOutputs {
  var onboardingItems: SignalProducer<[OnboardingItem], Never> { get }

  var goToLoginSignup: Signal<LoginIntent, Never> { get }
}

public protocol OnboardingUseCaseOutputs {
  /// Emits when the user has finished interacting with the Push Notificaiton system dialog.
  var triggerAppTrackingTransparencyPopup: Signal<Void, Never> { get }
}

/**
 A use case that:
 * Outputs a list of `OnboardingItem`s.
 * Determines if user permisions have been granted or need to be presented for Push Notifications and App Tracking Transparecy.
 * Emits onboarding analytic events.
 * Initiating the login/signup flow.

 UI Inputs:
  * `getNotifiedTapped()` - Presents the push notifications permissions system dialog.
  * `allowTrackingTapped()` - Presents the AppTrackingTransparency permissions system dialog.
  * `goToNextItemTapped(item: OnboardingItemType)` -  Moves to the next onboarding flow item.

 UI Outputs:
  * `onboardingItems` - Returns a list of `OnboardingItem` used to populate the views for each section of the flow.
  * `goToLoginSignup()` - The user tapped the login button. Triggers `goToLoginSignupTapped`.

 Data Outputs:
  * `completedGetNotifiedRequest` - The user has completed interacting with the notifications permission system dialog.
  * `completedAllowTrackingRequest` - The user has completed interacting with the AppTrackingTransparency  permission system dialog.
  */
public final class OnboardingUseCase: OnboardingUseCaseType, OnboardingUseCaseUIInputs,
  OnboardingUseCaseUIOutputs, OnboardingUseCaseOutputs {
  // MARK: - Initialization

  /// Injecting a bundle so that we can test that the correct Lottie JSON files are being loaded as expected.
  init(for bundle: Bundle = .main) {
    let onboardingItems = allOnboardingItems(in: bundle)

    self.onboardingItems = SignalProducer(value: onboardingItems)

    self.goToLoginSignup = self.goToLoginSignupTappedSignal
      .mapConst(LoginIntent.onboarding)

    self.triggerAppTrackingTransparencyPopup = self.allowTrackingTappedSignal.signal
      .filter {
        let appTrackingTransparency = AppEnvironment.current.appTrackingTransparency
        return appTrackingTransparency.advertisingIdentifier == nil && appTrackingTransparency
          .shouldRequestAuthorizationStatus()
      }
      .map { _ in () }

    _ = self.goToNextItemTappedSignal.signal
      .observeValues { itemType in
        if itemType.isPermissionType {
          // TODO: Emit analytic tracking events here so that we know that the user opted skipped push notifications and/or AppTrackingTransparency views
        }
      }
  }

  // MARK: - Inputs

  private let (allowTrackingTappedSignal, allowTrackingTappedObserver) = Signal<Void, Never>.pipe()
  public func allowTrackingTapped() {
    self.allowTrackingTappedObserver.send(value: ())
  }

  private let (goToLoginSignupTappedSignal, goToLoginSignupTappedObserver) = Signal<Void, Never>.pipe()
  public func goToLoginSignupTapped() {
    self.goToLoginSignupTappedObserver.send(value: ())
  }

  private let (goToNextItemTappedSignal, goToNextItemTappedObserver) = Signal<OnboardingItemType, Never>
    .pipe()
  public func goToNextItemTapped(item: OnboardingItemType) {
    self.goToNextItemTappedObserver.send(value: item)
  }

  // MARK: - UI Outputs

  public let triggerAppTrackingTransparencyPopup: Signal<Void, Never>
  public let goToLoginSignup: Signal<LoginIntent, Never>

  // MARK: - Data Outputs

  public let onboardingItems: SignalProducer<[OnboardingItem], Never>

  // MARK: - Type

  public var uiInputs: any OnboardingUseCaseUIInputs { return self }
  public var uiOutputs: any OnboardingUseCaseUIOutputs { return self }
  public var outputs: any OnboardingUseCaseOutputs { return self }
}

// MARK: - Helpers

private func allOnboardingItems(
  in bundle: Bundle = .main
) -> [OnboardingItem] {
  // TODO: Update hardcoded strings with translations [mbl-2417](https://kickstarter.atlassian.net/browse/MBL-2417)
  return [
    makeOnboardingItem(
      title: "FPO: Welcome to Kickstarter",
      subTitle: "FPO: Use our app to discover and support creative projects. Browse by category, find projects near you, or explore our “Projects We Love” picks.",
      type: .welcome,
      in: bundle
    ),
    makeOnboardingItem(
      title: "FPO: Save projects for later",
      subTitle: "FPO: Found a project that’s caught your eye? Tap the heart to save it and you can come back to it later on your Saved tab.",
      type: .saveProjects,
      in: bundle
    ),
    makeOnboardingItem(
      title: "FPO: Stay in the know",
      subTitle: "FPO: Turn on notifications to keep track of your backed projects and discover more you’ll love. You can customize these anytime in your settings.",
      type: .enableNotifications,
      in: bundle
    ),
    makeOnboardingItem(
      title: "FPO: Personalize your experince",
      subTitle: "FPO: Allow tracking to help us improve your in-app experience. You can change your tracking preference anytime in your device settings.",
      type: .allowTracking,
      in: bundle
    ),
    makeOnboardingItem(
      title: "FPO: Join the community",
      subTitle: "FPO: Log in or create an account to back projects, save favorites, and follow along as creative ideas come to life.",
      type: .loginSignUp,
      in: bundle
    )
  ]
  .compactMap { $0 }
}

private func makeOnboardingItem(
  title: String,
  subTitle: String,
  type: OnboardingItemType,
  in bundle: Bundle = .main
) -> OnboardingItem? {
  guard let lottieName = localizedOnboardingLottieFile(for: type.lottieFileName, in: bundle) else {
    assertionFailure("Missing Lottie file for onboarding type: \(type)")
    return nil
  }

  return OnboardingItem(
    title: title,
    subtitle: subTitle,
    lottieView: .init(name: lottieName, bundle: bundle),
    type: type
  )
}
