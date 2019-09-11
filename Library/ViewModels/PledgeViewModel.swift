import Foundation
import KsApi
import PassKit
import Prelude
import ReactiveSwift

public typealias StripeConfigurationData = (merchantIdentifier: String, publishableKey: String)
public typealias BackingData = (
  project: Project, reward: Reward, pledgeAmount: Double,
  selectedShippingRule: ShippingRule?
)
public typealias PaymentAuthorizationData = (
  project: Project, reward: Reward, pledgeAmount: Double,
  selectedShippingRule: ShippingRule?, merchantIdentifier: String
)
public typealias PKPaymentData = (displayName: String, network: String, transactionIdentifier: String)

public protocol PledgeViewModelInputs {
  func applePayButtonTapped()
  func configureWith(project: Project, reward: Reward)
  func paymentAuthorizationDidAuthorizePayment(
    paymentData: (displayName: String?, network: String?, transactionIdentifier: String))
  func paymentAuthorizationViewControllerDidFinish()
  func pledgeAmountDidUpdate(to amount: Double)
  func shippingRuleSelected(_ shippingRule: ShippingRule)
  func stripeTokenCreated(token: String?, error: Error?) -> PKPaymentAuthorizationStatus
  func userSessionStarted()
  func viewDidLoad()
}

public protocol PledgeViewModelOutputs {
  var configurePaymentMethodsViewControllerWithValue: Signal<(User, Project), Never> { get }
  var configureStripeIntegration: Signal<StripeConfigurationData, Never> { get }
  var configureSummaryViewControllerWithData: Signal<(Project, Double), Never> { get }
  var configureWithData: Signal<(project: Project, reward: Reward), Never> { get }
  var continueViewHidden: Signal<Bool, Never> { get }
  var createBackingError: Signal<String, Never> { get }
  var goToApplePayPaymentAuthorization: Signal<PaymentAuthorizationData, Never> { get }
  var goToThanks: Signal<Project, Never> { get }
  var paymentMethodsViewHidden: Signal<Bool, Never> { get }
  var shippingLocationViewHidden: Signal<Bool, Never> { get }
}

public protocol PledgeViewModelType {
  var inputs: PledgeViewModelInputs { get }
  var outputs: PledgeViewModelOutputs { get }
}

