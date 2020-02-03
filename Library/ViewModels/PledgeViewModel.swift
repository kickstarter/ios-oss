import Foundation
import KsApi
import PassKit
import Prelude
import ReactiveSwift

public typealias StripeConfigurationData = (merchantIdentifier: String, publishableKey: String)
public typealias CreateBackingData = (
  project: Project,
  reward: Reward,
  pledgeAmount: Double,
  shippingRule: ShippingRule?,
  paymentSourceId: String?,
  applePayParams: ApplePayParams?,
  refTag: RefTag?
)
public typealias UpdateBackingData = (
  backing: Backing,
  reward: Reward,
  pledgeAmount: Double,
  shippingRule: ShippingRule?,
  paymentSourceId: String?,
  applePayParams: ApplePayParams?
)
public typealias PaymentAuthorizationData = (
  project: Project, reward: Reward, pledgeAmount: Double,
  selectedShippingRule: ShippingRule?, merchantIdentifier: String
)
public typealias PKPaymentData = (displayName: String, network: String, transactionIdentifier: String)

public protocol PledgeViewModelInputs {
  func applePayButtonTapped()
  func configureWith(project: Project, reward: Reward, refTag: RefTag?, context: PledgeViewContext)
  func creditCardSelected(with paymentSourceId: String)
  func paymentAuthorizationDidAuthorizePayment(
    paymentData: (displayName: String?, network: String?, transactionIdentifier: String)
  )
  func paymentAuthorizationViewControllerDidFinish()
  func pledgeAmountViewControllerDidUpdate(with data: PledgeAmountData)
  func scaFlowCompleted(with result: StripePaymentHandlerActionStatusType, error: Error?)
  func shippingRuleSelected(_ shippingRule: ShippingRule)
  func stripeTokenCreated(token: String?, error: Error?) -> PKPaymentAuthorizationStatus
  func submitButtonTapped()
  func userSessionStarted()
  func viewDidLoad()
}

public protocol PledgeViewModelOutputs {
  var beginSCAFlowWithClientSecret: Signal<String, Never> { get }
  var configurePaymentMethodsViewControllerWithValue: Signal<PledgePaymentMethodsValue, Never> { get }
  var configureStripeIntegration: Signal<StripeConfigurationData, Never> { get }
  var configureSummaryViewControllerWithData: Signal<(Project, Double), Never> { get }
  var configureWithData: Signal<(project: Project, reward: Reward), Never> { get }
  var confirmationLabelAttributedText: Signal<NSAttributedString, Never> { get }
  var confirmationLabelHidden: Signal<Bool, Never> { get }
  var continueViewHidden: Signal<Bool, Never> { get }
  var descriptionViewHidden: Signal<Bool, Never> { get }
  var goToApplePayPaymentAuthorization: Signal<PaymentAuthorizationData, Never> { get }
  var goToThanks: Signal<ThanksPageData, Never> { get }
  var notifyDelegateUpdatePledgeDidSucceedWithMessage: Signal<String, Never> { get }
  var notifyPledgeAmountViewControllerShippingAmountChanged: Signal<Double, Never> { get }
  var paymentMethodsViewHidden: Signal<Bool, Never> { get }
  var pledgeAmountViewHidden: Signal<Bool, Never> { get }
  var pledgeAmountSummaryViewHidden: Signal<Bool, Never> { get }
  var popToRootViewController: Signal<(), Never> { get }
  var sectionSeparatorsHidden: Signal<Bool, Never> { get }
  var shippingLocationViewHidden: Signal<Bool, Never> { get }
  var showApplePayAlert: Signal<(String, String), Never> { get }
  var showErrorBannerWithMessage: Signal<String, Never> { get }
  var submitButtonEnabled: Signal<Bool, Never> { get }
  var submitButtonHidden: Signal<Bool, Never> { get }
  var submitButtonIsLoading: Signal<Bool, Never> { get }
  var submitButtonTitle: Signal<String, Never> { get }
  var title: Signal<String, Never> { get }
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

    self.confirmationLabelHidden = context.map { $0.confirmationLabelHidden }
    self.descriptionViewHidden = context.map { $0.descriptionViewHidden }
    self.pledgeAmountViewHidden = context.map { $0.pledgeAmountViewHidden }
    self.pledgeAmountSummaryViewHidden = context.map { $0.pledgeAmountSummaryViewHidden }
    self.sectionSeparatorsHidden = context.map { $0.sectionSeparatorsHidden }

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

