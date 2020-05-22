import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public typealias PledgeViewCTAContainerViewData = (
  isLoggedIn: Bool,
  isEnabled: Bool,
  context: PledgeViewContext,
  willRetryPaymentMethod: Bool
)

public protocol PledgeViewCTAContainerViewModelInputs {
  func applePayButtonTapped()
  func configureWith(value: PledgeViewCTAContainerViewData)
  func continueButtonTapped()
  func submitButtonTapped()
  func tapped(_ url: URL)
}

public protocol PledgeViewCTAContainerViewModelOutputs {
  var applePayButtonIsHidden: Signal<Bool, Never> { get }
  var continueButtonIsHidden: Signal<Bool, Never> { get }
  var notifyDelegateApplePayButtonTapped: Signal<Void, Never> { get }
  var notifyDelegateOpenHelpType: Signal<HelpType, Never> { get }
  var notifyDelegateSubmitButtonTapped: Signal<Void, Never> { get }
  var notifyDelegateToGoToLoginSignup: Signal<Void, Never> { get }
  var submitButtonIsEnabled: Signal<Bool, Never> { get }
  var submitButtonIsHidden: Signal<Bool, Never> { get }
  var submitButtonTitle: Signal<String, Never> { get }
}

public protocol PledgeViewCTAContainerViewModelType {
  var inputs: PledgeViewCTAContainerViewModelInputs { get }
  var outputs: PledgeViewCTAContainerViewModelOutputs { get }
}

public final class PledgeViewCTAContainerViewModel: PledgeViewCTAContainerViewModelType,
  PledgeViewCTAContainerViewModelInputs, PledgeViewCTAContainerViewModelOutputs {
  public init() {
    let context = self.configDataSignal.map { $0.context }
    let isLoggedIn = self.configDataSignal.map { $0.isLoggedIn }

    self.notifyDelegateOpenHelpType = self.tappedUrlProperty.signal.skipNil().map { url -> HelpType? in
      let helpType = HelpType.allCases.filter { helpType in
        url.absoluteString == helpType.url(
          withBaseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl
        )?.absoluteString
      }
      .first

      return helpType
    }
    .skipNil()

    self.submitButtonIsEnabled = self.configDataSignal.map { $0.isEnabled }
    self.submitButtonTitle = self.configDataSignal.map { data in
      guard data.willRetryPaymentMethod == false else { return Strings.Retry() }

      return data.context.submitButtonTitle
    }

    self.submitButtonIsHidden = isLoggedIn.map { $0 }.negate()
    self.applePayButtonIsHidden = Signal.combineLatest(context, isLoggedIn)
      .map { context, isLoggedIn in
        context.isAny(of: .pledge, .fixPaymentMethod, .changePaymentMethod) == false || isLoggedIn == false
      }
    self.continueButtonIsHidden = isLoggedIn

    self.notifyDelegateApplePayButtonTapped = self.applePayButtonTappedProperty.signal
    self.notifyDelegateSubmitButtonTapped = self.submitButtonTappedProperty.signal
    self.notifyDelegateToGoToLoginSignup = self.continueButtonTappedProperty.signal
  }

  private let applePayButtonTappedProperty = MutableProperty(())
  public func applePayButtonTapped() {
    self.applePayButtonTappedProperty.value = ()
  }

  private let (configDataSignal, configDataObserver) = Signal<PledgeViewCTAContainerViewData, Never>.pipe()
  public func configureWith(value: PledgeViewCTAContainerViewData) {
    self.configDataObserver.send(value: value)
  }

  private let continueButtonTappedProperty = MutableProperty(())
  public func continueButtonTapped() {
    self.continueButtonTappedProperty.value = ()
  }

  private let submitButtonTappedProperty = MutableProperty(())
  public func submitButtonTapped() {
    self.submitButtonTappedProperty.value = ()
  }

  private let tappedUrlProperty = MutableProperty<(URL)?>(nil)
  public func tapped(_ url: URL) {
    self.tappedUrlProperty.value = url
  }

  public let applePayButtonIsHidden: Signal<Bool, Never>
  public let continueButtonIsHidden: Signal<Bool, Never>
  public let submitButtonIsHidden: Signal<Bool, Never>
  public let notifyDelegateApplePayButtonTapped: Signal<Void, Never>
  public let notifyDelegateOpenHelpType: Signal<HelpType, Never>
  public let notifyDelegateSubmitButtonTapped: Signal<Void, Never>
  public let notifyDelegateToGoToLoginSignup: Signal<Void, Never>
  public let submitButtonIsEnabled: Signal<Bool, Never>
  public let submitButtonTitle: Signal<String, Never>

  public var inputs: PledgeViewCTAContainerViewModelInputs { return self }
  public var outputs: PledgeViewCTAContainerViewModelOutputs { return self }
}
