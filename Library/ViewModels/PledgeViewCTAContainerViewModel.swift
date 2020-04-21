import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public typealias PledgeViewCTAContainerViewData = (
  isLoggedIn: Bool,
  isEnabled: Bool,
  isLoading: Bool
)

public protocol PledgeViewCTAContainerViewModelInputs {
  func configureWith(value: PledgeViewCTAContainerViewData)
  func applePayButtonTapped()
  func submitButtonTapped()
  func tapped(_ url: URL)
}

public protocol PledgeViewCTAContainerViewModelOutputs {
  var notifyDelegateApplePayButtonTapped: Signal<Void, Never> { get }
  var notifyDelegateOpenHelpType: Signal<HelpType, Never> { get }
  var notifyDelegateSubmitButtonTapped: Signal<SubmitCTAType, Never> { get }
  var notifyDelegateToGoToLoginSignup: Signal<SubmitCTAType, Never> { get }
  var applePayButtonHidden: Signal<Bool, Never> { get }
  var submitButtonIsLoading: Signal<Bool, Never> { get }
  var submitButtonIsEnabled: Signal<Bool, Never> { get }
  var submitButtonTitle: Signal<String, Never> { get }
}

public protocol PledgeViewCTAContainerViewModelType {
  var inputs: PledgeViewCTAContainerViewModelInputs { get }
  var outputs: PledgeViewCTAContainerViewModelOutputs { get }
}

public final class PledgeViewCTAContainerViewModel: PledgeViewCTAContainerViewModelType,
  PledgeViewCTAContainerViewModelInputs, PledgeViewCTAContainerViewModelOutputs {
  public init() {
    let isLoggedIn = self.configDataSignal.map { $0.isLoggedIn }
    let isEnabled = self.configDataSignal.map { $0.isEnabled }
    let submitCTAType = isLoggedIn.map(submitCTA(isLoggedIn:))

    self.applePayButtonHidden = submitCTAType.map { $0.applePayButtonHidden }
    self.submitButtonTitle = submitCTAType.map { $0.buttonTitle }

    self.submitButtonIsLoading = self.configDataSignal.map{ $0.isLoading }
    self.submitButtonIsEnabled = Signal.combineLatest(submitCTAType, isEnabled)
    .map(enableSubmitButton(submitCTAType:isEnabled:))

  self.notifyDelegateOpenHelpType = self.tappedUrlProperty.signal.skipNil().map { url -> HelpType? in
      let helpType = HelpType.allCases.filter { helpType in
        url.absoluteString == helpType.url(
          withBaseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl
        )?.absoluteString
      }
      .first

      return helpType
    }.skipNil()

    self.notifyDelegateSubmitButtonTapped = submitCTAType
      .filter { $0 == .pledge }
      .takeWhen(self.submitButtonTappedProperty.signal)

    self.notifyDelegateApplePayButtonTapped = self.applePayButtonTappedProperty.signal

    self.notifyDelegateToGoToLoginSignup = submitCTAType
      .filter { $0 == .continueCTA }
      .takeWhen(self.submitButtonTappedProperty.signal)
  }

  private let applePayButtonTappedProperty = MutableProperty(())
  public func applePayButtonTapped() {
    self.applePayButtonTappedProperty.value = ()
  }

  fileprivate let (configDataSignal, configDataObserver) = Signal<PledgeViewCTAContainerViewData, Never>.pipe()
  public func configureWith(value: PledgeViewCTAContainerViewData) {
    self.configDataObserver.send(value: value)
  }

  fileprivate let submitButtonTappedProperty = MutableProperty(())
  public func submitButtonTapped() {
    self.submitButtonTappedProperty.value = ()
  }

  fileprivate let tappedUrlProperty = MutableProperty<(URL)?>(nil)
  public func tapped(_ url: URL) {
    self.tappedUrlProperty.value = url
  }

  public let applePayButtonHidden: Signal<Bool, Never>
  public let notifyDelegateApplePayButtonTapped: Signal<Void, Never>
  public let notifyDelegateOpenHelpType: Signal<HelpType, Never>
  public let notifyDelegateSubmitButtonTapped: Signal<SubmitCTAType, Never>
  public let notifyDelegateToGoToLoginSignup: Signal<SubmitCTAType, Never>
  public let submitButtonIsEnabled: Signal<Bool, Never>
  public let submitButtonIsLoading: Signal<Bool, Never>
  public let submitButtonTitle: Signal<String, Never>

  public var inputs: PledgeViewCTAContainerViewModelInputs { return self }
  public var outputs: PledgeViewCTAContainerViewModelOutputs { return self }
}


public enum SubmitCTAType {
  case pledge
  case continueCTA

  public var applePayButtonHidden: Bool {
    switch self {
      case .pledge:
        return false
      case .continueCTA:
        return true
    }
  }

  public var buttonTitle: String {
    switch self {
    case .pledge:
      return Strings.Pledge()
    case .continueCTA:
      return Strings.Continue()
    }
  }
}

private func submitCTA(isLoggedIn: Bool) -> SubmitCTAType {
  if isLoggedIn == true {
    return SubmitCTAType.pledge
  } else {
    return SubmitCTAType.continueCTA
  }
}

private func enableSubmitButton(submitCTAType: SubmitCTAType, isEnabled: Bool) -> Bool {
  if submitCTAType == .pledge {
    return isEnabled
  } else if submitCTAType == .continueCTA {
    return true
  } else {
    return isEnabled
  }
}
