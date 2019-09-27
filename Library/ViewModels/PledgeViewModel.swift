import Foundation
import KsApi
import PassKit
import Prelude
import ReactiveSwift

public typealias StripeConfigurationData = (merchantIdentifier: String, publishableKey: String)
public typealias CreateBackingData = (
  project: Project, reward: Reward, pledgeAmount: Double,
  selectedShippingRule: ShippingRule?, refTag: RefTag?
)
public typealias PaymentAuthorizationData = (
  project: Project, reward: Reward, pledgeAmount: Double,
  selectedShippingRule: ShippingRule?, merchantIdentifier: String
)
public typealias PKPaymentData = (displayName: String, network: String, transactionIdentifier: String)

public protocol PledgeViewModelInputs {
  func applePayButtonTapped()
  func configureWith(project: Project, reward: Reward, refTag: RefTag?)
  func creditCardSelected(with paymentSourceId: String)
  func paymentAuthorizationDidAuthorizePayment(
    paymentData: (displayName: String?, network: String?, transactionIdentifier: String)
  )
  func paymentAuthorizationViewControllerDidFinish()
  func pledgeAmountDidUpdate(to amount: Double)
  func pledgeButtonTapped()
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
  var updatePledgeButtonEnabled: Signal<Bool, Never> { get }
}

public protocol PledgeViewModelType {
  var inputs: PledgeViewModelInputs { get }
  var outputs: PledgeViewModelOutputs { get }
}

public class PledgeViewModel: PledgeViewModelType, PledgeViewModelInputs, PledgeViewModelOutputs {
  public init() {
    let initialData = Signal.combineLatest(
      self.configureWithDataProperty.signal,
      self.viewDidLoadProperty.signal
    )
    .map(first)
    .skipNil()

    let project = initialData.map(first)
    let reward = initialData.map(second)
    let refTag = initialData.map(third)
    let isLoggedIn = Signal.merge(initialData.ignoreValues(), self.userSessionStartedSignal)
      .map { _ in AppEnvironment.current.currentUser }
      .map(isNotNil)

    let pledgeAmount = Signal.merge(
      self.pledgeAmountSignal,
      reward.map { $0.minimum }
    )

    let initialShippingAmount = initialData.mapConst(0.0)
    let shippingAmount = self.shippingRuleSelectedSignal
      .map { $0.cost }
    let shippingCost = Signal.merge(shippingAmount, initialShippingAmount)

    let pledgeTotal = Signal.combineLatest(pledgeAmount, shippingCost).map(+)

    self.configureWithData = initialData.map { (project: $0.0, reward: $0.1) }

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

    let paymentSourceSelected = Signal.combineLatest(
      self.configurePaymentMethodsViewControllerWithValue, self.creditCardSelectedSignal
    )

    self.updatePledgeButtonEnabled = paymentSourceSelected.mapConst(true)

    self.shippingLocationViewHidden = reward
      .map { $0.shipping.enabled }
      .negate()

    self.configureStripeIntegration = initialData.ignoreValues()
      .map { _ in
        (
          PKPaymentAuthorizationViewController.merchantIdentifier,
          AppEnvironment.current.environmentType.stripePublishableKey
        )
      }

    let selectedShippingRule = Signal.merge(
      initialData.mapConst(nil),
      self.shippingRuleSelectedSignal.wrapInOptional()
    )

    let backingData = Signal.combineLatest(
      project,
      reward,
      pledgeAmount,
      selectedShippingRule,
      refTag
    ).map { $0 as CreateBackingData }

    // MARK: Create Backing

    let createBackingEvent = Signal.combineLatest(backingData, self.creditCardSelectedSignal)
      .takeWhen(self.pledgeButtonTappedSignal)
      .map { backingData, paymentSourceId in
        (
          backingData.project,
          backingData.reward,
          backingData.pledgeAmount,
          backingData.selectedShippingRule,
          backingData.refTag,
          paymentSourceId
        )
      }
      .map(CreateBackingInput.input(from:reward:pledgeAmount:selectedShippingRule:refTag:paymentSourceId:))
      .switchMap { input in
        AppEnvironment.current.apiService.createBacking(input: input)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    let createBackingEventSuccess = createBackingEvent.values()
    let createBackingEventError = createBackingEvent.errors()
      .map { $0.localizedDescription }

    // MARK: Apple Pay

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
      self.stripeTokenSignal.skipNil(),
      self.stripeErrorSignal.filter(isNil),
      pkPaymentData.skipNil()
    ).mapConst(PKPaymentAuthorizationStatus.success)

    let applePayStatusFailure = Signal.merge(
      self.stripeErrorSignal.skipNil().ignoreValues(),
      self.stripeTokenSignal.filter(isNil).ignoreValues(),
      pkPaymentData.filter(isNil).ignoreValues()
    ).mapConst(PKPaymentAuthorizationStatus.failure)

    self.createApplePayBackingStatusProperty <~ Signal.merge(
      applePayStatusSuccess,
      applePayStatusFailure
    )

    let createApplePayBackingData = Signal.combineLatest(
      backingData,
      pkPaymentData.skipNil(),
      self.stripeTokenSignal.skipNil()
    )
    .takeWhen(applePayStatusSuccess)
    .map { backingData, paymentData, stripeToken
      -> (Project, Reward, Double, ShippingRule?, PKPaymentData, String, RefTag?) in
      (
        backingData.project,
        backingData.reward,
        backingData.pledgeAmount,
        backingData.selectedShippingRule,
        paymentData,
        stripeToken,
        backingData.refTag
      )
    }

    let createApplePayBackingEvent = createApplePayBackingData
      .map(
        CreateApplePayBackingInput.input(
          from:reward:pledgeAmount:selectedShippingRule:pkPaymentData:stripeToken:refTag:
        )
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
      createApplePayBackingError,
      createBackingEventError
    )

    let applePayTransactionCompleted = Signal.combineLatest(project, createApplePayBackingEventSuccess)
      .takeWhen(self.paymentAuthorizationDidFinishSignal)
      .map(first)

    let createBackingTransactionSuccess = project.takeWhen(createBackingEventSuccess)

    self.goToThanks = Signal.merge(applePayTransactionCompleted, createBackingTransactionSuccess)
  }

  // MARK: - Inputs

  private let (applePayButtonTappedSignal, applePayButtonTappedObserver) = Signal<Void, Never>.pipe()
  public func applePayButtonTapped() {
    self.applePayButtonTappedObserver.send(value: ())
  }

  private let configureWithDataProperty = MutableProperty<(Project, Reward, RefTag?)?>(nil)
  public func configureWith(project: Project, reward: Reward, refTag: RefTag?) {
    self.configureWithDataProperty.value = (project, reward, refTag)
  }

  private let (creditCardSelectedSignal, creditCardSelectedObserver) = Signal<String, Never>.pipe()
  public func creditCardSelected(with paymentSourceId: String) {
    self.creditCardSelectedObserver.send(value: paymentSourceId)
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

  private let (pledgeButtonTappedSignal, pledgeButtonTappedObserver) = Signal<Void, Never>.pipe()
  public func pledgeButtonTapped() {
    self.pledgeButtonTappedObserver.send(value: ())
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

  // MARK: - Outputs

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
  public let updatePledgeButtonEnabled: Signal<Bool, Never>

  public var inputs: PledgeViewModelInputs { return self }
  public var outputs: PledgeViewModelOutputs { return self }
}
