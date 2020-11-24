import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol EmailVerificationViewModelInputs {
  func resendButtonTapped()
  func skipButtonTapped()
  func viewDidLoad()
}

public protocol EmailVerificationViewModelOutputs {
  var activityIndicatorIsHidden: Signal<Bool, Never> { get }
  var notifyDelegateDidComplete: Signal<(), Never> { get }
  var showErrorBannerWithMessage: Signal<String, Never> { get }
  var showSuccessBannerWithMessage: Signal<String, Never> { get }
  var skipButtonHidden: Signal<Bool, Never> { get }
}

public protocol EmailVerificationViewModelType {
  var inputs: EmailVerificationViewModelInputs { get }
  var outputs: EmailVerificationViewModelOutputs { get }
}

public final class EmailVerificationViewModel: EmailVerificationViewModelType,
  EmailVerificationViewModelInputs,
  EmailVerificationViewModelOutputs {
  public init() {
    self.notifyDelegateDidComplete = self.skipButtonTappedProperty.signal
    self.skipButtonHidden = self.viewDidLoadProperty.signal
      .map(featureEmailVerificationSkipIsEnabled)
      .negate()

    let resendEmailVerificationEvent = self.resendButtonTappedProperty.signal
      .switchMap { _ in
        AppEnvironment.current.apiService.sendVerificationEmail(input: EmptyInput())
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    let didSendVerificationEmail = resendEmailVerificationEvent.values().ignoreValues()
    let didFailToSendVerificationEmail = resendEmailVerificationEvent.errors()
      .map { $0.localizedDescription }

    self.activityIndicatorIsHidden = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(true),
      self.resendButtonTappedProperty.signal.mapConst(false),
      resendEmailVerificationEvent.filter { $0.isTerminating }.mapConst(true)
    )

    self.showErrorBannerWithMessage = didFailToSendVerificationEmail

    self.showSuccessBannerWithMessage = didSendVerificationEmail
      .mapConst(Strings.Verification_email_sent())

    // MARK: - Tracking

    self.viewDidLoadProperty.signal.observeValues { _ in
      AppEnvironment.current.koala.trackEmailVerificationScreenViewed()
    }

    self.skipButtonTappedProperty.signal.observeValues { _ in
      AppEnvironment.current.koala.trackSkipEmailVerificationButtonClicked()
    }
  }

  private let resendButtonTappedProperty = MutableProperty(())
  public func resendButtonTapped() {
    self.resendButtonTappedProperty.value = ()
  }

  private let skipButtonTappedProperty = MutableProperty(())
  public func skipButtonTapped() {
    self.skipButtonTappedProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let activityIndicatorIsHidden: Signal<Bool, Never>
  public let notifyDelegateDidComplete: Signal<(), Never>
  public let showErrorBannerWithMessage: Signal<String, Never>
  public let showSuccessBannerWithMessage: Signal<String, Never>
  public let skipButtonHidden: Signal<Bool, Never>

  public var inputs: EmailVerificationViewModelInputs { return self }
  public var outputs: EmailVerificationViewModelOutputs { return self }
}
