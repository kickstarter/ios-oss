import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol PledgeViewCTAContainerViewModelInputs {
  // func configureWith(value: PledgeCTAContainerViewData)
  func applePayButtonTapped()
  func pledgeCTAButtonTapped()
  func tapped(_ url: URL)
}

public protocol PledgeViewCTAContainerViewModelOutputs {
  var notifyDelegateApplePayButtonTapped: Signal<Void, Never> { get }
  var notifyDelegateTermsOfUseTapped: Signal<HelpType, Never> { get }
  var notifyDelegatePledgeButtonTapped: Signal<Void, Never> { get }
}

public protocol PledgeViewCTAContainerViewModelType {
  var inputs: PledgeViewCTAContainerViewModelInputs { get }
  var outputs: PledgeViewCTAContainerViewModelOutputs { get }
}

public final class PledgeViewCTAContainerViewModel: PledgeViewCTAContainerViewModelType,
  PledgeViewCTAContainerViewModelInputs, PledgeViewCTAContainerViewModelOutputs {
  public init() {

    self.notifyDelegatePledgeButtonTapped = self.pledgeCTAButtonTappedProperty.signal
    self.notifyDelegateApplePayButtonTapped = self.applePayButtonTappedProperty.signal

    self.notifyDelegateTermsOfUseTapped = self.tappedUrlProperty.signal.skipNil().map { url -> HelpType? in
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

  fileprivate let pledgeCTAButtonTappedProperty = MutableProperty(())
  public func pledgeCTAButtonTapped() {
    self.pledgeCTAButtonTappedProperty.value = ()
  }

  fileprivate let tappedUrlProperty = MutableProperty<(URL)?>(nil)
  public func tapped(_ url: URL) {
    self.tappedUrlProperty.value = url
  }

  public let notifyDelegateApplePayButtonTapped: Signal<Void, Never>
  public let notifyDelegateTermsOfUseTapped: Signal<HelpType, Never>
  public let notifyDelegatePledgeButtonTapped: Signal<Void, Never>

  public var inputs: PledgeViewCTAContainerViewModelInputs { return self }
  public var outputs: PledgeViewCTAContainerViewModelOutputs { return self }
}
