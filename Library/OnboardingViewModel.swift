import AppTrackingTransparency
import Foundation
import KsApi
import ReactiveSwift
import UserNotifications

public protocol OnboardingViewModelInputs {
  func allowTrackingTapped()
  func didCompleteAppTrackingDialog(with authStatus: ATTrackingManager.AuthorizationStatus)
  func didCompletePushNotificationsDialog(with authStatus: UNAuthorizationStatus)
  func getNotifiedTapped()
  func goToLoginSignupTapped()
  func goToNextItemTapped(item: OnboardingItem)
  func onAppear()
  func onboardingFlowEnded()
}

public protocol OnboardingViewModelOutputs {
  var onboardingItems: SignalProducer<[OnboardingItem], Never> { get }
  var didCompletePushNotificationSystemDialog: Signal<Void, Never> { get }
  var triggerAppTrackingTransparencyPopup: Signal<Void, Never> { get }
}

public protocol OnboardingViewModelType {
  var inputs: OnboardingViewModelInputs { get }
  var outputs: OnboardingViewModelOutputs { get }
}

public final class OnboardingViewModel: OnboardingViewModelType, Equatable & Identifiable & ObservableObject,
  OnboardingViewModelOutputs, OnboardingViewModelInputs {
  // MARK: - Properties

  private let useCase: OnboardingUseCaseType

  // MARK: - Outputs

  public let onboardingItems: SignalProducer<[OnboardingItem], Never>
  public let didCompletePushNotificationSystemDialog: Signal<Void, Never>
  public let triggerAppTrackingTransparencyPopup: Signal<Void, Never>

  // MARK: - Init

  public init(with bundle: Bundle = .main) {
    self.useCase = OnboardingUseCase(for: bundle)

    self.onboardingItems = self.useCase.uiOutputs.onboardingItems

    self.didCompletePushNotificationSystemDialog = self.useCase.outputs
      .didCompletePushNotificationSystemDialog

    self.triggerAppTrackingTransparencyPopup = self.useCase.outputs.triggerAppTrackingTransparencyDialog
      .map { _ in
        AppEnvironment.current.ksrAnalytics
          .trackSystemPermissionsDialogViewed(on: .onboardingAppTrackingDialog)

        return ()
      }
  }

  public static func == (lhs: OnboardingViewModel, rhs: OnboardingViewModel) -> Bool {
    lhs.id == rhs.id
  }

  public var inputs: OnboardingViewModelInputs { return self }
  public var outputs: OnboardingViewModelOutputs { return self }

  // MARK: - Inputs

  public func onAppear() {
    AppEnvironment.current.ksrAnalytics.trackOnboardingPageViewed(at: .welcome)
  }

  public func getNotifiedTapped() {
    self.useCase.uiInputs.getNotifiedTapped()

    AppEnvironment.current.ksrAnalytics.trackOnboardingPageButtonTapped(
      context: .onboardingGetNotified,
      item: .enableNotifications
    )
  }

  public func allowTrackingTapped() {
    self.useCase.uiInputs.allowTrackingTapped()

    AppEnvironment.current.ksrAnalytics.trackOnboardingPageButtonTapped(
      context: .onboardingAllowTracking,
      item: .allowTracking
    )
  }

  public func didCompletePushNotificationsDialog(with authStatus: UNAuthorizationStatus) {
    /// Send analytics event when the user has finished interacting with the PN system dialog. `authStatus` let's insights know whether they allowed or denied permissions.
    AppEnvironment.current.ksrAnalytics.trackPushNotificationPermissionsDialogInteraction(
      .onboardingNotificationsDialog,
      authStatus: authStatus
    )
  }

  public func didCompleteAppTrackingDialog(with authStatus: ATTrackingManager.AuthorizationStatus) {
    /// Send analytics event when the user has finished interacting with the AppTracking  system dialog. `authStatus` let's insights know whether they allowed or denied permissions.
    AppEnvironment.current.ksrAnalytics.trackAppTrackingTransparencyPermissionsDialogInteraction(
      .onboardingAppTrackingDialog,
      authStatus: authStatus
    )
  }

  public func goToLoginSignupTapped() {
    AppEnvironment.current.ksrAnalytics.trackOnboardingPageButtonTapped(
      context: .onboardingSignUpLogIn,
      item: .loginSignUp
    )

    AppEnvironment.current.ksrAnalytics.trackOnboardingPageButtonTapped(context: .onboardingClose)
  }

  public func onboardingFlowEnded() {
    AppEnvironment.current.ksrAnalytics.trackOnboardingPageButtonTapped(context: .onboardingClose)
  }

  public func goToNextItemTapped(item: OnboardingItem) {
    AppEnvironment.current.ksrAnalytics.trackOnboardingPageViewed(at: item.type)
    AppEnvironment.current.ksrAnalytics.trackOnboardingPageButtonTapped(
      context: .onboardingNext,
      item: item.type
    )
  }
}
