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
public typealias UpdateBackingData = (
  backing: Backing,
  reward: Reward,
  pledgeAmount: Double?,
  shippingRule: ShippingRule?
)
public typealias PaymentAuthorizationData = (
  project: Project, reward: Reward, pledgeAmount: Double,
  selectedShippingRule: ShippingRule?, merchantIdentifier: String
)
public typealias PKPaymentData = (displayName: String, network: String, transactionIdentifier: String)
public typealias PledgeAmountData = (amount: Double, min: Double, max: Double, isValid: Bool)

public protocol PledgeViewModelInputs {
  func applePayButtonTapped()
  func configureWith(project: Project, reward: Reward, refTag: RefTag?, context: PledgeViewContext)
  func creditCardSelected(with paymentSourceId: String)
  func paymentAuthorizationDidAuthorizePayment(
    paymentData: (displayName: String?, network: String?, transactionIdentifier: String)
  )
  func paymentAuthorizationViewControllerDidFinish()
  func pledgeAmountViewControllerDidUpdate(with data: PledgeAmountData)
  func pledgeButtonTapped()
  func shippingRuleSelected(_ shippingRule: ShippingRule)
  func stripeTokenCreated(token: String?, error: Error?) -> PKPaymentAuthorizationStatus
  func submitButtonTapped()
  func traitCollectionDidChange()
  func userSessionStarted()
  func viewDidLoad()
}

public protocol PledgeViewModelOutputs {
  var configurePaymentMethodsViewControllerWithValue: Signal<(User, Project), Never> { get }
  var configureStripeIntegration: Signal<StripeConfigurationData, Never> { get }
  var configureSummaryViewControllerWithData: Signal<(Project, Double), Never> { get }
  var configureWithData: Signal<(project: Project, reward: Reward), Never> { get }
  var confirmationLabelAttributedText: Signal<NSAttributedString, Never> { get }
  var confirmationLabelHidden: Signal<Bool, Never> { get }
  var continueViewHidden: Signal<Bool, Never> { get }
  var createBackingError: Signal<String, Never> { get }
  var descriptionViewHidden: Signal<Bool, Never> { get }
  var goToApplePayPaymentAuthorization: Signal<PaymentAuthorizationData, Never> { get }
  var goToThanks: Signal<Project, Never> { get }
  var notifyDelegateUpdatePledgeDidSucceedWithMessage: Signal<String, Never> { get }
  var paymentMethodsViewHidden: Signal<Bool, Never> { get }
  var popViewController: Signal<(), Never> { get }
  var sectionSeparatorsHidden: Signal<Bool, Never> { get }
  var shippingLocationViewHidden: Signal<Bool, Never> { get }
  var showApplePayAlert: Signal<(String, String), Never> { get }
  var submitButtonTitle: Signal<String, Never> { get }
  var submitButtonEnabled: Signal<Bool, Never> { get }
  var title: Signal<String, Never> { get }
  var updatePledgeFailedWithError: Signal<String, Never> { get }
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

    let project = initialData.map { $0.0 }
    let reward = initialData.map { $0.1 }
    let refTag = initialData.map { $0.2 }
    let context = initialData.map { $0.3 }

    let backing = project.map { $0.personalization.backing }.skipNil()

    self.descriptionViewHidden = context.map { $0.descriptionViewHidden }
    self.sectionSeparatorsHidden = context.map { $0.sectionSeparatorsHidden }
    self.confirmationLabelHidden = context.map { $0.confirmationLabelHidden }

    let isLoggedIn = Signal.merge(initialData.ignoreValues(), self.userSessionStartedSignal)
      .map { _ in AppEnvironment.current.currentUser }
      .map(isNotNil)

    let pledgeAmount = Signal.merge(
      self.pledgeAmountDataSignal.map { $0.amount },
      reward.map { $0.minimum }
    )

    let initialShippingAmount = initialData.mapConst(0.0)
    let shippingAmount = self.shippingRuleSelectedSignal.map { $0.cost }
    let shippingCost = Signal.merge(shippingAmount, initialShippingAmount)