public class PledgeViewModel: PledgeViewModelType, PledgeViewModelInputs, PledgeViewModelOutputs {
  public init() {
    let projectAndReward = Signal.combineLatest(
      self.configureProjectAndRewardProperty.signal,
      self.viewDidLoadProperty.signal
    )
    .map(first)
    .skipNil()

    let project = projectAndReward.map(first)
    let reward = projectAndReward.map(second)
    let isLoggedIn = Signal.merge(projectAndReward.ignoreValues(), self.userSessionStartedSignal)
      .map { _ in AppEnvironment.current.currentUser }
      .map(isNotNil)

    let pledgeAmount = Signal.merge(
      self.pledgeAmountSignal,
      projectAndReward.map { $1.minimum }
    )

    let initialShippingAmount = projectAndReward.mapConst(0.0)
    let shippingAmount = self.shippingRuleSelectedSignal
      .map { $0.cost }
    let shippingCost = Signal.merge(shippingAmount, initialShippingAmount)

    let pledgeTotal = Signal.combineLatest(pledgeAmount, shippingCost).map(+)

    self.configureWithData = projectAndReward.map { (project: $0.0, reward: $0.1) }

    self.configureSummaryViewControllerWithData = project
      .takePairWhen(pledgeTotal)
      .map { project, total in (project, total) }

    self.configurePaymentMethodsViewControllerWithValue = Signal.merge(
      project,
      project.takeWhen(self.userSessionStartedSignal)
    )
    .map { project -> (User, Project)? in
      guard let user = AppEnvironment.current.currentUser else { return nil }

      return (user, project)
    }
    .skipNil()

    self.continueViewHidden = isLoggedIn
    self.paymentMethodsViewHidden = isLoggedIn.negate()
    self.shippingLocationViewHidden = reward
      .map { $0.shipping.enabled }
      .negate()

    self.configureStripeIntegration = projectAndReward.ignoreValues()
      .map { _ in
        (
          PKPaymentAuthorizationViewController.merchantIdentifier,
          AppEnvironment.current.environmentType.stripePublishableKey
        )
      }

    let selectedShippingRule = Signal.merge(
      projectAndReward.mapConst(nil),
      self.shippingRuleSelectedSignal.wrapInOptional()
    )

    let backingData: Signal<BackingData, Never> = Signal.combineLatest(
      projectAndReward,
      pledgeAmount,
      selectedShippingRule
    )
    .map { projectAndReward, pledgeAmount, selectedShippingRule in
      (
        projectAndReward.0,
        projectAndReward.1,
        pledgeAmount,
        selectedShippingRule
      )
    }

    // Apple Pay

    let paymentAuthorizationData = backingData
      .map { (
        $0.project,
        $0.reward,
        $0.pledgeAmount,
        $0.selectedShippingRule,
        PKPaymentAuthorizationViewController.merchantIdentifier
      ) as PaymentAuthorizationData }

    self.goToApplePayPaymentAuthorization = paymentAuthorizationData
      .takeWhen(self.applePayButtonTappedSignal)

    let pkPaymentData = self.pkPaymentSignal
      .map { pkPayment -> PKPaymentData? in
        guard let displayName = pkPayment.displayName, let network = pkPayment.network else {
          return nil
        }

        return (displayName, network, pkPayment.transactionIdentifier)
      }

    let applePayStatusSuccess = Signal.combineLatest(
      stripeTokenSignal.skipNil(),
      stripeErrorSignal.filter(isNil),
      pkPaymentData.skipNil()
      ).mapConst(PKPaymentAuthorizationStatus.success)

    let applePayStatusFailure = Signal.merge(
      stripeErrorSignal.skipNil().ignoreValues(),
      stripeTokenSignal.filter(isNil).ignoreValues(),
      pkPaymentData.filter(isNil).ignoreValues()
      ).mapConst(PKPaymentAuthorizationStatus.failure)

    self.createApplePayBackingStatusProperty <~ Signal.merge(
      applePayStatusSuccess,
      applePayStatusFailure
    )

    let createApplePayBackingData = Signal.combineLatest(backingData,
                                                         pkPaymentData.skipNil(),
                                                         stripeTokenSignal.skipNil())
      .takeWhen(applePayStatusSuccess)
      .map { backingData, paymentData, stripeToken
        -> (Project, Reward, Double, ShippingRule?, PKPaymentData, String) in
        return (
          backingData.project,
          backingData.reward,
          backingData.pledgeAmount,
          backingData.selectedShippingRule,
          paymentData,
          stripeToken
        )
      }

    let createApplePayBackingEvent = createApplePayBackingData
      .map(
        createApplePayBackingInput(for:reward:pledgeAmount:selectedShippingRule:pkPaymentData:stripeToken:)
      )
      .switchMap { input in
        AppEnvironment.current.apiService.createApplePayBacking(input: input)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    let createApplePayBackingEventSuccess = createApplePayBackingEvent.values()

    let createApplePayBackingEventErrors = createApplePayBackingEvent.errors()
      .map { $0.localizedDescription }
    let createApplePayBackingError = createApplePayBackingEventErrors
      .takeWhen(self.paymentAuthorizationDidFinishSignal)

    self.createBackingError = Signal.merge(
      createApplePayBackingError
    )

    self.goToThanks = Signal.combineLatest(project, createApplePayBackingEventSuccess)
      .takeWhen(self.paymentAuthorizationDidFinishSignal)
      .map(first)
  }

  private let (applePayButtonTappedSignal, applePayButtonTappedObserver) = Signal<Void, Never>.pipe()
  public func applePayButtonTapped() {
    self.applePayButtonTappedObserver.send(value: ())
  }

  private let configureProjectAndRewardProperty = MutableProperty<(Project, Reward)?>(nil)
  public func configureWith(project: Project, reward: Reward) {
    self.configureProjectAndRewardProperty.value = (project, reward)
  }

  private let (pkPaymentSignal, pkPaymentObserver) = Signal<
    (
      displayName: String?,
      network: String?, transactionIdentifier: String
    ), Never
  >.pipe()
  public func paymentAuthorizationDidAuthorizePayment(paymentData: (
    displayName: String?,
    network: String?, transactionIdentifier: String
  )) {
    self.pkPaymentObserver.send(value: paymentData)
  }

  private let (paymentAuthorizationDidFinishSignal, paymentAuthorizationDidFinishObserver)
    = Signal<Void, Never>.pipe()
  public func paymentAuthorizationViewControllerDidFinish() {
    self.paymentAuthorizationDidFinishObserver.send(value: ())
  }

  private let (pledgeAmountSignal, pledgeAmountObserver) = Signal<Double, Never>.pipe()
  public func pledgeAmountDidUpdate(to amount: Double) {
    self.pledgeAmountObserver.send(value: amount)
  }

  private let (shippingRuleSelectedSignal, shippingRuleSelectedObserver) = Signal<ShippingRule, Never>.pipe()
  public func shippingRuleSelected(_ shippingRule: ShippingRule) {
    self.shippingRuleSelectedObserver.send(value: shippingRule)
  }

  private let (stripeTokenSignal, stripeTokenObserver) = Signal<String?, Never>.pipe()
  private let (stripeErrorSignal, stripeErrorObserver) = Signal<Error?, Never>.pipe()

  private let createApplePayBackingStatusProperty = MutableProperty<PKPaymentAuthorizationStatus>(.failure)
  public func stripeTokenCreated(token: String?, error: Error?) -> PKPaymentAuthorizationStatus {
    self.stripeTokenObserver.send(value: token)
    self.stripeErrorObserver.send(value: error)

    return self.createApplePayBackingStatusProperty.value
  }

  private let (userSessionStartedSignal, userSessionStartedObserver) = Signal<Void, Never>.pipe()
  public func userSessionStarted() {
    self.userSessionStartedObserver.send(value: ())
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let configurePaymentMethodsViewControllerWithValue: Signal<(User, Project), Never>
  public let configureStripeIntegration: Signal<StripeConfigurationData, Never>
  public let configureSummaryViewControllerWithData: Signal<(Project, Double), Never>
  public let configureWithData: Signal<(project: Project, reward: Reward), Never>
  public let continueViewHidden: Signal<Bool, Never>
  public let createBackingError: Signal<String, Never>
  public let goToApplePayPaymentAuthorization: Signal<PaymentAuthorizationData, Never>
  public let goToThanks: Signal<Project, Never>
  public let paymentMethodsViewHidden: Signal<Bool, Never>
  public let shippingLocationViewHidden: Signal<Bool, Never>

  public var inputs: PledgeViewModelInputs { return self }
  public var outputs: PledgeViewModelOutputs { return self }
}

private func createApplePayBackingInput(
  for project: Project,
  reward: Reward,
  pledgeAmount: Double,
  selectedShippingRule: ShippingRule?,
  pkPaymentData: PKPaymentData,
  stripeToken: String
) -> CreateApplePayBackingInput {
  let pledgeAmountDecimal = Decimal(pledgeAmount)
  var shippingAmountDecimal: Decimal = Decimal()
  var shippingLocationId: String?

  if let shippingRule = selectedShippingRule, shippingRule.cost > 0 {
    shippingAmountDecimal = Decimal(shippingRule.cost)
    shippingLocationId = String(shippingRule.location.id)
  }

  let pledgeTotal = NSDecimalNumber(decimal: pledgeAmountDecimal + shippingAmountDecimal)
  let formattedPledgeTotal = Format.decimalCurrency(for: pledgeTotal.doubleValue)

  let rewardId = reward == Reward.noReward ? nil : reward.graphID

  return CreateApplePayBackingInput(
    amount: formattedPledgeTotal,
    locationId: shippingLocationId,
    paymentInstrumentName: pkPaymentData.displayName,
    paymentNetwork: pkPaymentData.network,
    projectId: project.graphID,
    rewardId: rewardId,
    stripeToken: stripeToken,
    transactionIdentifier: pkPaymentData.transactionIdentifier
  )
}
