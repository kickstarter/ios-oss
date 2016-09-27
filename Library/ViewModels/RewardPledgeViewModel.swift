// swiftlint:disable file_length
import KsApi
import PassKit
import Prelude
import ReactiveCocoa
import Result

public protocol RewardPledgeViewModelInputs {
  /// Call when the apple pay button is tapped.
  func applePayButtonTapped()

  func cancelPledgeButtonTapped()

  /// Call when the shipping picker has notified us that shipping has changed.
  func change(shippingRule shippingRule: ShippingRule)

  /// Call with the project and reward provided to the view.
  func configureWith(project project: Project, reward: Reward, applePayCapable: Bool)

  /// Call when the "continue to payments" button is tapped.
  func continueToPaymentsButtonTapped()

  func continueToUpdatePledgeTapped()

  /// Call when the description label is tapped.
  func descriptionLabelTapped()

  /// Call when the "different payment method" button is tapped.
  func differentPaymentMethodButtonTapped()

  /// Call when the disclaimer button is tapped.
  func disclaimerButtonTapped()

  /// Call from the payment authorization delegate method.
  func paymentAuthorizationDidFinish()

  /// Call from the payment authorization method when a payment has been authorized.
  func paymentAuthorization(didAuthorizePayment payment: PaymentData)

  /// Call from the payment authorization delegate method.
  func paymentAuthorizationWillAuthorizePayment()

  /// Call when the pledge text field is changed.
  func pledgeTextFieldChanged(text: String)

  /// Call when the pledge text field ends editing.
  func pledgeTextFieldDidEndEditing()

  /// Call when the shipping button is tapped.
  func shippingButtonTapped()

  /// Call from the Stripe callback method once a stripe token has been created.
  func stripeCreatedToken(stripeToken stripeToken: String?, error: NSError?) -> PKPaymentAuthorizationStatus

