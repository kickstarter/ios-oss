// swiftlint:disable file_length
import KsApi
import PassKit
import Prelude
import ReactiveCocoa
import Result

public protocol RewardPledgeViewModelInputs {
  /// Call when the apple pay button is tapped.
  func applePayButtonTapped()

  /// Call when the cancel pledge button is tapped.
  func cancelPledgeButtonTapped()

  /// Call when the change payment method button is tapped.
  func changePaymentMethodButtonTapped()

  /// Call when the shipping picker has notified us that shipping has changed.
  func change(shippingRule shippingRule: ShippingRule)

  /// Call when the close button is tapped.
  func closeButtonTapped()

  /// Call with the project and reward provided to the view.
  func configureWith(project project: Project, reward: Reward, applePayCapable: Bool)

  /// Call when the "continue to payments" button is tapped.
  func continueToPaymentsButtonTapped()

  /// Call when the "different payment method" button is tapped.
  func differentPaymentMethodButtonTapped()

  /// Call when the disclaimer button is tapped.
  func disclaimerButtonTapped()

  /// Call when anything is tapped that should expand the reward's description.
  func expandDescriptionTapped()

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

  /// Call when the update pledge button is tapped.
  func updatePledgeButtonTapped()

  /// Call when the user starts a session.
  func userSessionStarted()

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol RewardPledgeViewModelOutputs {
  /// Emits a boolean that determines if the apple pay button is hidden.
  var applePayButtonHidden: Signal<Bool, NoError> { get }

  /// Emits a boolean that determines if the cancel pledge button should be hidden.
  var cancelPledgeButtonHidden: Signal<Bool, NoError> { get }

  /// Emits a boolean that determines if the change method button should be hidden.
  var changePaymentMethodButtonHidden: Signal<Bool, NoError> { get }

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

  /// Emits when the controller should be dismissed.
  var dismissViewController: Signal<(), NoError> { get }

  /// Emits a string to be put into the estimated delivery date label.
  var estimatedDeliveryDateLabelText: Signal<String, NoError> { get }

  /// Emits when the reward description should be expanded.
  var expandRewardDescription: Signal<(), NoError> { get }

  /// Emits a boolean that determines if the fulfillment footer stack view should be hidden.
  var fulfillmentAndShippingFooterStackViewHidden: Signal<Bool, NoError> { get }

  /// Emits when the checkout screen should be shown to the user.
  var goToCheckout: Signal<(NSURLRequest, Project, Reward), NoError> { get }

  /// Emits when the login tout should be shown to the user.
  var goToLoginTout: Signal<(), NoError> { get }

  /// Emits a payment request object that is to be used to present a payment authorization controller.
  var goToPaymentAuthorization: Signal<PKPaymentRequest, NoError> { get }

  /// Emits a project, list of shipping rules, and current selected shipping rule that are to be used to
  /// go to the shipping picker.
  var goToShippingPicker: Signal<(Project, [ShippingRule], ShippingRule), NoError> { get }

  /// Emits when we should go to the thanks screen.
  var goToThanks: Signal<Project, NoError> { get }

  /// Emits when we should go to the trust & safety page.
  var goToTrustAndSafety: Signal<(), NoError> { get }

  /// Emits an array of strings that are to be loaded into the itemization stack view.
  var items: Signal<[String], NoError> { get }

  /// Emits a boolean that determines if the itemization stack view is hidden.
  var itemsContainerHidden: Signal<Bool, NoError> { get }

  /// Emits whether loading overlay view should be hidden.
  var loadingOverlayIsHidden: Signal<Bool, NoError> { get }

  /// Emits a string to be put into the minimum pledge label.
  var minimumLabelText: Signal<String, NoError> { get }

  /// Emits a string for the title of the navigation controller.
  var navigationTitle: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the -or- separator label should be hidden.
  var orLabelHidden: Signal<Bool, NoError> { get }

  /// Emits a string to be put into the currency label.
  var pledgeCurrencyLabelText: Signal<String, NoError> { get }

  /// Emits a bool whether a pledge is loading for the indicator view.
  var pledgeIsLoading: Signal<Bool, NoError> { get }

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

  /// Emits a boolean that determines if the update pledge button should be hidden.
  var updatePledgeButtonHidden: Signal<Bool, NoError> { get }
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
      .switchMap { (project, reward) -> SignalProducer<[ShippingRule], NoError> in
        guard reward != Reward.noReward else {
          return SignalProducer<[ShippingRule], NoError>(value: [])
        }

        return AppEnvironment.current.apiService.fetchRewardShippingRules(
          projectId: project.id, rewardId: reward.id
          )
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

    self.applePayButtonHidden = combineLatest(applePayCapable, project)
      .map(applePayButtonHiddenFor(applePayCapable:project:))

    self.differentPaymentMethodButtonHidden = self.applePayButtonHidden

    self.continueToPaymentsButtonHidden = combineLatest(applePayCapable, project)
      .map { applePayCapable, project in
        !applePayButtonHiddenFor(applePayCapable: applePayCapable, project: project)
          || project.personalization.isBacking == .Some(true)
      }

    self.updatePledgeButtonHidden = projectAndReward
      .map { project, reward in
        project.personalization.isBacking != .Some(true)
    }

    self.cancelPledgeButtonHidden = projectAndReward
      .map { project, reward in !userIsBacking(reward: reward, inProject: project) }

    self.changePaymentMethodButtonHidden = self.cancelPledgeButtonHidden

    self.orLabelHidden = self.cancelPledgeButtonHidden

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
          shipping_cost: Format.currency(
            Int(shippingRule.cost),
            country: project.country,
            omitCurrencyCode: !projectNeedsCurrencyCode(project)
          )
        )
    }

