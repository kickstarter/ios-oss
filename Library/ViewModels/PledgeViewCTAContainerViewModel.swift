import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol PledgeViewCTAContainerViewModelInputs {
  func applePayButtonTapped()
  func submitButtonTapped()
  func tapped(_ url: URL)
}

public protocol PledgeViewCTAContainerViewModelOutputs {
  var notifyDelegateApplePayButtonTapped: Signal<Void, Never> { get }
  var notifyDelegateOpenHelpType: Signal<HelpType, Never> { get }
  var notifyDelegateSubmitButtonTapped: Signal<Void, Never> { get }
}

public protocol PledgeViewCTAContainerViewModelType {
  var inputs: PledgeViewCTAContainerViewModelInputs { get }
  var outputs: PledgeViewCTAContainerViewModelOutputs { get }
}

public final class PledgeViewCTAContainerViewModel: PledgeViewCTAContainerViewModelType,
  PledgeViewCTAContainerViewModelInputs, PledgeViewCTAContainerViewModelOutputs {
  public init() {
    self.notifyDelegateSubmitButtonTapped = self.submitButtonTappedProperty.signal
    self.notifyDelegateApplePayButtonTapped = self.applePayButtonTappedProperty.signal

    self.notifyDelegateOpenHelpType = self.tappedUrlProperty.signal.skipNil().map { url -> HelpType? in
      let helpType = HelpType.allCases.filter { helpType in
        url.absoluteString == helpType.url(
          withBaseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl
        )?.absoluteString
      }
      .first

      return helpType
    }.skipNil()
  }

  private let applePayButtonTappedProperty = MutableProperty(())
  public func applePayButtonTapped() {
    self.applePayButtonTappedProperty.value = ()
  }

  fileprivate let submitButtonTappedProperty = MutableProperty(())
  public func submitButtonTapped() {
    self.submitButtonTappedProperty.value = ()
  }

  fileprivate let tappedUrlProperty = MutableProperty<(URL)?>(nil)
  public func tapped(_ url: URL) {
    self.tappedUrlProperty.value = url
  }

  public let notifyDelegateApplePayButtonTapped: Signal<Void, Never>
  public let notifyDelegateOpenHelpType: Signal<HelpType, Never>
  public let notifyDelegateSubmitButtonTapped: Signal<Void, Never>

  public var inputs: PledgeViewCTAContainerViewModelInputs { return self }
  public var outputs: PledgeViewCTAContainerViewModelOutputs { return self }
}