  /// Call when the user starts a session.
  func userSessionStarted()

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol RewardPledgeViewModelOutputs {
  /// Emits a boolean that determines if the apple pay button is hidden.
  var applePayButtonHidden: Signal<Bool, NoError> { get }

  /// Emits a boolean that determines if the "continue to payments" button is hidden.
  var continueToPaymentsButtonHidden: Signal<Bool, NoError> { get }

  /// Emits a boolean that determines if the conversion label is hidden.
  var conversionLabelHidden: Signal<Bool, NoError> { get }

  /// Emits a string to be put into the conversion label.
  var conversionLabelText: Signal<String, NoError> { get }

  /// Emits a string to be put into the shipping country label.
  var countryLabelText: Signal<String, NoError> { get }

  /// Emits a string to be put into the description label.
  var descriptionLabelText: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the "different payment method" button is hidden.
  var differentPaymentMethodButtonHidden: Signal<Bool, NoError> { get }

  /// Emits a string to be put into the estimated delivery date label.
  var estimatedDeliveryDateLabelText: Signal<String, NoError> { get }

  /// Emits when the reward description should be expanded.
  var expandRewardDescription: Signal<(), NoError> { get }

  /// Emits a boolean that determines if the fulfillment footer stack view should be hidden.
  var fulfillmentAndShippingFooterStackViewHidden: Signal<Bool, NoError> { get }

  /// Emits when the checkout screen should be shown to the user.
  var goToCheckout: Signal<(NSURLRequest, Project), NoError> { get }

  /// Emits when the login tout should be shown to the user.
  var goToLoginTout: Signal<(), NoError> { get }

  /// Emits a payment request object that is to be used to present a payment authorization controller.
  var goToPaymentAuthorization: Signal<PKPaymentRequest, NoError> { get }

  /// Emits a project, list of shipping rules, and current selected shipping rule that are to be used to
  /// go to the shipping picker.
  var goToShippingPicker: Signal<(Project, [ShippingRule], ShippingRule), NoError> { get }

  /// Emits when we should go to the thanks screen.
  var goToThanks: Signal<Project, NoError> { get }

  /// Emits when the web modal should be loaded.
  var goToWebModal: Signal<NSURLRequest, NoError> { get }

  /// Emits an array of strings that are to be loaded into the itemization stack view.
  var items: Signal<[String], NoError> { get }

  /// Emits a boolean that determines if the itemization stack view is hidden.
  var itemsContainerHidden: Signal<Bool, NoError> { get }

  var managePledgeButtonsStackViewHidden: Signal<Bool, NoError> { get }

  /// Emits a string to be put into the minimum pledge label.
  var minimumLabelText: Signal<String, NoError> { get }

  /// Emits a string for the title of the navigation controller.
  var navigationTitle: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the pay button is enabled.
  var payButtonsEnabled: Signal<Bool, NoError> { get }

  var pledgeButtonsStackViewHidden: Signal<Bool, NoError> { get }

  /// Emits a string to be put into the currency label.
  var pledgeCurrencyLabelText: Signal<String, NoError> { get }

  /// Emits a string to be put into the pledge text field.
  var pledgeTextFieldText: Signal<String, NoError> { get }

  /// Emits a boolean when the read more container should be hidden.
  var readMoreContainerViewHidden: Signal<Bool, NoError> { get }

  /// Emits a string to be used to set the Stripe library's apple merchant identifier.
  var setStripeAppleMerchantIdentifier: Signal<String, NoError> { get }

  /// Emits a string to be used to set the Stripe library's publishable key.
  var setStripePublishableKey: Signal<String, NoError> { get }

  /// Emits a string to be put into the shipping amount label.
  var shippingAmountLabelText: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the shipping container view should be hidden.
  var shippingInputStackViewHidden: Signal<Bool, NoError> { get }

  /// Emits a string that should be put into the shipping locations label.
  var shippingLocationsLabelText: Signal<String, NoError> { get }

  /// Emits a string to be shown in an alert controller.
  var showAlert: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the title label should be hidden.
  var titleLabelHidden: Signal<Bool, NoError> { get }

  /// Emits a string to be put into the title label.
  var titleLabelText: Signal<String, NoError> { get }
}

public protocol RewardPledgeViewModelType {
  var inputs: RewardPledgeViewModelInputs { get }
  var outputs: RewardPledgeViewModelOutputs { get }
}

// swiftlint:disable type_body_length
public final class RewardPledgeViewModel: RewardPledgeViewModelType, RewardPledgeViewModelInputs,
RewardPledgeViewModelOutputs {

  private let rewardViewModel: RewardCellViewModelType = RewardCellViewModel()

  // swiftlint:disable function_body_length
  public init() {
    let projectAndRewardAndApplePayCapable = combineLatest(
      self.projectAndRewardAndApplePayCapableProperty.signal.ignoreNil(),
      self.viewDidLoadProperty.signal
      )
      .map(first)

    let projectAndReward = projectAndRewardAndApplePayCapable
      .map { project, reward, _ in (project, reward) }

    let applePayCapable = projectAndRewardAndApplePayCapable
      .map { _, _, applePayCapable in applePayCapable }

    let project = projectAndReward
      .map(first)
    let reward = projectAndReward
      .map(second)

    let currentUser = Signal.merge([
      self.viewDidLoadProperty.signal,
      self.userSessionStartedProperty.signal
      ])
      .map { AppEnvironment.current.currentUser }
      .skipRepeats(==)

    let shippingRules = projectAndReward
      .switchMap { project, reward in
        AppEnvironment.current.apiService.fetchRewardShippingRules(projectId: project.id, rewardId: reward.id)
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .map(ShippingRulesEnvelope.lens.shippingRules.view)
          .demoteErrors()
    }

    self.navigationTitle = projectAndReward
      .map(navigationTitle(forProject:reward:))

    self.setStripeAppleMerchantIdentifier = applePayCapable
      .filter(isTrue)
      .mapConst(PKPaymentAuthorizationViewController.merchantIdentifier)

    self.setStripePublishableKey = applePayCapable
      .filter(isTrue)
      .map { _ in AppEnvironment.current.config?.stripePublishableKey }
      .ignoreNil()

    self.applePayButtonHidden = combineLatest(
      applePayCapable.map(negate),
      self.viewDidLoadProperty.signal
      )
      .map(first)

    self.differentPaymentMethodButtonHidden = self.applePayButtonHidden
    self.continueToPaymentsButtonHidden = self.applePayButtonHidden.map(negate)

    let defaultShippingRule = shippingRules
      .map(defaultShippingRule(fromShippingRules:))

    let selectedShipping = Signal.merge(
      defaultShippingRule,
      self.changedShippingRuleProperty.signal
    )

    self.shippingInputStackViewHidden = reward
      .map { !$0.shipping.enabled }

    self.goToShippingPicker = combineLatest(
      project,
      shippingRules,
      selectedShipping.ignoreNil()
      )
      .takeWhen(self.shippingButtonTappedProperty.signal)

    self.paymentAuthorizationStatusProperty <~ self.stripeTokenAndErrorProperty.signal
      .map { _, error in error == nil ? .Success : .Failure }

    self.countryLabelText = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(""),
      selectedShipping.ignoreNil().map { $0.location.displayableName }
    )

    let shippingAmount = combineLatest(
      project,
      selectedShipping.ignoreNil()
      )
      .map { project, shippingRule in
        Strings.plus_shipping_cost(
          shipping_cost: Format.currency(Int(shippingRule.cost), country: project.country)
        )
    }

    self.shippingAmountLabelText = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(""),
      shippingAmount
    )

