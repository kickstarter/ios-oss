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
  var title: String
  var subTitle: String
  var lottieView: LottieAnimationView = .init()
  var type: OnboardingItemType

  // TODO: Update hardcoded strings with translations [mbl-2417](https://kickstarter.atlassian.net/browse/MBL-2417)
  public static let allItems: [OnboardingItem] = [
    .init(
      title: "Welcome to Kickstarter",
      subTitle: """
      Use our app to discover and support creative projects. Browse by category, find projects near you, or explore our “Projects We Love” picks.
      """,
      lottieView: .init(name: localizedOnboardingLottieFile(for: .welcome, in: .main) ?? "", bundle: .main),
      type: .welcome
    ),
    .init(
      title: "Save projects for later",
      subTitle: """
      Found a project that’s caught your eye? Tap the heart to save it and you can come back to it later on your Saved tab..
      """,
      lottieView: .init(
        name: localizedOnboardingLottieFile(for: .saveProjects, in: .main) ?? "",
        bundle: .main
      ),
      type: .saveProjects
    ),
    .init(
      title: "Stay in the know",
      subTitle: """
      Turn on notifications to keep track of your backed projects and discover more you’ll love. You can customize these anytime in your settings.
      """,
      lottieView: .init(
        name: localizedOnboardingLottieFile(for: .enableNotifications, in: .main) ?? "",
        bundle: .main
      ),
      type: .enableNotifications
    ),
    .init(
      title: "Personalize your experince",
      subTitle: """
      Allow tracking to help us improve your 
      in-app experience. You can change your tracking preference anytime in your
      device settings.
      """,
      lottieView: .init(
        name: localizedOnboardingLottieFile(for: .appTracking, in: .main) ?? "",
        bundle: .main
      ),
      type: .allowTracking
    ),
    .init(
      title: "Join the community",
      subTitle: """
      Log in or create an account to back projects, save favorites, and follow along as creative ideas come to life.
      """,
      lottieView: .init(
        name: localizedOnboardingLottieFile(for: .loginSignup, in: .main) ?? "",
        bundle: .main
      ),
      type: .loginSignUp
    )
  ]
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
      .map { itemType in
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
