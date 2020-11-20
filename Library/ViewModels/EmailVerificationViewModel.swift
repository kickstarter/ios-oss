import Foundation
import Prelude
import ReactiveSwift

public protocol EmailVerificationViewModelInputs {
  func skipButtonTapped()
  func viewDidLoad()
}

public protocol EmailVerificationViewModelOutputs {
  var footerStackViewIsHidden: Signal<Bool, Never> { get }
  var notifyDelegateDidComplete: Signal<(), Never> { get }
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
    self.footerStackViewIsHidden = self.viewDidLoadProperty.signal
      .map(featureEmailVerificationSkipIsEnabled)
      .negate()
  }

  private let skipButtonTappedProperty = MutableProperty(())
  public func skipButtonTapped() {
    self.skipButtonTappedProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let notifyDelegateDidComplete: Signal<(), Never>
  public let footerStackViewIsHidden: Signal<Bool, Never>

  public var inputs: EmailVerificationViewModelInputs { return self }
  public var outputs: EmailVerificationViewModelOutputs { return self }
}