    self.readMoreContainerViewHidden = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(false),
      self.descriptionLabelTappedProperty.signal.mapConst(true)
    )

    self.itemsContainerHidden = self.readMoreContainerViewHidden.map(negate)

    self.expandRewardDescription = self.descriptionLabelTappedProperty.signal

    self.shippingLocationsLabelText = reward
      .map { $0.shipping.summary }
      .ignoreNil()

    self.estimatedDeliveryDateLabelText = reward
      .map { reward in
        reward.estimatedDeliveryOn.map {
          Format.date(secondsInUTC: $0, dateFormat: "MMM yyyy")
        }
      }
      .ignoreNil()

    self.fulfillmentAndShippingFooterStackViewHidden = reward
      .map { !$0.shipping.enabled }

    self.pledgeCurrencyLabelText = project
      .map(currencyLabel(forProject:))

    let initialPledgeTextFieldText = projectAndReward
      .map { (project, reward) -> Int in
        guard let backing = project.personalization.backing
          where userIsBacking(reward: reward, inProject: project) else {

            return reward == Reward.noReward
              ? project.country.minPledge ?? 1
              : reward.minimum
        }

        return backing.amount - (backing.shippingAmount ?? 0)
    }

    let pledgeAmount = Signal.merge(
      initialPledgeTextFieldText,
      self.pledgeTextChangedProperty.signal.map { Int($0) ?? 0 }
      )

    let pledgeTextFieldWhenReturnWithBadAmount = combineLatest(
      pledgeAmount,
      projectAndReward.map(minAndMaxPledgeAmount(forProject:reward:))
      )
      .takeWhen(self.pledgeTextFieldDidEndEditingProperty.signal)
      .filter { pledgeAmount, minAndMax in pledgeAmount < minAndMax.0 || pledgeAmount > minAndMax.1 }
      .map { _, minAndMax in minAndMax.0 }

    self.pledgeTextFieldText = Signal.merge(
      initialPledgeTextFieldText,
      pledgeTextFieldWhenReturnWithBadAmount
      )
      .map { String($0) }

    self.payButtonsEnabled = combineLatest(
      Signal.merge(pledgeAmount, pledgeTextFieldWhenReturnWithBadAmount),
      projectAndReward.map(minAndMaxPledgeAmount(forProject:reward:))
      )
      .map { pledgeAmount, minAndMax in pledgeAmount >= minAndMax.0 && pledgeAmount <= minAndMax.1 }
      .skipRepeats()

    let paymentMethodTapped = Signal.merge(
      self.continueToPaymentsButtonTappedProperty.signal,
      self.differentPaymentMethodButtonTappedProperty.signal
    )

    let loggedOutUserTappedApplePayButton = currentUser
      .takeWhen(self.applePayButtonTappedProperty.signal)
      .filter { $0 == nil }

    let loggedOutUserTappedPaymentMethodButton = currentUser
      .takeWhen(paymentMethodTapped)
      .filter { $0 == nil }

    let loggedInUserTappedApplePayButton = currentUser
      .takeWhen(self.applePayButtonTappedProperty.signal)
      .filter { $0 != nil }
      .ignoreValues()

    let applePayEventAfterLogin = Signal.merge(
      loggedOutUserTappedApplePayButton.mapConst(true),
      loggedOutUserTappedPaymentMethodButton.mapConst(false)
      )
      .takeWhen(currentUser.filter(isNotNil))
      .filter(isTrue)
      .ignoreValues()

    let paymentMethodEventAfterLogin = Signal.merge(
      loggedOutUserTappedApplePayButton.mapConst(true),
      loggedOutUserTappedPaymentMethodButton.mapConst(false)
      )
      .takeWhen(currentUser.filter(isNotNil))
      .filter(isFalse)
      .ignoreValues()

    let loggedInUserTappedPaymentMethodButton = currentUser
      .takeWhen(paymentMethodTapped)
      .filter { $0 != nil }
      .ignoreValues()

    self.goToLoginTout = Signal.merge(
      loggedOutUserTappedApplePayButton,
      loggedOutUserTappedPaymentMethodButton
      ).ignoreValues()

    self.goToPaymentAuthorization = combineLatest(
      projectAndReward,
      pledgeAmount,
      selectedShipping,
      self.setStripeAppleMerchantIdentifier
      )
      .map { ($0.0, $0.1, $1, $2, $3) }
      .takeWhen(Signal.merge(applePayEventAfterLogin, loggedInUserTappedApplePayButton))
      .map(paymentRequest(forProject:reward:pledgeAmount:selectedShippingRule:merchantIdentifier:))

    let createApplePayPledgeEvent = combineLatest(
      projectAndReward,
      pledgeAmount,
      selectedShipping,
      self.didAuthorizePaymentProperty.signal.ignoreNil()
      )
      .takePairWhen(self.stripeTokenAndErrorProperty.signal.map(first).ignoreNil())
      .map { ($0.0.0, $0.0.1, $0.1, $0.2, $0.3, $1) }
      .switchMap { project, reward, amount, shipping, paymentData, stripeToken in
        createApplePayPledge(
          project: project,
          reward: reward,
          amount: amount,
          shipping: shipping,
          paymentData: paymentData,
          stripeToken: stripeToken
        )
        .materialize()
    }

    self.goToThanks = project
      .takeWhen(createApplePayPledgeEvent.values())

    let createPledgeEvent = combineLatest(
      projectAndReward,
      pledgeAmount,
      selectedShipping
      )
      .takeWhen(Signal.merge(paymentMethodEventAfterLogin, loggedInUserTappedPaymentMethodButton))
      .map { ($0.0, $0.1, $1, $2) }
      .switchMap { project, reward, amount, shipping in
        createPledge(project: project, reward: reward, amount: amount, shipping: shipping)
          .materialize()
    }

    let cancelPledge = project
      .takeWhen(self.cancelPledgeButtonTappedProperty.signal)
      .map { project -> (NSURLRequest, Project)? in
        guard let request = NSURL(string: project.urls.web.project)
          .flatMap({ optionalize($0.URLByAppendingPathComponent("pledge")) })
          .flatMap({ optionalize($0.URLByAppendingPathComponent("destroy")) })
          .flatMap({ optionalize(NSURLRequest(URL: $0)) }) else {
          return nil
        }
        return (request, project)
      }
      .ignoreNil()

    let updatePledgeEvent = combineLatest(
      projectAndReward,
      pledgeAmount,
      selectedShipping
      )
      .takeWhen(self.continueToUpdatePledgeTappedProperty.signal)
      .map { ($0.0, $0.1, $1, $2) }
      .switchMap { project, reward, amount, shipping in
        updatePledge(project: project, reward: reward, amount: amount, shipping: shipping)
          .materialize()
    }

    self.goToCheckout = Signal.merge(
      createPledgeEvent.values(),
      cancelPledge,
      updatePledgeEvent.values()
      )

    self.goToWebModal = project
      .takeWhen(self.disclaimerButtonTappedProperty.signal)
      .map {
        NSURL(string: $0.urls.web.project)?.URLByAppendingPathComponent("pledge/big_print")
      }
      .ignoreNil()
      .map(NSURLRequest.init(URL:))

    self.showAlert = Signal.merge(
      createPledgeEvent.errors(),
      createApplePayPledgeEvent.errors()
      )
      .map { $0.errorMessages.first }
      .ignoreNil()

    self.managePledgeButtonsStackViewHidden = project.map { $0.personalization.isBacking != true }
    self.pledgeButtonsStackViewHidden = project.map { $0.personalization.isBacking == true }

    project
      .takeWhen(self.paymentAuthorizationWillAuthorizeProperty.signal)
      .observeNext {
        AppEnvironment.current.koala.trackShowApplePaySheet(project: $0, context: .native)
    }

    project
      .takeWhen(self.didAuthorizePaymentProperty.signal)
      .observeNext {
        AppEnvironment.current.koala.trackApplePayAuthorizedPayment(project: $0, context: .native)
    }

    project
      .takeWhen(self.stripeTokenAndErrorProperty.signal.filter(isNotNil • first))
      .observeNext {
        AppEnvironment.current.koala.trackStripeTokenCreatedForApplePay(project: $0, context: .native)
    }

    project
      .takeWhen(self.stripeTokenAndErrorProperty.signal.filter(isNotNil • second))
      .observeNext {
        AppEnvironment.current.koala.trackStripeTokenErroredForApplePay(project: $0, context: .native)
    }

    let applePaySuccessful = Signal.merge(
      self.paymentAuthorizationWillAuthorizeProperty.signal.mapConst(false),
      self.didAuthorizePaymentProperty.signal.mapConst(true)
    )

    combineLatest(project, applePaySuccessful)
      .takeWhen(self.paymentAuthorizationFinishedProperty.signal)
      .observeNext { project, successful in
        successful
          ? AppEnvironment.current.koala.trackApplePayFinished(project: project, context: .native)
          : AppEnvironment.current.koala.trackApplePaySheetCanceled(project: project, context: .native)
    }

    projectAndReward
      .observeNext { [weak self] project, reward in
        self?.rewardViewModel.inputs.configureWith(project: project, reward: reward)
        self?.rewardViewModel.inputs.boundStyles()
    }
  }
  // swiftlint:enable function_body_length

  private let applePayButtonTappedProperty = MutableProperty()
  public func applePayButtonTapped() {
    self.applePayButtonTappedProperty.value = ()
  }

  private let cancelPledgeButtonTappedProperty = MutableProperty()
  public func cancelPledgeButtonTapped() {
    self.cancelPledgeButtonTappedProperty.value = ()
  }

  private let changedShippingRuleProperty = MutableProperty<ShippingRule?>(nil)
  public func change(shippingRule shippingRule: ShippingRule) {
    self.changedShippingRuleProperty.value = shippingRule
  }

  private let projectAndRewardAndApplePayCapableProperty = MutableProperty<(Project, Reward, Bool)?>(nil)
  public func configureWith(project project: Project, reward: Reward, applePayCapable: Bool) {
    self.projectAndRewardAndApplePayCapableProperty.value = (project, reward, applePayCapable)
  }

  private let continueToPaymentsButtonTappedProperty = MutableProperty()
  public func continueToPaymentsButtonTapped() {
    self.continueToPaymentsButtonTappedProperty.value = ()
  }

  private let continueToUpdatePledgeTappedProperty = MutableProperty()
  public func continueToUpdatePledgeTapped() {
    self.continueToUpdatePledgeTappedProperty.value = ()
  }

  private let differentPaymentMethodButtonTappedProperty = MutableProperty()
  public func differentPaymentMethodButtonTapped() {
    self.differentPaymentMethodButtonTappedProperty.value = ()
  }

  private let disclaimerButtonTappedProperty = MutableProperty()
  public func disclaimerButtonTapped() {
    self.disclaimerButtonTappedProperty.value = ()
  }

  private let paymentAuthorizationFinishedProperty = MutableProperty()
  public func paymentAuthorizationDidFinish() {
    self.paymentAuthorizationFinishedProperty.value = ()
  }

  private let didAuthorizePaymentProperty = MutableProperty<PaymentData?>(nil)
  public func paymentAuthorization(didAuthorizePayment payment: PaymentData) {
    self.didAuthorizePaymentProperty.value = payment
  }

  private let paymentAuthorizationWillAuthorizeProperty = MutableProperty()
  public func paymentAuthorizationWillAuthorizePayment() {
    self.paymentAuthorizationWillAuthorizeProperty.value = ()
  }

  private let pledgeTextChangedProperty = MutableProperty("")
  public func pledgeTextFieldChanged(text: String) {
    self.pledgeTextChangedProperty.value = text
  }

  private let pledgeTextFieldDidEndEditingProperty = MutableProperty()
  public func pledgeTextFieldDidEndEditing() {
    self.pledgeTextFieldDidEndEditingProperty.value = ()
  }

  private let descriptionLabelTappedProperty = MutableProperty()
  public func descriptionLabelTapped() {
    self.descriptionLabelTappedProperty.value = ()
  }

  private let shippingButtonTappedProperty = MutableProperty()
  public func shippingButtonTapped() {
    self.shippingButtonTappedProperty.value = ()
  }

  private let stripeTokenAndErrorProperty = MutableProperty(String?.None, NSError?.None)
  private let paymentAuthorizationStatusProperty = MutableProperty(PKPaymentAuthorizationStatus.Failure)
  public func stripeCreatedToken(stripeToken stripeToken: String?, error: NSError?)
    -> PKPaymentAuthorizationStatus {

      self.stripeTokenAndErrorProperty.value = (stripeToken, error)
      return self.paymentAuthorizationStatusProperty.value
  }

  private let userSessionStartedProperty = MutableProperty()
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let applePayButtonHidden: Signal<Bool, NoError>
  public let continueToPaymentsButtonHidden: Signal<Bool, NoError>
  public var conversionLabelHidden: Signal<Bool, NoError> {
    return self.rewardViewModel.outputs.conversionLabelHidden
  }
  public var conversionLabelText: Signal<String, NoError> {
    return self.rewardViewModel.outputs.conversionLabelText
  }
  public let countryLabelText: Signal<String, NoError>
  public var descriptionLabelText: Signal<String, NoError> {
    return self.rewardViewModel.outputs.descriptionLabelText
  }
  public let differentPaymentMethodButtonHidden: Signal<Bool, NoError>
  public let estimatedDeliveryDateLabelText: Signal<String, NoError>
  public let expandRewardDescription: Signal<(), NoError>
  public let fulfillmentAndShippingFooterStackViewHidden: Signal<Bool, NoError>
  public let goToCheckout: Signal<(NSURLRequest, Project), NoError>
  public let goToLoginTout: Signal<(), NoError>
  public let goToPaymentAuthorization: Signal<PKPaymentRequest, NoError>
  public let goToShippingPicker: Signal<(Project, [ShippingRule], ShippingRule), NoError>
  public let goToThanks: Signal<Project, NoError>
  public let goToWebModal: Signal<NSURLRequest, NoError>
  public var items: Signal<[String], NoError> {
    return self.rewardViewModel.outputs.items
  }
  public let itemsContainerHidden: Signal<Bool, NoError>
  public let managePledgeButtonsStackViewHidden: Signal<Bool, NoError>
  public var minimumLabelText: Signal<String, NoError> {
    return self.rewardViewModel.outputs.minimumLabelText
  }
  public let navigationTitle: Signal<String, NoError>
  public let payButtonsEnabled: Signal<Bool, NoError>
  public let pledgeButtonsStackViewHidden: Signal<Bool, NoError>
  public let pledgeCurrencyLabelText: Signal<String, NoError>
  public let pledgeTextFieldText: Signal<String, NoError>
  public let readMoreContainerViewHidden: Signal<Bool, NoError>
  public let setStripeAppleMerchantIdentifier: Signal<String, NoError>
  public let setStripePublishableKey: Signal<String, NoError>
  public let shippingAmountLabelText: Signal<String, NoError>
  public let shippingInputStackViewHidden: Signal<Bool, NoError>
  public let shippingLocationsLabelText: Signal<String, NoError>
  public let showAlert: Signal<String, NoError>
  public var titleLabelHidden: Signal<Bool, NoError> {
    return self.rewardViewModel.outputs.titleLabelHidden
  }
  public var titleLabelText: Signal<String, NoError> {
    return self.rewardViewModel.outputs.titleLabelText
  }

  public var inputs: RewardPledgeViewModelInputs { return self }
  public var outputs: RewardPledgeViewModelOutputs { return self }
}
// swiftlint:enable type_body_length

