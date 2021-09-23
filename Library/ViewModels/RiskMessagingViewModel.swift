import Foundation
import ReactiveSwift

public protocol RiskMessagingViewModelInputs {
  func configure(isApplePay: Bool)
  func confirmButtonTapped()
  func footnoteLabelTapped()
}

public protocol RiskMessagingViewModelOutputs {
  var dismissAndNotifyDelegate: Signal<Bool, Never> { get }
  var presentHelpWebViewController: Signal<Void, Never> { get }
}

public protocol RiskMessagingViewModelType {
  var inputs: RiskMessagingViewModelInputs { get }
  var outputs: RiskMessagingViewModelOutputs { get }
}

public class RiskMessagingViewModel: RiskMessagingViewModelType, RiskMessagingViewModelInputs,
  RiskMessagingViewModelOutputs {
  public init() {
    self.dismissAndNotifyDelegate = self.configureProperty.signal
      .skipNil()
      .takeWhen(self.confirmButtonTappedProperty.signal)

    self.presentHelpWebViewController = self.footnoteLabelTappedProperty.signal
  }

  private let configureProperty = MutableProperty<Bool?>(nil)
  public func configure(isApplePay: Bool) {
    self.configureProperty.value = isApplePay
  }

  private let confirmButtonTappedProperty = MutableProperty(())
  public func confirmButtonTapped() {
    self.confirmButtonTappedProperty.value = ()
  }

  private let footnoteLabelTappedProperty = MutableProperty(())
  public func footnoteLabelTapped() {
    self.footnoteLabelTappedProperty.value = ()
  }

  public let dismissAndNotifyDelegate: Signal<Bool, Never>
  public let presentHelpWebViewController: Signal<Void, Never>

  public var inputs: RiskMessagingViewModelInputs { self }
  public var outputs: RiskMessagingViewModelOutputs { self }
}
