import Foundation
import KsApi
import ReactiveSwift

public protocol PledgeContinueViewModelOutputs {
  var goToLoginSignup: Signal<(LoginIntent, Project, Reward), Never> { get }
}

public protocol PledgeContinueViewModelInputs {
  func configure(with value: (Project, Reward))
  func continueButtonTapped()
}

public protocol PledgeContinueViewModelType {
  var inputs: PledgeContinueViewModelInputs { get }
  var outputs: PledgeContinueViewModelOutputs { get }
}

public final class PledgeContinueViewModel: PledgeContinueViewModelType,
  PledgeContinueViewModelInputs, PledgeContinueViewModelOutputs {
  public init() {
    self.goToLoginSignup = self.projectAndRewardProperty.signal.skipNil()
      .takeWhen(self.continueButtonTappedProperty.signal)
      .map { (LoginIntent.backProject, $0.0, $0.1) }
  }

  private let projectAndRewardProperty = MutableProperty<(Project, Reward)?>(nil)
  public func configure(with value: (Project, Reward)) {
    self.projectAndRewardProperty.value = value
  }

  private let continueButtonTappedProperty = MutableProperty(())
  public func continueButtonTapped() {
    self.continueButtonTappedProperty.value = ()
  }

  public let goToLoginSignup: Signal<(LoginIntent, Project, Reward), Never>

  public var inputs: PledgeContinueViewModelInputs { return self }
  public var outputs: PledgeContinueViewModelOutputs { return self }
}