    self.shippingAmountLabelText = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(""),
      shippingAmount
    )

    self.readMoreContainerViewHidden = Signal.merge(
      reward.map { $0 == Reward.noReward },
      self.expandDescriptionTappedProperty.signal.mapConst(true)
    )

    self.itemsContainerHidden = self.readMoreContainerViewHidden.map(negate)

    self.expandRewardDescription = self.expandDescriptionTappedProperty.signal

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
      .map { currencySymbol(forCountry: $0.country).trimmed() }

    let initialPledgeTextFieldText = projectAndReward
      .map { project, reward -> Int in
        guard let backing = project.personalization.backing
          where userIsBacking(reward: reward, inProject: project) else {

            return reward == Reward.noReward
              ? minAndMaxPledgeAmount(forProject: project, reward: reward).min
              : reward.minimum
        }

        return backing.amount - (backing.shippingAmount ?? 0)
    }

    let userEnteredPledgeAmount = Signal.merge(
      initialPledgeTextFieldText,
      self.pledgeTextChangedProperty.signal.map { Int($0) ?? 0 }
      )

    let pledgeTextFieldWhenReturnWithBadAmount = combineLatest(
      userEnteredPledgeAmount,
      projectAndReward.map(minAndMaxPledgeAmount(forProject:reward:))
      )
      .takeWhen(self.pledgeTextFieldDidEndEditingProperty.signal)
      .filter { pledgeAmount, minAndMax in pledgeAmount < minAndMax.0 || pledgeAmount > minAndMax.1 }
      .map { _, minAndMax in minAndMax.0 }

    let pledgeAmount = Signal.merge(
      userEnteredPledgeAmount,
      pledgeTextFieldWhenReturnWithBadAmount
    )

    self.pledgeTextFieldText = Signal.merge(
      initialPledgeTextFieldText,
      pledgeTextFieldWhenReturnWithBadAmount
      )
      .map { String($0) }

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
      // introduce a small delay for this event since the login tout takes a moment to dismiss...
      .ksr_debounce(1, onScheduler: AppEnvironment.current.scheduler)

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

    let isLoading = MutableProperty(false)
    self.pledgeIsLoading = isLoading.signal

    self.loadingOverlayIsHidden = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(true),
      self.pledgeIsLoading.map(negate)
    )

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
        .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
        .on(started: { isLoading.value = true }, terminated: { isLoading.value = false })
        .materialize()
    }

    self.goToTrustAndSafety = self.disclaimerButtonTappedProperty.signal

    let createPledgeEvent = combineLatest(
      projectAndReward,
      pledgeAmount,
      selectedShipping
      )
      .takeWhen(Signal.merge(paymentMethodEventAfterLogin, loggedInUserTappedPaymentMethodButton))
      .map { ($0.0, $0.1, $1, $2) }
      .switchMap { project, reward, amount, shipping in
        createPledge(project: project, reward: reward, amount: amount, shipping: shipping)
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .map { ($0, project, reward) }
          .on(started: { isLoading.value = true }, terminated: { isLoading.value = false })
          .materialize()
    }

    let cancelPledge = projectAndReward
      .takeWhen(self.cancelPledgeButtonTappedProperty.signal)
      .map { project, reward -> (NSURLRequest, Project, Reward)? in
        guard let request = NSURL(string: project.urls.web.project)
          .flatMap({ optionalize($0.URLByAppendingPathComponent("pledge")) })
          .flatMap({ optionalize($0.URLByAppendingPathComponent("destroy")) })
          .flatMap({ optionalize(NSURLRequest(URL: $0)) }) else {
          return nil
        }
        return (request, project, reward)
      }
      .ignoreNil()

    let updatePledgeEvent = combineLatest(
      projectAndReward,
      pledgeAmount,
      selectedShipping
      )
      .takeWhen(self.updatePledgeButtonTappedProperty.signal)
      .map { ($0.0, $0.1, $1, $2) }
      .switchMap { project, reward, amount, shipping in
        updatePledge(project: project, reward: reward, amount: amount, shipping: shipping)
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .map { ($0, project, reward) }
          .on(started: { isLoading.value = true }, terminated: { isLoading.value = false })
          .materialize()
    }

    let changePaymentMethodEvent = projectAndReward
      .takeWhen(self.changePaymentMethodButtonTappedProperty.signal)
      .switchMap { project, reward in
        changePaymentMethod(project: project)
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .map { ($0, project, reward) }
          .on(started: { isLoading.value = true }, terminated: { isLoading.value = false })
          .materialize()
    }

    let completedPledge = Signal.merge(
      updatePledgeEvent.values().filter { request, _, _ in request == nil }.ignoreValues(),
      createApplePayPledgeEvent.values().ignoreValues()
    )

    self.goToThanks = project
      .takeWhen(completedPledge)

    let updatedPledgeNeedsNewCheckout = updatePledgeEvent.values()
      .flatMap { request, project, reward -> SignalProducer<(NSURLRequest, Project, Reward), NoError> in
        guard let request = request else { return .empty }
        return SignalProducer(value: (request, project, reward))
    }

    self.goToCheckout = Signal.merge(
      createPledgeEvent.values(),
      cancelPledge,
      changePaymentMethodEvent.values(),
      updatedPledgeNeedsNewCheckout
    )

    let pledgeErrors = Signal.merge(
      createPledgeEvent.errors(),
      updatePledgeEvent.errors(),
      createApplePayPledgeEvent.errors(),
      changePaymentMethodEvent.errors()
    )

    self.showAlert = pledgeErrors
      .map { $0.errorEnvelope.errorMessages.first }
      .ignoreNil()

    self.titleLabelText = reward
      .map {
        $0 == Reward.noReward
          ? Strings.Id_just_like_to_support_the_project()
          : ($0.title ?? "")
    }

    self.dismissViewController = self.closeButtonTappedProperty.signal

    let projectAndRewardAndPledgeContext = projectAndReward
      .map { project, reward -> (Project, Reward, Koala.PledgeContext) in
        (
          project: project,
          reward: reward,
          pledgeContext: pledgeContext(forProject: project, reward: reward)
        )
    }

    projectAndRewardAndPledgeContext
      .take(1)
      .observeNext {
        AppEnvironment.current.koala.trackSelectedReward(project: $0, reward: $1, pledgeContext: $2)
    }

    projectAndRewardAndPledgeContext
      .takeWhen(self.paymentAuthorizationWillAuthorizeProperty.signal)
      .observeNext {
        AppEnvironment.current.koala.trackShowApplePaySheet(project: $0, reward: $1, pledgeContext: $2)
    }

    projectAndRewardAndPledgeContext
      .takeWhen(self.didAuthorizePaymentProperty.signal)
      .observeNext {
        AppEnvironment.current.koala.trackApplePayAuthorizedPayment(
          project: $0, reward: $1, pledgeContext: $2
        )
    }

    projectAndRewardAndPledgeContext
      .takeWhen(self.stripeTokenAndErrorProperty.signal.filter(isNotNil • first))
      .observeNext {
        AppEnvironment.current.koala.trackStripeTokenCreatedForApplePay(
          project: $0, reward: $1, pledgeContext: $2
        )
    }

    projectAndRewardAndPledgeContext
      .takeWhen(self.stripeTokenAndErrorProperty.signal.filter(isNotNil • second))
      .observeNext {
        AppEnvironment.current.koala.trackStripeTokenErroredForApplePay(
          project: $0, reward: $1, pledgeContext: $2
        )
    }

    let applePaySuccessful = Signal.merge(
      self.paymentAuthorizationWillAuthorizeProperty.signal.mapConst(false),
      self.stripeTokenAndErrorProperty.signal.filter(isNotNil • second).mapConst(false),
      self.stripeTokenAndErrorProperty.signal.filter(isNotNil • first).mapConst(true)
    )

    combineLatest(projectAndRewardAndPledgeContext, applePaySuccessful)
      .takeWhen(self.paymentAuthorizationFinishedProperty.signal)
      .observeNext { projectAndRewardAndPledgeContext, successful in
        let (project, reward, context) = projectAndRewardAndPledgeContext

        if successful {
          AppEnvironment.current.koala.trackApplePayFinished(
            project: project, reward: reward, pledgeContext: context
          )
        } else {
          AppEnvironment.current.koala.trackApplePaySheetCanceled(
            project: project, reward: reward, pledgeContext: context
          )
        }
    }

    projectAndReward
      .observeNext { [weak self] project, reward in
        self?.rewardViewModel.inputs.configureWith(project: project, rewardOrBacking: .left(reward))
        self?.rewardViewModel.inputs.boundStyles()
    }

    projectAndRewardAndPledgeContext
      .takeWhen(self.closeButtonTappedProperty.signal)
      .observeNext {
        AppEnvironment.current.koala.trackClosedReward(project: $0, reward: $1, pledgeContext: $2)
    }

    projectAndRewardAndPledgeContext
      .takeWhen(self.pledgeTextChangedProperty.signal)
      .observeNext { project, reward, context in
        AppEnvironment.current.koala.trackChangedPledgeAmount(
          project, reward: reward, pledgeContext: context
        )
    }

    projectAndRewardAndPledgeContext
      .takeWhen(self.changedShippingRuleProperty.signal)
      .observeNext { project, reward, context in
        AppEnvironment.current.koala.trackSelectedShippingDestination(
          project, reward: reward, pledgeContext: context
        )
    }

    projectAndRewardAndPledgeContext
      .takeWhen(self.expandDescriptionTappedProperty.signal)
      .take(1)
      .observeNext { project, reward, context in
        AppEnvironment.current.koala.trackExpandedRewardDescription(
          reward, project: project, pledgeContext: context
        )
    }

    let continueCheckoutType: Signal<Koala.ClickedRewardPledgeButtonType, NoError> = Signal.merge(
      self.continueToPaymentsButtonTappedProperty.signal.mapConst(.paymentMethods),
      self.applePayButtonTappedProperty.signal.mapConst(.applePay),
      self.differentPaymentMethodButtonTappedProperty.signal.mapConst(.paymentMethods),
      self.updatePledgeButtonTappedProperty.signal.mapConst(.updatePledge),
      self.changePaymentMethodButtonTappedProperty.signal.mapConst(.changePaymentMethod)
    )

    projectAndRewardAndPledgeContext
      .takePairWhen(continueCheckoutType)
      .observeNext { projectAndRewardAndPledgeContext, type in
        let (project, reward, context) = projectAndRewardAndPledgeContext

        AppEnvironment.current.koala.trackClickedRewardPledgeButton(
          project: project,
          reward: reward,
          buttonType: type,
          pageContext: .rewardSelection,
          pledgeContext: context
        )
    }

    projectAndRewardAndPledgeContext
      .takePairWhen(pledgeErrors)
      .observeNext { projectAndRewardAndPledgeContext, pledgeError in
        guard let koalaErrorType = pledgeError.koalaErrorType,
          let errorText = pledgeError.errorEnvelope.errorMessages.first
        else { return }

        let (project, reward, context) = projectAndRewardAndPledgeContext

        AppEnvironment.current.koala.trackClickedRewardPledgeButton(
          project: project,
          reward: reward,
          errorText: errorText,
          errorType: koalaErrorType,
          paymentMethod: nil, /// todo
          pageContext: .rewardSelection,
          pledgeContext: context
        )
    }
  }
  // swiftlint:enable function_body_length

  private let applePayButtonTappedProperty = MutableProperty()
  public func applePayButtonTapped() {
    self.applePayButtonTappedProperty.value = ()
  }

  private let changePaymentMethodButtonTappedProperty = MutableProperty()
  public func changePaymentMethodButtonTapped() {
    self.changePaymentMethodButtonTappedProperty.value = ()
  }

  private let cancelPledgeButtonTappedProperty = MutableProperty()
  public func cancelPledgeButtonTapped() {
    self.cancelPledgeButtonTappedProperty.value = ()
  }

  private let changedShippingRuleProperty = MutableProperty<ShippingRule?>(nil)
  public func change(shippingRule shippingRule: ShippingRule) {
    self.changedShippingRuleProperty.value = shippingRule
  }

  private let closeButtonTappedProperty = MutableProperty()
  public func closeButtonTapped() {
    self.closeButtonTappedProperty.value = ()
  }

  private let projectAndRewardAndApplePayCapableProperty = MutableProperty<(Project, Reward, Bool)?>(nil)
  public func configureWith(project project: Project, reward: Reward, applePayCapable: Bool) {
    self.projectAndRewardAndApplePayCapableProperty.value = (project, reward, applePayCapable)
  }

  private let continueToPaymentsButtonTappedProperty = MutableProperty()
  public func continueToPaymentsButtonTapped() {
    self.continueToPaymentsButtonTappedProperty.value = ()
  }

  private let differentPaymentMethodButtonTappedProperty = MutableProperty()
  public func differentPaymentMethodButtonTapped() {
    self.differentPaymentMethodButtonTappedProperty.value = ()
  }

  private let disclaimerButtonTappedProperty = MutableProperty()
  public func disclaimerButtonTapped() {
    self.disclaimerButtonTappedProperty.value = ()
  }

  private let expandDescriptionTappedProperty = MutableProperty()
  public func expandDescriptionTapped() {
    self.expandDescriptionTappedProperty.value = ()
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

  private let updatePledgeButtonTappedProperty = MutableProperty()
  public func updatePledgeButtonTapped() {
    self.updatePledgeButtonTappedProperty.value = ()
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
  public let dismissViewController: Signal<(), NoError>
  public let estimatedDeliveryDateLabelText: Signal<String, NoError>
  public let expandRewardDescription: Signal<(), NoError>
  public let fulfillmentAndShippingFooterStackViewHidden: Signal<Bool, NoError>
  public let goToCheckout: Signal<(NSURLRequest, Project, Reward), NoError>
  public let goToLoginTout: Signal<(), NoError>
  public let goToPaymentAuthorization: Signal<PKPaymentRequest, NoError>
  public let goToShippingPicker: Signal<(Project, [ShippingRule], ShippingRule), NoError>
  public let goToThanks: Signal<Project, NoError>
  public let goToTrustAndSafety: Signal<(), NoError>
  public var items: Signal<[String], NoError> {
    return self.rewardViewModel.outputs.items
  }
  public let itemsContainerHidden: Signal<Bool, NoError>
  public let loadingOverlayIsHidden: Signal<Bool, NoError>
  public var minimumLabelText: Signal<String, NoError> {
    return self.rewardViewModel.outputs.minimumLabelText
  }
  public let navigationTitle: Signal<String, NoError>
  public let orLabelHidden: Signal<Bool, NoError>
  public let pledgeCurrencyLabelText: Signal<String, NoError>
  public let pledgeIsLoading: Signal<Bool, NoError>
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
  public let titleLabelText: Signal<String, NoError>

  public let updatePledgeButtonHidden: Signal<Bool, NoError>
  public let changePaymentMethodButtonHidden: Signal<Bool, NoError>
  public let cancelPledgeButtonHidden: Signal<Bool, NoError>

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

private func projectNeedsCurrencyCode(project: Project) -> Bool {
  return (project.country.countryCode != "US" || AppEnvironment.current.config?.countryCode != "US")
    && project.country.currencySymbol == "$"
}

private func backingError(forProject project: Project, amount: Int, reward: Reward?) -> PledgeError? {

  let (min, max) = minAndMaxPledgeAmount(forProject: project, reward: reward)

  guard amount >= min else {
    let message = Strings.Please_enter_an_amount_of_amount_or_more(
      amount: Format.currency(min, country: project.country)
    )

    return .minimumAmount(.init(errorMessages: [message], ksrCode: nil, httpCode: 400, exception: nil))
  }

  guard amount <= max else {
    let message = Strings.Please_enter_an_amount_of_amount_or_less(
      amount: Format.currency(max, country: project.country)
    )

    return .maximumAmount(.init(errorMessages: [message], ksrCode: nil, httpCode: 400, exception: nil))
  }

  return nil
}

private func createPledge(
  project project: Project,
          reward: Reward?,
          amount: Int,
          shipping: ShippingRule?) -> SignalProducer<NSURLRequest, PledgeError> {

  if let error = backingError(forProject: project, amount: amount, reward: reward) {
    return SignalProducer(error: error)
  }

  let totalAmount = Double(amount) + (shipping?.cost ?? 0)

  return AppEnvironment.current.apiService.createPledge(
    project: project,
    amount: totalAmount,
    reward: reward,
    shippingLocation: shipping?.location,
    tappedReward: true
    )
    .mapError { PledgeError.other($0) }
    .flatMap { env -> SignalProducer<NSURLRequest, PledgeError> in

      #if swift(>=2.3)
        guard let url = AppEnvironment.current.apiService.serverConfig.webBaseUrl
        .URLByAppendingPathComponent(env.newCheckoutUrl)
      #else
        guard let url = env.newCheckoutUrl
          .map({ AppEnvironment.current.apiService.serverConfig.webBaseUrl.URLByAppendingPathComponent($0) })
        else { return .empty }
      #endif

      let request = NSURLRequest(URL: url)
      return SignalProducer(value: request)
  }
}

private func updatePledge(
  project project: Project,
          reward: Reward?,
          amount: Int,
          shipping: ShippingRule?) -> SignalProducer<NSURLRequest?, PledgeError> {

  if let error = backingError(forProject: project, amount: amount, reward: reward) {
    return SignalProducer(error: error)
  }

  let totalAmount = Double(amount) + (shipping?.cost ?? 0)

  return AppEnvironment.current.apiService.updatePledge(
    project: project,
    amount: totalAmount,
    reward: reward,
    shippingLocation: shipping?.location,
    tappedReward: true
    )
    .mapError { PledgeError.other($0) }
    .flatMap { env -> SignalProducer<NSURLRequest?, PledgeError> in

      #if swift(>=2.3)
        let url = AppEnvironment.current.apiService.serverConfig.webBaseUrl
          .URLByAppendingPathComponent(env.newCheckoutUrl)
      #else
        let url = env.newCheckoutUrl
          .map({ AppEnvironment.current.apiService.serverConfig.webBaseUrl.URLByAppendingPathComponent($0) })
      #endif

      let request = url.map(NSURLRequest.init(URL:))
      return SignalProducer(value: request)
  }
}

private func createApplePayPledge(
  project project: Project,
  reward: Reward?,
  amount: Int,
  shipping: ShippingRule?,
  paymentData: PaymentData,
  stripeToken: String) -> SignalProducer<SubmitApplePayEnvelope, PledgeError> {

  if let error = backingError(forProject: project, amount: amount, reward: reward) {
    return SignalProducer(error: error)
  }

  let totalAmount = Double(amount) + (shipping?.cost ?? 0)

  return AppEnvironment.current.apiService.createPledge(
    project: project,
    amount: totalAmount,
    reward: reward,
    shippingLocation: shipping?.location,
    tappedReward: true
    )
    .mapError { PledgeError.other($0) }
    .flatMap { env -> SignalProducer<SubmitApplePayEnvelope, PledgeError> in

      #if swift(>=2.3)
        guard let checkoutUrl = AppEnvironment.current.apiService.serverConfig.webBaseUrl
        .URLByAppendingPathComponent(env.checkoutUrl)?
        .absoluteString else {
        return .empty
        }
      #else
        guard let checkoutUrl = env.checkoutUrl
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
        .mapError { PledgeError.other($0) }
  }
}

private func changePaymentMethod(project project: Project) -> SignalProducer<NSURLRequest, PledgeError> {

    return AppEnvironment.current.apiService.changePaymentMethod(project: project)
      .mapError { PledgeError.other($0) }
      .map { env in
        env.newCheckoutUrl
          .flatMap(NSURL.init(string:))
          .flatMap(NSURLRequest.init(URL:))
      }
      .ignoreNil()
}

private func navigationTitle(forProject project: Project, reward: Reward) -> String {

  guard project.personalization.isBacking != true else {
    if reward == Reward.noReward {
      return Strings.Manage_your_pledge()
    } else if userIsBacking(reward: reward, inProject: project) {
      return Strings.Manage_your_reward()
    } else {
      return Strings.Select_this_reward_instead()
    }
  }

  guard reward != Reward.noReward else {
    return Strings.Make_a_pledge_without_a_reward()
  }

  return Strings.rewards_title_pledge_reward_currency_or_more(
    reward_currency: Format.currency(reward.minimum, country: project.country)
  )
}

private enum PledgeError: ErrorType {
  case maximumAmount(ErrorEnvelope)
  case minimumAmount(ErrorEnvelope)
  case other(ErrorEnvelope)

  private var errorEnvelope: ErrorEnvelope {
    switch self {
    case let .maximumAmount(env): return env
    case let .minimumAmount(env): return env
    case let .other(env):         return env
    }
  }

  private var koalaErrorType: Koala.ErroredRewardPledgeButtonClickType? {
    switch self {
    case .maximumAmount:  return .maximumAmount
    case .minimumAmount:  return .minimumAmount
    case .other:          return nil
    }
  }
}

private func applePayButtonHiddenFor(applePayCapable applePayCapable: Bool, project: Project) -> Bool {
  return !applePayCapable
    || project.personalization.isBacking == .Some(true)
    || AppEnvironment.current.config?.applePayCountries.indexOf(project.country.countryCode) == nil
}