    self.notifyPledgeAmountViewControllerShippingAmountChanged = shippingCost

    let projectAndReward = initialData.map { (project: $0.0, reward: $0.1) }

    self.configureWithData = projectAndReward

    self.configureSummaryViewControllerWithData = project
      .takePairWhen(pledgeTotal)
      .map { project, total in (project, total) }

    let configurePaymentMethodsViewController = Signal.merge(
      initialData,
      initialData.takeWhen(self.userSessionStartedSignal)
    )

    self.configurePaymentMethodsViewControllerWithValue = configurePaymentMethodsViewController
      .filter { !$3.paymentMethodsViewHidden }
      .filterMap { project, reward, refTag, context -> PledgePaymentMethodsValue? in
        guard let user = AppEnvironment.current.currentUser else { return nil }

        return (user, project, reward, context, refTag)
      }

    let projectAndPledgeTotal = project
      .combineLatest(with: pledgeTotal)

    self.confirmationLabelAttributedText = projectAndPledgeTotal
      .map { project, pledgeTotal in
        attributedConfirmationString(
          with: project,
          pledgeTotal: pledgeTotal
        )
      }

    self.continueViewHidden = Signal
      .combineLatest(isLoggedIn, context)
      .map { $0 || $1.continueViewHidden }

    self.submitButtonHidden = self.continueViewHidden.negate()

    self.paymentMethodsViewHidden = Signal.combineLatest(isLoggedIn, context)
      .map { !$0 || $1.paymentMethodsViewHidden }

    let pledgeAmountIsValid = self.pledgeAmountDataSignal
      .map { $0.isValid }

    self.shippingLocationViewHidden = reward
      .map { $0.shipping.enabled }
      .negate()
      .combineLatest(with: context)
      .map { $0 || $1.shippingLocationViewHidden }

    self.configureStripeIntegration = Signal.combineLatest(
      initialData,
      context
    )
    .filter { !$1.paymentMethodsViewHidden }
    .ignoreValues()
    .map { _ in
      (
        Secrets.ApplePay.merchantIdentifier,
        AppEnvironment.current.environmentType.stripePublishableKey
      )
    }

    let selectedShippingRule = Signal.merge(
      initialData.mapConst(nil),
      self.shippingRuleSelectedSignal.wrapInOptional()
    )

    let selectedPaymentSourceId = Signal.merge(
      initialData.mapConst(nil),
      self.creditCardSelectedSignal.wrapInOptional()
    )

    // MARK: - Apple Pay

