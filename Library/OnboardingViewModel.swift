import Foundation
import KsApi
import ReactiveSwift

public protocol OnboardingViewModelInputs {
  func getNotifiedTapped()
  func allowTrackingTapped()
  func goToLoginSignupTapped()
  func goToNextItemTapped(item: OnboardingItem)
  func onAppear()
}

public protocol OnboardingViewModelOutputs {
  var onboardingItems: SignalProducer<[OnboardingItem], Never> { get }
  var didCompletePushNotificationSystemDialog: Signal<Void, Never> { get }
  var triggerAppTrackingTransparencyPopup: Signal<Void, Never> { get }
  var goToLoginSignup: Signal<LoginIntent, Never> { get }
}

public typealias OnboardingViewModelType = Equatable & Identifiable & ObservableObject &
  OnboardingViewModelInputs & OnboardingViewModelOutputs

public final class OnboardingViewModel: OnboardingViewModelType {
  // MARK: - Properties

  private let useCase: OnboardingUseCaseType

  // MARK: - Outputs

  public let onboardingItems: SignalProducer<[OnboardingItem], Never>
  public let didCompletePushNotificationSystemDialog: Signal<Void, Never>
  public let triggerAppTrackingTransparencyPopup: Signal<Void, Never>
  public let goToLoginSignup: Signal<LoginIntent, Never>

  // MARK: - Init

  public init(with bundle: Bundle = .main) {
    self.useCase = OnboardingUseCase(for: bundle)

    self.onboardingItems = self.useCase.uiOutputs.onboardingItems
    self.goToLoginSignup = self.useCase.uiOutputs.goToLoginSignup
    self.didCompletePushNotificationSystemDialog = self.useCase.outputs
      .didCompletePushNotificationSystemDialog
    self.triggerAppTrackingTransparencyPopup = self.useCase.outputs.triggerAppTrackingTransparencyDialog

    // MARK: - Analytics

    _ = self.onAppearSignal.signal
      .on(value: { _ in
        AppEnvironment.current.ksrAnalytics.trackOnboardingPageViewed(at: .welcome)
      })
      .observeValues { _ in }

    _ = self.goToNextItemTappedSignal.signal
      .on(value: { item in
        AppEnvironment.current.ksrAnalytics.trackOnboardingPageViewed(at: item.type)
      })
      .observeValues { _ in }
  }

  public static func == (lhs: OnboardingViewModel, rhs: OnboardingViewModel) -> Bool {
    lhs.id == rhs.id
  }

  // MARK: - Inputs

  public func getNotifiedTapped() {
    self.useCase.uiInputs.getNotifiedTapped()
  }

  public func allowTrackingTapped() {
    self.useCase.uiInputs.allowTrackingTapped()
  }

  public func goToLoginSignupTapped() {
    self.useCase.uiInputs.goToLoginSignupTapped()
  }

  private let (goToNextItemTappedSignal, goToNextItemTappedObserver) = Signal<OnboardingItem, Never>.pipe()
  public func goToNextItemTapped(item: OnboardingItem) {
    self.goToNextItemTappedObserver.send(value: item)
  }

  private let (onAppearSignal, onAppearObserver) = Signal<Void, Never>.pipe()
  public func onAppear() {
    self.onAppearObserver.send(value: ())
  }
}
