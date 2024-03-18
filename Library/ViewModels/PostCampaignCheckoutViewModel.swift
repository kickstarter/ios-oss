import Foundation
import KsApi
import PassKit
import Prelude
import ReactiveSwift

public protocol PostCampaignCheckoutViewModelInputs {
  func configure(with data: PledgeViewData)
  func pledgeDisclaimerViewDidTapLearnMore()
  func viewDidLoad()
}

public protocol PostCampaignCheckoutViewModelOutputs {
  var configurePaymentMethodsViewControllerWithValue: Signal<PledgePaymentMethodsValue, Never> { get }
  var configurePledgeViewCTAContainerView: Signal<PledgeViewCTAContainerViewData, Never> { get }
  var showWebHelp: Signal<HelpType, Never> { get }
}

public protocol PostCampaignCheckoutViewModelType {
  var inputs: PostCampaignCheckoutViewModelInputs { get }
  var outputs: PostCampaignCheckoutViewModelOutputs { get }
}

public class PostCampaignCheckoutViewModel: PostCampaignCheckoutViewModelType,
  PostCampaignCheckoutViewModelInputs,
  PostCampaignCheckoutViewModelOutputs {
  public init() {
    let initialData = Signal.combineLatest(
      self.configureWithDataProperty.signal,
      self.viewDidLoadProperty.signal
    )
    .map(first)
    .skipNil()

    let context = initialData.map(\.context)

    self.configurePaymentMethodsViewControllerWithValue = initialData
      .compactMap { data -> PledgePaymentMethodsValue? in
        guard let user = AppEnvironment.current.currentUser else { return nil }
        guard let reward = data.rewards.first else { return nil }

        return (user, data.project, reward, data.context, data.refTag)
      }

    // TODO: Respond to login flow.
    let isLoggedIn = initialData.ignoreValues()
      .map { _ in AppEnvironment.current.currentUser }
      .map(isNotNil)

    self.configurePledgeViewCTAContainerView = Signal.combineLatest(
      isLoggedIn,
      context
    )
    .map { isLoggedIn, context in
      // TODO: Calculate isEnabled and willRetryPaymentMethod fields instead of defaulting to true.
      PledgeViewCTAContainerViewData(isLoggedIn, true, context, true)
    }

    self.showWebHelp = self.pledgeDisclaimerViewDidTapLearnMoreSignal.mapConst(.trust)
  }

  // MARK: - Inputs

  private let configureWithDataProperty = MutableProperty<PledgeViewData?>(nil)
  public func configure(with data: PledgeViewData) {
    self.configureWithDataProperty.value = data
  }

  private let (pledgeDisclaimerViewDidTapLearnMoreSignal, pledgeDisclaimerViewDidTapLearnMoreObserver)
    = Signal<Void, Never>.pipe()
  public func pledgeDisclaimerViewDidTapLearnMore() {
    self.pledgeDisclaimerViewDidTapLearnMoreObserver.send(value: ())
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  // MARK: - Outputs

  public let configurePaymentMethodsViewControllerWithValue: Signal<PledgePaymentMethodsValue, Never>
  public let configurePledgeViewCTAContainerView: Signal<PledgeViewCTAContainerViewData, Never>
  public let showWebHelp: Signal<HelpType, Never>

  public var inputs: PostCampaignCheckoutViewModelInputs { return self }
  public var outputs: PostCampaignCheckoutViewModelOutputs { return self }
}
