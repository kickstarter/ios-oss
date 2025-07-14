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
}

public struct OnboardingItem: Identifiable, Equatable {
  public var id: UUID = .init()
  let title: String
  let subTitle: String
  let lottieView: LottieAnimationView = .init()
  let type: OnboardingItemType

  // TODO: Update hardcoded strings with translations [mbl-2417](https://kickstarter.atlassian.net/browse/MBL-2417)
  public static var allItems: [OnboardingItem] = {
    var items: [OnboardingItem] = []

    [
      makeOnboardingItem(
        title: "Onboarding: Welcome to Kickstarter",
        subTitle: "Onboarding: Use our app to discover and support creative projects. Browse by category, find projects near you, or explore our “Projects We Love” picks.",
        type: .welcome
      ),
      makeOnboardingItem(
        title: "Onboarding: Save projects for later",
        subTitle: "Onboarding: Found a project that’s caught your eye? Tap the heart to save it and you can come back to it later on your Saved tab.",
        type: .saveProjects
      ),
      makeOnboardingItem(
        title: "Onboarding: Stay in the know",
        subTitle: "Onboarding: Turn on notifications to keep track of your backed projects and discover more you’ll love. You can customize these anytime in your settings.",
        type: .enableNotifications
      ),
      makeOnboardingItem(
        title: "Onboarding: Personalize your experince",
        subTitle: "Onboarding: Allow tracking to help us improve your in-app experience. You can change your tracking preference anytime in your device settings.",
        type: .allowTracking
      ),
      makeOnboardingItem(
        title: "Onboarding: Join the community",
        subTitle: "Onboarding: Log in or create an account to back projects, save favorites, and follow along as creative ideas come to life.",
        type: .loginSignUp
      )
    ]
    .compactMap { $0 }
    .forEach { items.append($0) }

    return items
  }()
}

public protocol OnboardingUseCaseType {
  var uiInputs: OnboardingUseCaseUIInputs { get }
  var uiOutputs: OnboardingUseCaseUIOutputs { get }
  var outputs: OnboardingUseCaseOutputs { get }
}

public protocol OnboardingUseCaseUIInputs {
  /// Triggers the PN permissions system dialog.
  func getNotifiedTapped()

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
  var completedGetNotifiedRequest: Signal<Void, Never> { get }

  /// Emits when the user has finished interacting with the Push Notificaiton system dialog.
  var completedAllowTrackingRequest: Signal<Void, Never> { get }
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

  init() {
    self.onboardingItems = SignalProducer(value: OnboardingItem.allItems)

    self.goToLoginSignup = self.goToLoginSignupTappedSignal
      .mapConst(LoginIntent.onboarding)

    self.completedGetNotifiedRequest = self.getNotifiedSignal.signal
      .flatMap { AppEnvironment.current.pushRegistrationType.hasAuthorizedNotifications() }
      .map { _ in () }

    self.completedAllowTrackingRequest = self.allowTrackingTappedSignal.signal
      .map { _ in
        let appTrackingTransparency = AppEnvironment.current.appTrackingTransparency
        let canRequestAppTrackingTransparency = appTrackingTransparency
          .advertisingIdentifier == nil && appTrackingTransparency.shouldRequestAuthorizationStatus()

        if canRequestAppTrackingTransparency {
          appTrackingTransparency.requestAndSetAuthorizationStatus()
        }
      }

    _ = self.goToNextItemTappedSignal.signal
      .observeValues { itemType in
        if itemType.isPermissionType {
          // TODO: Emit analytic tracking events here so that we know that the user opted skipped push notifications and/or AppTrackingTransparency views
        }
      }
  }

  // MARK: - Inputs

  private let (getNotifiedSignal, getNotifiedObserver) = Signal<Void, Never>.pipe()
  public func getNotifiedTapped() {
    self.getNotifiedObserver.send(value: ())
  }

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

  public let completedGetNotifiedRequest: Signal<Void, Never>
  public let completedAllowTrackingRequest: Signal<Void, Never>
  public let goToLoginSignup: Signal<LoginIntent, Never>

  // MARK: - Data Outputs

  public let onboardingItems: SignalProducer<[OnboardingItem], Never>

  // MARK: - Type

  public var uiInputs: any OnboardingUseCaseUIInputs { return self }
  public var uiOutputs: any OnboardingUseCaseUIOutputs { return self }
  public var outputs: any OnboardingUseCaseOutputs { return self }
}

// MARK: - Helpers

private func makeOnboardingItem(
  title: String,
  subTitle: String,
  type: OnboardingItemType
) -> OnboardingItem? {
  guard let lottieName = localizedOnboardingLottieFile(for: type, in: .main) else {
    assertionFailure("Missing Lottie file for onboarding type: \(type)")
    return nil
  }

  return OnboardingItem(
    title: title,
    subTitle: subTitle,
    lottieView: .init(name: lottieName, bundle: .main),
    type: type
  )
}