private func paymentRequest(forProject project: Project,
                                       reward: Reward,
                                       pledgeAmount: Int,
                                       selectedShippingRule: ShippingRule?,
                                       merchantIdentifier: String) -> PKPaymentRequest {
  let request = PKPaymentRequest()
  request.merchantIdentifier = merchantIdentifier
  request.supportedNetworks = PKPaymentAuthorizationViewController.supportedNetworks
  request.merchantCapabilities = .Capability3DS
  request.countryCode = project.country.countryCode
  request.currencyCode = project.country.currencyCode
  request.shippingType = .Shipping

  request.paymentSummaryItems = paymentSummaryItems(forProject: project,
                                                    reward: reward,
                                                    pledgeAmount: pledgeAmount,
                                                    selectedShippingRule: selectedShippingRule)

  return request
}

private func paymentSummaryItems(forProject project: Project,
                                            reward: Reward,
                                            pledgeAmount: Int,
                                            selectedShippingRule: ShippingRule?) -> [PKPaymentSummaryItem] {

  var paymentSummaryItems: [PKPaymentSummaryItem] = []

  paymentSummaryItems.append(
    PKPaymentSummaryItem(
      label: reward.title ?? project.name,
      amount: NSDecimalNumber(long: pledgeAmount),
      type: .Final
    )
  )

  if let selectedShippingRule = selectedShippingRule where selectedShippingRule.cost != 0.0 {
    paymentSummaryItems.append(
      PKPaymentSummaryItem(
        label: Strings.Shipping(),
        amount: NSDecimalNumber(double: selectedShippingRule.cost),
        type: .Final
      )
    )
  }

  let total = paymentSummaryItems.reduce(NSDecimalNumber.zero()) { accum, item in
    accum.decimalNumberByAdding(item.amount)
  }

  paymentSummaryItems.append(

    PKPaymentSummaryItem(
      label: Strings.Kickstarter_if_funded(),
      amount: total,
      type: .Final
    )

  )

  return paymentSummaryItems
}