    let paymentAuthorizationData = Signal.combineLatest(
      project,
      reward,
      pledgeAmount,
      selectedShippingRule
    )
    .map { project, reward, pledgeAmount, shippingRule in
      (
        project,
        reward,
        pledgeAmount,
        shippingRule,
        Secrets.ApplePay.merchantIdentifier
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

    let pkPaymentData = self.pkPaymentSignal
      .map { pkPayment -> PKPaymentData? in
        guard let displayName = pkPayment.displayName, let network = pkPayment.network else {
          return nil
        }

        return (displayName, network, pkPayment.transactionIdentifier)
      }

    // MARK: - Create Apple Pay Backing

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

    let willCreateApplePayBacking = Signal.combineLatest(
      applePayStatusSuccess,
      context
    )
    .map { $1.isCreating }
    .filter(isTrue)

    // MARK: - Update Apple Pay Backing

    let applePayParams = Signal.combineLatest(
      pkPaymentData.skipNil(),
      self.stripeTokenSignal.skipNil()
    )
    .map { paymentData, token in
      (
        paymentData.displayName,
        paymentData.network,
        paymentData.transactionIdentifier,
        token
      )
    }
    .map(ApplePayParams.init)

    let applePayParamsData = Signal.merge(
      initialData.mapConst(nil),
      applePayParams.wrapInOptional()
    )

    // MARK: - Create Backing

    let createBackingData = Signal.combineLatest(
      project,
      reward,
      pledgeAmount,
      selectedShippingRule,
      selectedPaymentSourceId,
      applePayParamsData,
      refTag
    )
    .map { $0 as CreateBackingData }

    let createButtonTapped = Signal.combineLatest(
      self.submitButtonTappedSignal,
      context
    )
    .filter { _, context in context.isCreating }
    .ignoreValues()

    let createBackingDataAndIsApplePay = createBackingData.takePairWhen(
      Signal.merge(
        createButtonTapped.mapConst(false),
        willCreateApplePayBacking
      )
    )

    // Captures the checkoutId immediately and avoids a race condition further down the chain.
    let checkoutIdProperty = MutableProperty<Int?>(nil)

    let createBackingEvents = createBackingDataAndIsApplePay
      .map(CreateBackingInput.input(from:isApplePay:))
      .switchMap { [checkoutIdProperty] input in
        AppEnvironment.current.apiService.createBacking(input: input)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .map { envelope -> StripeSCARequiring in
            checkoutIdProperty.value = decompose(id: envelope.createBacking.checkout.id)
            return envelope as StripeSCARequiring
          }
          .materialize()
      }

    // MARK: - Update Backing

    let updateBackingData = Signal.combineLatest(
      backing,
      reward,
      pledgeAmount,
      selectedShippingRule,
      selectedPaymentSourceId,
      applePayParamsData
    )
    .map { $0 as UpdateBackingData }

    let willUpdateApplePayBacking = Signal.combineLatest(
      applePayStatusSuccess,
      context
    )
    .map { $1.isUpdating }
    .filter(isTrue)

    let updateButtonTapped = Signal.combineLatest(
      self.submitButtonTappedSignal,
      context
    )
    .filter { _, context in context.isUpdating }
    .ignoreValues()

    let updateBackingDataAndIsApplePay = updateBackingData.takePairWhen(
      Signal.merge(
        updateButtonTapped.mapConst(false),
        willUpdateApplePayBacking
      )
    )

    let updateBackingEvents = updateBackingDataAndIsApplePay
      .map(UpdateBackingInput.input(from:isApplePay:))
      .switchMap { input in
        AppEnvironment.current.apiService.updateBacking(input: input)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .map { $0 as StripeSCARequiring }
          .materialize()
      }

    let createOrUpdateEvent = Signal.merge(
      createBackingEvents,
      updateBackingEvents
    )

    // MARK: - Form Validation

    let amountChangedAndValid = Signal.combineLatest(
      project,
      reward,
      self.pledgeAmountDataSignal,
      context
    )
    .map(amountValid)

    let shippingRuleChangedAndValid = Signal.combineLatest(
      project,
      reward,
      selectedShippingRule,
      context
    )
    .map(shippingRuleValid)

    self.showApplePayAlert = Signal.combineLatest(
      project,
      self.pledgeAmountDataSignal
    )
    .takeWhen(showApplePayAlert)
    .map { project, pledgeAmountData in (project, pledgeAmountData.min, pledgeAmountData.max) }
    .map { project, min, max in
      (
        Strings.Almost_there(),
        Strings.Please_enter_a_pledge_amount_between_min_and_max(
          min: Format.currency(min, country: project.country, omitCurrencyCode: false),
          max: Format.currency(max, country: project.country, omitCurrencyCode: false)
        )
      )
    }

    let notChangingPaymentMethod = context.map { context in
      context.isUpdating && context != .changePaymentMethod
    }
    .filter(isTrue)

    let paymentMethodChangedAndValid = Signal.merge(
      notChangingPaymentMethod.mapConst(false),
      Signal.combineLatest(
        project,
        reward,
        self.creditCardSelectedSignal,
        context
      )
      .map(paymentMethodValid)
    )

    let valuesChangedAndValid = Signal.combineLatest(
      amountChangedAndValid,
      shippingRuleChangedAndValid,
      paymentMethodChangedAndValid,
      context
    )
    .map(allValuesChangedAndValid)

    self.submitButtonEnabled = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(false)
        .take(until: valuesChangedAndValid.ignoreValues()),
      valuesChangedAndValid,
      self.submitButtonTappedSignal.signal.mapConst(false),
      createOrUpdateEvent.filter { $0.isTerminating }.mapConst(true)
    )
    .skipRepeats()

    self.submitButtonIsLoading = Signal.merge(
      self.submitButtonTappedSignal.mapConst(true),
      createOrUpdateEvent.filter { $0.isTerminating }.mapConst(false)
    )

    let isCreateOrUpdateBacking = Signal.merge(
      self.submitButtonTappedSignal.mapConst(true),
      Signal.merge(willUpdateApplePayBacking, willCreateApplePayBacking).mapConst(false)
    )

    // MARK: - Success/Failure

    let scaFlowCompletedWithError = self.scaFlowCompletedWithResultSignal
      .filter { $0.0.status == .failed }
      .map(second)
      .skipNil()

    let scaFlowCompletedWithSuccess = self.scaFlowCompletedWithResultSignal
      .filter { $0.0.status == .succeeded }
      .map(first)
      .ignoreValues()

    let didInitiateApplePayBacking = Signal.merge(
      willCreateApplePayBacking,
      willUpdateApplePayBacking
    )

    let paymentAuthorizationDidFinish = didInitiateApplePayBacking
      .takeWhen(self.paymentAuthorizationDidFinishSignal)

    let createOrUpdateApplePayBackingCompleted = Signal.zip(
      didInitiateApplePayBacking,
      createOrUpdateEvent.filter { $0.isTerminating }.ignoreValues(),
      paymentAuthorizationDidFinish
    )

    let valuesOrNil = Signal.merge(
      createOrUpdateEvent.values().wrapInOptional(),
      isCreateOrUpdateBacking.mapConst(nil)
    )

    let createOrUpdateBackingEventValuesNoSCA = valuesOrNil
      .skipNil()
      .filter(requiresSCA >>> isFalse)

    let createOrUpdateBackingDidCompleteNoSCA = isCreateOrUpdateBacking
      .takeWhen(createOrUpdateBackingEventValuesNoSCA)
      .filter(isTrue)
      .ignoreValues()

    let createOrUpdateBackingEventValuesRequiresSCA = valuesOrNil
      .skipNil()
      .filter(requiresSCA)

    self.beginSCAFlowWithClientSecret = createOrUpdateBackingEventValuesRequiresSCA
      .map { $0.clientSecret }
      .skipNil()

    let didCompleteApplePayBacking = valuesOrNil
      .takeWhen(createOrUpdateApplePayBackingCompleted)
      .skipNil()

    let creatingContext = context.filter { $0.isCreating }

    let createBackingCompletionEvents = Signal.merge(
      didCompleteApplePayBacking.combineLatest(with: willCreateApplePayBacking).ignoreValues(),
      createOrUpdateBackingDidCompleteNoSCA.combineLatest(with: creatingContext).ignoreValues(),
      scaFlowCompletedWithSuccess.combineLatest(with: creatingContext).ignoreValues()
    )

    let thanksPageData = createBackingDataAndIsApplePay.combineLatest(with: checkoutIdProperty.signal)
      .map(unpack)
      .map { data, isApplePay, checkoutId -> ThanksPageData in
        let checkoutPropsData = checkoutPropertiesData(
          from: data,
          checkoutId: checkoutId,
          isApplePay: isApplePay
        )

        return (data.project, data.reward, checkoutPropsData)
      }

    self.goToThanks = thanksPageData
      .takeWhen(createBackingCompletionEvents)

    let errorsOrNil = Signal.merge(
      createOrUpdateEvent.errors().wrapInOptional(),
      isCreateOrUpdateBacking.mapConst(nil)
    )

    let createOrUpdateApplePayBackingError = createOrUpdateApplePayBackingCompleted
      .withLatest(from: errorsOrNil)
      .map(second)
      .skipNil()

    let createOrUpdateBackingError = isCreateOrUpdateBacking
      .takePairWhen(errorsOrNil.skipNil())
      .filter(first >>> isTrue)
      .map(second)

    let updatingContext = context.filter { $0.isUpdating }

    let updateBackingCompletionEvents = Signal.merge(
      didCompleteApplePayBacking.combineLatest(with: willUpdateApplePayBacking).ignoreValues(),
      createOrUpdateBackingDidCompleteNoSCA.combineLatest(with: updatingContext).ignoreValues(),
      scaFlowCompletedWithSuccess.combineLatest(with: updatingContext).ignoreValues()
    )

    self.notifyDelegateUpdatePledgeDidSucceedWithMessage = updateBackingCompletionEvents
      .mapConst(Strings.Got_it_your_changes_have_been_saved())

    let graphErrors = Signal.merge(
      createOrUpdateApplePayBackingError,
      createOrUpdateBackingError
    )
    .map { $0.localizedDescription }

    let scaErrors = scaFlowCompletedWithError.map { $0.localizedDescription }

    self.showErrorBannerWithMessage = Signal.merge(
      graphErrors,
      scaErrors
    )

    self.popToRootViewController = self.notifyDelegateUpdatePledgeDidSucceedWithMessage.ignoreValues()

    self.submitButtonTitle = context.map { $0.submitButtonTitle }
    self.title = context.map { $0.title }
    let contextAndProjectAndPledgeAmount = Signal.combineLatest(context, project, pledgeAmount)

    // Tracking

    contextAndProjectAndPledgeAmount
      .filter { $0.0 == .changePaymentMethod }
      .takeWhen(updateButtonTapped)
      .observeValues {
        AppEnvironment.current.koala.trackUpdatePaymentMethodButton(
          project: $1,
          pledgeAmount: $2
        )
      }

    contextAndProjectAndPledgeAmount
      .filter { $0.0 != .changePaymentMethod }
      .takeWhen(updateButtonTapped)
      .observeValues {
        AppEnvironment.current.koala.trackUpdatePledgeButtonClicked(
          project: $1,
          pledgeAmount: $2
        )
      }

    initialData
      .observeValues { project, reward, refTag, context in
        AppEnvironment.current.koala.trackCheckoutPaymentPageViewed(
          project: project,
          reward: reward,
          context: TrackingHelpers.pledgeContext(for: context),
          refTag: refTag
        )
      }

    initialData
      .observeValues { project, _, refTag, _ in
        let (properties, eventTags) = optimizelyTrackingAttributesAndEventTags(
          with: AppEnvironment.current.currentUser,
          project: project,
          refTag: refTag
        )

        try? AppEnvironment.current.optimizelyClient?
          .track(
            eventKey: "Pledge Screen Viewed",
            userId: deviceIdentifier(uuid: UUID()),
            attributes: properties,
            eventTags: eventTags
          )
      }

    createBackingData
      .takeWhen(createButtonTapped)
      .map { data in
        let checkoutData = checkoutPropertiesData(from: data, isApplePay: false)

        return (data.project, data.reward, data.refTag, checkoutData)
      }
      .observeValues { project, reward, refTag, checkoutData in
        AppEnvironment.current.koala.trackPledgeSubmitButtonClicked(
          project: project,
          reward: reward,
          checkoutData: checkoutData,
          refTag: refTag
        )
      }
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

  private let (scaFlowCompletedWithResultSignal, scaFlowCompletedWithResultObserver)
    = Signal<(StripePaymentHandlerActionStatusType, Error?), Never>.pipe()
  public func scaFlowCompleted(with result: StripePaymentHandlerActionStatusType, error: Error?) {
    self.scaFlowCompletedWithResultObserver.send(value: (result, error))
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

  private let (userSessionStartedSignal, userSessionStartedObserver) = Signal<Void, Never>.pipe()
  public func userSessionStarted() {
    self.userSessionStartedObserver.send(value: ())
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  // MARK: - Outputs

  public let beginSCAFlowWithClientSecret: Signal<String, Never>
  public let configurePaymentMethodsViewControllerWithValue: Signal<PledgePaymentMethodsValue, Never>
  public let configureStripeIntegration: Signal<StripeConfigurationData, Never>
  public let configureSummaryViewControllerWithData: Signal<(Project, Double), Never>
  public let configureWithData: Signal<(project: Project, reward: Reward), Never>
  public let confirmationLabelAttributedText: Signal<NSAttributedString, Never>
  public let confirmationLabelHidden: Signal<Bool, Never>
  public let continueViewHidden: Signal<Bool, Never>
  public let descriptionViewHidden: Signal<Bool, Never>
  public let goToApplePayPaymentAuthorization: Signal<PaymentAuthorizationData, Never>
  public let goToThanks: Signal<ThanksPageData, Never>
  public let notifyDelegateUpdatePledgeDidSucceedWithMessage: Signal<String, Never>
  public let notifyPledgeAmountViewControllerShippingAmountChanged: Signal<Double, Never>
  public let paymentMethodsViewHidden: Signal<Bool, Never>
  public let pledgeAmountViewHidden: Signal<Bool, Never>
  public let pledgeAmountSummaryViewHidden: Signal<Bool, Never>
  public let popToRootViewController: Signal<(), Never>
  public let sectionSeparatorsHidden: Signal<Bool, Never>
  public let shippingLocationViewHidden: Signal<Bool, Never>
  public let showErrorBannerWithMessage: Signal<String, Never>
  public let showApplePayAlert: Signal<(String, String), Never>
  public let submitButtonEnabled: Signal<Bool, Never>
  public let submitButtonHidden: Signal<Bool, Never>
  public let submitButtonIsLoading: Signal<Bool, Never>
  public let submitButtonTitle: Signal<String, Never>
  public let title: Signal<String, Never>

  public var inputs: PledgeViewModelInputs { return self }
  public var outputs: PledgeViewModelOutputs { return self }
}

// MARK: - Functions

private func requiresSCA(_ envelope: StripeSCARequiring) -> Bool {
  return envelope.requiresSCAFlow
}

private func attributedConfirmationString(with project: Project, pledgeTotal: Double) -> NSAttributedString {
  let date = Format.date(secondsInUTC: project.dates.deadline, template: "MMMM d, yyyy")
  let pledgeTotal = Format.currency(pledgeTotal, country: project.country)

  let font = UIFont.ksr_caption1()
  let foregroundColor = UIColor.ksr_text_dark_grey_500

  let paragraphStyle = NSMutableParagraphStyle()
  paragraphStyle.alignment = .center

  let attributes = [
    NSAttributedString.Key.paragraphStyle: paragraphStyle
  ]

  guard project.stats.needsConversion else {
    return Strings.If_the_project_reaches_its_funding_goal_you_will_be_charged_on_project_deadline(
      project_deadline: date
    )
    .attributed(with: font, foregroundColor: foregroundColor, attributes: attributes, bolding: [date])
  }

  return Strings.If_the_project_reaches_its_funding_goal_you_will_be_charged_total_on_project_deadline(
    total: pledgeTotal,
    project_deadline: date
  )
  .attributed(
    with: font, foregroundColor: foregroundColor, attributes: attributes, bolding: [pledgeTotal, date]
  )
}

// MARK: - Validation Functions

private func amountValid(
  project: Project,
  reward: Reward,
  pledgeAmountData: PledgeAmountData,
  context: PledgeViewContext
) -> Bool {
  guard
    let backing = project.personalization.backing,
    context.isUpdating,
    userIsBacking(reward: reward, inProject: project)
  else {
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
  if context.isCreating || context == .updateReward {
    return !reward.shipping.enabled || shippingRule != nil
  }

  guard
    let backing = project.personalization.backing,
    let shippingRule = shippingRule,
    context.isUpdating
  else {
    return false
  }

  return backing.locationId != shippingRule.location.id
}

private func paymentMethodValid(
  project: Project,
  reward: Reward,
  paymentSourceId: String,
  context: PledgeViewContext
) -> Bool {
  guard
    let backedPaymentSourceId = project.personalization.backing?.paymentSource?.id,
    context.isUpdating,
    userIsBacking(reward: reward, inProject: project)
  else {
    return true
  }

  return backedPaymentSourceId != paymentSourceId
}

private func allValuesChangedAndValid(
  amountValid: Bool,
  shippingRuleValid: Bool,
  paymentSourceValid: Bool,
  context: PledgeViewContext
) -> Bool {
  if context.isUpdating, context != .updateReward {
    return amountValid || shippingRuleValid || paymentSourceValid
  }

  return amountValid && shippingRuleValid
}

// MARK: - Helper Functions

private func checkoutPropertiesData(
  from createBackingData: CreateBackingData,
  checkoutId: Int? = nil,
  isApplePay: Bool
)
  -> Koala.CheckoutPropertiesData {
  var pledgeTotal = createBackingData.pledgeAmount

  if let shippingRule = createBackingData.shippingRule {
    pledgeTotal = pledgeTotal.addingCurrency(shippingRule.cost)
  }

  let pledgeTotalUsdCents = pledgeTotal
    .multiplyingCurrency(Double(createBackingData.project.stats.staticUsdRate))
    .multiplyingCurrency(100.0)
    .rounded()

  let amount = Format.decimalCurrency(for: pledgeTotal)
  let revenueInUsdCents = Int(pledgeTotalUsdCents)
  let rewardId = createBackingData.reward.id
  let estimatedDelivery = createBackingData.reward.estimatedDeliveryOn
  let paymentType = isApplePay
    ? Backing.PaymentType.applePay.rawValue
    : Backing.PaymentType.creditCard.rawValue
  let shippingEnabled = createBackingData.reward.shipping.enabled
  let shippingAmount = createBackingData.shippingRule?.cost
  let rewardTitle = createBackingData.reward.title
  let userHasEligibleStoredApplePayCard = AppEnvironment.current
    .applePayCapabilities
    .applePayCapable(for: createBackingData.project)

  return Koala.CheckoutPropertiesData(
    amount: amount,
    checkoutId: checkoutId,
    estimatedDelivery: estimatedDelivery,
    paymentType: paymentType,
    revenueInUsdCents: revenueInUsdCents,
    rewardId: rewardId,
    rewardTitle: rewardTitle,
    shippingEnabled: shippingEnabled,
    shippingAmount: shippingAmount,
    userHasStoredApplePayCard: userHasEligibleStoredApplePayCard
  )
}