    let pledgeTotal = Signal.combineLatest(pledgeAmount, shippingCost).map(+)

    self.configureWithData = initialData.map { (project: $0.0, reward: $0.1) }

    self.configureSummaryViewControllerWithData = project
      .takePairWhen(pledgeTotal)
      .map { project, total in (project, total) }

    let configurePaymentMethodsViewController = Signal.merge(
      project,
      project.takeWhen(self.userSessionStartedSignal)
    )

    self.configurePaymentMethodsViewControllerWithValue = Signal.combineLatest(
      configurePaymentMethodsViewController,
      context
    )
    .filter { !$1.paymentMethodsViewHidden }
    .map(first)
    .map { project -> (User, Project)? in
      guard let user = AppEnvironment.current.currentUser else { return nil }

      return (user, project)
    }
    .skipNil()

    self.continueViewHidden = Signal
      .combineLatest(isLoggedIn, context)
      .map { $0 || $1.continueViewHidden }

    self.paymentMethodsViewHidden = Signal.combineLatest(isLoggedIn, context)
      .map { !$0 || $1.paymentMethodsViewHidden }

    let pledgeAmountIsValid = self.pledgeAmountDataSignal
      .map { $0.isValid }

    self.shippingLocationViewHidden = reward
      .map { $0.shipping.enabled }
      .negate()

    self.configureStripeIntegration = Signal.combineLatest(
      initialData,
      context
    )
    .filter { !$1.paymentMethodsViewHidden }
    .ignoreValues()
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

    let createBackingData = Signal.combineLatest(
      project,
      reward,
      pledgeAmount,
      selectedShippingRule,
      refTag
    )
    .map { $0 as CreateBackingData }

    // MARK: Create Backing

    let createBackingEvent = Signal.combineLatest(createBackingData, self.creditCardSelectedSignal)
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

    let paymentAuthorizationData = createBackingData.map {
      (
        $0.project,
        $0.reward,
        $0.pledgeAmount,
        $0.selectedShippingRule,
        PKPaymentAuthorizationViewController.merchantIdentifier
      ) as PaymentAuthorizationData
    }

    let goToApplePayPaymentAuthorization = pledgeAmountIsValid
      .takeWhen(self.applePayButtonTappedSignal)
      .filter(isTrue)

    let showApplePayAlert = pledgeAmountIsValid
      .takeWhen(self.applePayButtonTappedSignal)
      .filter(isFalse)

    self.goToApplePayPaymentAuthorization = paymentAuthorizationData
      .takeWhen(goToApplePayPaymentAuthorization)