private func defaultShippingRule(fromShippingRules shippingRules: [ShippingRule]) -> ShippingRule? {

  let shippingRuleFromCurrentLocation = shippingRules
    .filter { shippingRule in shippingRule.location.country == AppEnvironment.current.config?.countryCode }
    .first

  if let shippingRuleFromCurrentLocation = shippingRuleFromCurrentLocation {
    return shippingRuleFromCurrentLocation
  }

  let shippingRuleInUSA = shippingRules
    .filter { shippingRule in shippingRule.location.country == "US" }
    .first

  return shippingRuleInUSA ?? shippingRules.first
}

private func currencyLabel(forProject project: Project) -> String {
  guard project.country.countryCode != "US" || AppEnvironment.current.config?.countryCode != "US" else {
    return project.country.currencySymbol
  }

  let projectCurrencySymbolIsAmbiguous = 1 != AppEnvironment.current.config?.launchedCountries
    .distincts { $0.currencyCode == $1.currencyCode }
    .filter { $0.currencySymbol == project.country.currencySymbol }
    .count

  return projectCurrencySymbolIsAmbiguous
    ? "\(project.country.currencyCode) \(project.country.currencySymbol)"
    : project.country.currencySymbol
}

private func createPledge(
  project project: Project,
          reward: Reward?,
          amount: Int,
          shipping: ShippingRule?) -> SignalProducer<(NSURLRequest, Project), ErrorEnvelope> {

  let totalAmount = Double(amount) + (shipping?.cost ?? 0)

  return AppEnvironment.current.apiService.createPledge(
    project: project,
    amount: totalAmount,
    reward: reward,
    shippingLocation: shipping?.location,
    tappedReward: true
    )
    .flatMap { env -> SignalProducer<(NSURLRequest, Project), ErrorEnvelope> in

      #if swift(>=2.3)
        guard let url = AppEnvironment.current.apiService.serverConfig.webBaseUrl
        .URLByAppendingPathComponent(env.checkoutUrl)?
        .URLByAppendingPathComponent("new") else { return .empty }
      #else
        guard let url = env.newCheckoutUrl
          .map({ AppEnvironment.current.apiService.serverConfig.webBaseUrl.URLByAppendingPathComponent($0) })
        else { return .empty }
      #endif

      let request = NSURLRequest(URL: url)
      return SignalProducer(value: (request, project))
  }
}

