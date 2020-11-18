import Foundation
import Prelude
import ReactiveSwift

public protocol EmailVerificationViewModelInputs {}

public protocol EmailVerificationViewModelOutputs {}

public protocol EmailVerificationViewModelType {
  var inputs: EmailVerificationViewModelInputs { get }
  var outputs: EmailVerificationViewModelOutputs { get }
}

public final class EmailVerificationViewModel: EmailVerificationViewModelType,
  EmailVerificationViewModelInputs,
  EmailVerificationViewModelOutputs {
  public init() {}

  public var inputs: EmailVerificationViewModelInputs { return self }
  public var outputs: EmailVerificationViewModelOutputs { return self }
}