    self.showApplePayAlert = Signal.combineLatest(
      project,
      self.pledgeAmountDataSignal
    )
    .takeWhen(showApplePayAlert)
    .map { project, pledgeAmountData in (project, pledgeAmountData.min, pledgeAmountData.max) }
    .map { project, min, max in
      (
        localizedString(key: "Almost_there", defaultValue: "Almost there!"),
        localizedString(
          key: "Please_enter_a_pledge_amount_between_min_and_max",
          defaultValue: "Please enter a pledge amount between %{min} and %{max}.",
          count: nil,
          substitutions: [
            "min": "\(Format.currency(min, country: project.country, omitCurrencyCode: false))",
            "max": "\(Format.currency(max, country: project.country, omitCurrencyCode: false))"
          ]
        )
      )
    }

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
    )
    .mapConst(PKPaymentAuthorizationStatus.success)

    let applePayStatusFailure = Signal.merge(
      self.stripeErrorSignal.skipNil().ignoreValues(),
      self.stripeTokenSignal.filter(isNil).ignoreValues(),
      pkPaymentData.filter(isNil).ignoreValues()
    )
    .mapConst(PKPaymentAuthorizationStatus.failure)

    self.createApplePayBackingStatusProperty <~ Signal.merge(
      applePayStatusSuccess,
      applePayStatusFailure
    )

    // MARK: - Apple Pay

    let createApplePayBackingData = Signal.combineLatest(
      createBackingData,
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

    let createApplePayBackingEvent = createApplePayBackingData.map(
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

    self.confirmationLabelAttributedText = Signal.merge(
      project,
      project.takeWhen(self.traitCollectionDidChangeSignal)
    )
    .map(attributedConfirmationString(with:))
    .skipNil()

    let createBackingTransactionSuccess = project.takeWhen(createBackingEventSuccess)

    self.goToThanks = Signal.merge(applePayTransactionCompleted, createBackingTransactionSuccess)

    self.submitButtonTitle = context.map { $0.submitButtonTitle }
    self.title = context.map { $0.title }

    // MARK: Update Backing

    let updateBackingData = Signal.combineLatest(
      backing,
      reward,
      pledgeAmount.wrapInOptional(),
      selectedShippingRule
    )
    .map { $0 as UpdateBackingData }

    let updateBackingEvent = updateBackingData
      .takeWhen(self.submitButtonTappedSignal)
      .map(UpdateBackingInput.input(from:))
      .switchMap { input in
        AppEnvironment.current.apiService.updateBacking(input: input)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    self.notifyDelegateUpdatePledgeDidSucceedWithMessage = updateBackingEvent.values()
      .mapConst(Strings.Got_it_your_changes_have_been_saved())
    self.updatePledgeFailedWithError = updateBackingEvent.errors()
      .map { $0.localizedDescription }

    self.popViewController = self.notifyDelegateUpdatePledgeDidSucceedWithMessage.ignoreValues()

    // MARK: - Form Validation

    let amountChangedAndValid = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(false),
      Signal.combineLatest(
        project,
        self.pledgeAmountDataSignal,
        context
      )
      .map(amountValid)
    )

    let newPledgeNoShipping = Signal.combineLatest(
      reward.map { $0.shipping.enabled },
      context.map { $0.isCreating }
    )
    .filter(first >>> isFalse)
    .map { !$0 && $1 }

    let shippingRuleChangedAndValid = Signal.merge(
      newPledgeNoShipping,
      Signal.combineLatest(
        project,
        reward,
        self.shippingRuleSelectedSignal,
        context
      )
      .map(shippingRuleValid)
    )

    let paymentMethodChanged = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(false),
      Signal.combineLatest(
        project,
        self.creditCardSelectedSignal,
        context
      )
      .map(paymentMethodValid)
    )

    let valuesChangedAndValid = Signal.combineLatest(
      amountChangedAndValid.logEvents(),
      shippingRuleChangedAndValid.logEvents(),
      paymentMethodChanged.logEvents(),
      context
    )
    .map(allValuesChangedAndValid)

    self.submitButtonEnabled = Signal.merge(
      valuesChangedAndValid,
      self.submitButtonTappedSignal.signal.mapConst(false),
      updateBackingEvent.filter { $0.isTerminating }.mapConst(true)
    )
  }

  // MARK: - Inputs

  private let (applePayButtonTappedSignal, applePayButtonTappedObserver) = Signal<Void, Never>.pipe()
  public func applePayButtonTapped() {
    self.applePayButtonTappedObserver.send(value: ())
  }

  private let configureWithDataProperty = MutableProperty<(Project, Reward, RefTag?, PledgeViewContext)?>(nil)
  public func configureWith(project: Project, reward: Reward, refTag: RefTag?, context: PledgeViewContext) {
    self.configureWithDataProperty.value = (project, reward, refTag, context)
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

  private let (pledgeAmountDataSignal, pledgeAmountObserver) = Signal<PledgeAmountData, Never>.pipe()
  public func pledgeAmountViewControllerDidUpdate(with data: PledgeAmountData) {
    self.pledgeAmountObserver.send(value: data)
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

  private let (submitButtonTappedSignal, submitButtonTappedObserver) = Signal<(), Never>.pipe()
  public func submitButtonTapped() {
    self.submitButtonTappedObserver.send(value: ())
  }

  private let createApplePayBackingStatusProperty = MutableProperty<PKPaymentAuthorizationStatus>(.failure)
  public func stripeTokenCreated(token: String?, error: Error?) -> PKPaymentAuthorizationStatus {
    self.stripeTokenObserver.send(value: token)
    self.stripeErrorObserver.send(value: error)

    return self.createApplePayBackingStatusProperty.value
  }

  private let (traitCollectionDidChangeSignal, traitCollectionDidChangeObserver) = Signal<(), Never>.pipe()
  public func traitCollectionDidChange() {
    self.traitCollectionDidChangeObserver.send(value: ())
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
  public let confirmationLabelAttributedText: Signal<NSAttributedString, Never>
  public let confirmationLabelHidden: Signal<Bool, Never>
  public let continueViewHidden: Signal<Bool, Never>
  public let descriptionViewHidden: Signal<Bool, Never>
  public let createBackingError: Signal<String, Never>
  public let goToApplePayPaymentAuthorization: Signal<PaymentAuthorizationData, Never>
  public let goToThanks: Signal<Project, Never>
  public let notifyDelegateUpdatePledgeDidSucceedWithMessage: Signal<String, Never>
  public let paymentMethodsViewHidden: Signal<Bool, Never>
  public let popViewController: Signal<(), Never>
  public let sectionSeparatorsHidden: Signal<Bool, Never>
  public let shippingLocationViewHidden: Signal<Bool, Never>
  public let showApplePayAlert: Signal<(String, String), Never>
  public let submitButtonTitle: Signal<String, Never>
  public let submitButtonEnabled: Signal<Bool, Never>
  public let title: Signal<String, Never>
  public let updatePledgeFailedWithError: Signal<String, Never>

  public var inputs: PledgeViewModelInputs { return self }
  public var outputs: PledgeViewModelOutputs { return self }
}

private func attributedConfirmationString(with project: Project) -> NSAttributedString? {
  let string = Strings.If_the_project_reaches_its_funding_goal_you_will_be_charged_on_project_deadline(
    project_deadline: Format.date(
      secondsInUTC: project.dates.deadline,
      template: "MMMM d, yyyy"
    )
  )

  guard let attributedString = try? NSMutableAttributedString(
    data: Data(string.utf8),
    options: [
      .documentType: NSAttributedString.DocumentType.html,
      .characterEncoding: String.Encoding.utf8.rawValue
    ],
    documentAttributes: nil
  ) else { return nil }

  let paragraphStyle = NSMutableParagraphStyle()
  paragraphStyle.alignment = .center

  let attributes: String.Attributes = [
    .paragraphStyle: paragraphStyle
  ]

  let fullRange = (attributedString.string as NSString).range(of: attributedString.string)

  attributedString.addAttributes(attributes, range: fullRange)

  attributedString.setFontKeepingTraits(
    to: UIFont.ksr_caption1(),
    color: UIColor.ksr_text_dark_grey_500
  )

  return attributedString
}

// MARK: - Validation Functions

private func amountValid(
  project: Project,
  pledgeAmountData: PledgeAmountData,
  context: PledgeViewContext
) -> Bool {
  guard let backing = project.personalization.backing, context.isUpdating else {
    return pledgeAmountData.isValid
  }

  return backing.pledgeAmount != pledgeAmountData.amount && pledgeAmountData.isValid
}

private func shippingRuleValid(
  project: Project,
  reward: Reward,
  shippingRule: ShippingRule?,
  context: PledgeViewContext
) -> Bool {
  guard reward.shipping.enabled else { return context.isCreating }

  guard let backing = project.personalization.backing, context.isUpdating, shippingRule != nil else {
    return false
  }

  return backing.locationId != shippingRule?.location.id
}

private func paymentMethodValid(
  project: Project,
  paymentSourceId: String,
  context: PledgeViewContext
) -> Bool {
  guard let backing = project.personalization.backing, context.isUpdating else {
    return true
  }

  return backing.paymentSource?.id != paymentSourceId
}

private func allValuesChangedAndValid(
  amountValid: Bool,
  shippingRuleValid: Bool,
  paymentSourceValid: Bool,
  context: PledgeViewContext
) -> Bool {
  if context.isUpdating {
    return amountValid || shippingRuleValid || paymentSourceValid
  }

  return amountValid && shippingRuleValid && paymentSourceValid
}