private func updatePledge(
  project project: Project,
          reward: Reward?,
          amount: Int,
          shipping: ShippingRule?) -> SignalProducer<(NSURLRequest, Project), ErrorEnvelope> {

  let totalAmount = Double(amount) + (shipping?.cost ?? 0)

  return AppEnvironment.current.apiService.updatePledge(
    project: project,
    amount: totalAmount,
    reward: reward,
    shippingLocation: shipping?.location,
    tappedReward: true
    )
    .flatMap { env -> SignalProducer<(NSURLRequest, Project), ErrorEnvelope> in

      #if swift(>=2.3)
        guard let url = AppEnvironment.current.apiService.serverConfig.webBaseUrl
        .URLByAppendingPathComponent(env.checkoutUrl)? else { return .empty }
      #else
        guard let url = env.newCheckoutUrl
          .map({ AppEnvironment.current.apiService.serverConfig.webBaseUrl.URLByAppendingPathComponent($0) })
        else { return .empty }
      #endif

      let request = NSURLRequest(URL: url)
      return SignalProducer(value: (request, project))
  }
}

private func createApplePayPledge(
  project project: Project,
  reward: Reward?,
  amount: Int,
  shipping: ShippingRule?,
  paymentData: PaymentData,
  stripeToken: String) -> SignalProducer<SubmitApplePayEnvelope, ErrorEnvelope> {

  let totalAmount = Double(amount) + (shipping?.cost ?? 0)

  return AppEnvironment.current.apiService.createPledge(
    project: project,
    amount: totalAmount,
    reward: reward,
    shippingLocation: shipping?.location,
    tappedReward: true
    )
    .flatMap { env -> SignalProducer<SubmitApplePayEnvelope, ErrorEnvelope> in

      #if swift(>=2.3)
        guard let checkoutUrl = AppEnvironment.current.apiService.serverConfig.webBaseUrl
        .URLByAppendingPathComponent(env.checkoutUrl)?
        .absoluteString else {
        return .empty
        }
      #else
        guard let checkoutUrl = env.newCheckoutUrl
          .map({ AppEnvironment.current.apiService.serverConfig.webBaseUrl.URLByAppendingPathComponent($0) })?
          .absoluteString else { return .empty }
      #endif

      return AppEnvironment.current.apiService.submitApplePay(
        checkoutUrl: checkoutUrl,
        stripeToken: stripeToken,
        paymentInstrumentName: paymentData.tokenData.paymentMethodData.displayName ?? "",
        paymentNetwork: paymentData.tokenData.paymentMethodData.network ?? "",
        transactionIdentifier: paymentData.tokenData.transactionIdentifier
      )
  }
}

private func navigationTitle(forProject project: Project, reward: Reward) -> String {

  guard project.personalization.isBacking != true else {
    return reward == Reward.noReward
      ? localizedString(key: "Manage_your_pledge", defaultValue: "Manage your pledge")
      : localizedString(key: "Manage_your_reward", defaultValue: "Manage your reward")
  }

  guard reward != Reward.noReward else {
    return localizedString(key: "Make_a_pledge_without_a_reward",
                           defaultValue: "Make a pledge without a reward")
  }

  return Strings.rewards_title_pledge_reward_currency_or_more(
    reward_currency: Format.currency(reward.minimum, country: project.country)
  )
}

private func userIsBacking(reward reward: Reward, inProject project: Project) -> Bool {
  return project.personalization.backing?.rewardId == reward.id
    || project.personalization.backing?.reward?.id == reward.id
}

private func minAndMaxPledgeAmount(forProject project: Project, reward: Reward) -> (min: Int, max: Int) {

  return (
    min: (reward == Reward.noReward ? (project.country.minPledge ?? 1) : reward.minimum),
    max: project.country.maxPledge ?? 10_000
  )
}
