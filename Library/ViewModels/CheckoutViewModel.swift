// swiftlint:disable file_length
import Argo
import KsApi
import PassKit
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol CheckoutViewModelInputs {
  /// Call when the back button is tapped.
  func cancelButtonTapped()

  /// Call with the data passed to the view.
  func configureWith(initialRequest initialRequest: NSURLRequest,
                                    project: Project,
                                    reward: Reward,
                                    applePayCapable: Bool)

  /// Call when the failure alert OK button is tapped.
  func failureAlertButtonTapped()

  /// Call from the payment authorization method when a payment has been authorized.
  func paymentAuthorization(didAuthorizePayment payment: PaymentData)

  /// Call from the payment authorization method when it finishes.
  func paymentAuthorizationDidFinish()

  /// Call from the payment authorization delegate method.
  func paymentAuthorizationWillAuthorizePayment()

  /// Call when the webview decides whether to load a request.
  func shouldStartLoad(withRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool

  /// Call from the Stripe callback method once a stripe token has been created.
  func stripeCreatedToken(stripeToken stripeToken: String?, error: NSError?) -> PKPaymentAuthorizationStatus

  /// Call when a user session has started.
  func userSessionStarted()

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol CheckoutViewModelOutputs {
  /// Emits when the login tout should be closed.
  var closeLoginTout: Signal<Void, NoError> { get }

  /// Emits a string that should be evaluated as javascript in the webview.
  var evaluateJavascript: Signal<String, NoError> { get }

  /// Emits a payment request object that is to be used to present a payment authorization controller.
  var goToPaymentAuthorization: Signal<PKPaymentRequest, NoError> { get }

  /// Emits when we should open a safari browser with the URL.
  var goToSafariBrowser: Signal<NSURL, NoError> { get }

  /// Emits when the thanks screen should be loaded.
  var goToThanks: Signal<Project, NoError> { get }

  /// Emits when the web modal should be loaded.
  var goToWebModal: Signal<NSURLRequest, NoError> { get }

  /// Emits when the login tout should be opened.
  var openLoginTout: Signal<Void, NoError> { get }

  /// Emits when the view controller should be popped.
  var popViewController: Signal<Void, NoError> { get }

  /// Emits a string to be used to set the Stripe library's apple merchant identifier.
  var setStripeAppleMerchantIdentifier: Signal<String, NoError> { get }

  /// Emits a string to be used to set the Stripe library's publishable key.
  var setStripePublishableKey: Signal<String, NoError> { get }

  /// Emits when an alert should be shown.
  var showAlert: Signal<String, NoError> { get }

  /// Emits a request that should be loaded into the webview.
  var webViewLoadRequest: Signal<NSURLRequest, NoError> { get }
}

public protocol CheckoutViewModelType: CheckoutViewModelInputs, CheckoutViewModelOutputs {
  var inputs: CheckoutViewModelInputs { get }
  var outputs: CheckoutViewModelOutputs { get }
}

public final class CheckoutViewModel: CheckoutViewModelType {

  private let checkoutRacingViewModel: CheckoutRacingViewModelType = CheckoutRacingViewModel()

  // swiftlint:disable function_body_length
  // swiftlint:disable cyclomatic_complexity
  public init() {
    let configData = self.configDataProperty.signal.ignoreNil()
      .takeWhen(self.viewDidLoadProperty.signal)

    let userSessionStarted = self.userSessionStartedProperty.signal

    let applePayCapable = configData.map { $0.applePayCapable }
    let initialRequest = configData.map { $0.initialRequest }
    let project = configData.map { $0.project }

    let requestData = self.shouldStartLoadProperty.signal.ignoreNil()
      .map { request, navigationType -> RequestData in
        let navigation = Navigation.match(request)

        let shouldStartLoad = isLoadableByWebView(request: request, navigation: navigation)

        return RequestData(request: request,
          navigation: navigation,
          shouldStartLoad: shouldStartLoad,
          webViewNavigationType: navigationType)
    }

    let projectRequest = requestData
      .filter { requestData in
        if let navigation = requestData.navigation,
          case .project(_, .root, _) = navigation { return true }
        return false
      }
      .ignoreValues()

    let webViewRequest = requestData
      .filter { requestData in
        // Allow through requests that the web view can load once they're prepared.
        !requestData.shouldStartLoad && isNavigationLoadedByWebView(navigation: requestData.navigation)
      }
      .map { $0.request }

    self.goToPaymentAuthorization = requestData
      .filter { $0.webViewNavigationType == .LinkClicked }
      .map { requestData -> String? in
        guard case let (.checkout(_, .payments(.applePay(payload))))? = requestData.navigation else {
          return nil
        }
        return payload
      }
      .map { $0.flatMap(paymentRequest(fromBase64Payload:)) }
      .ignoreNil()

    let modalRequestOrSafariRequest = requestData
      .filter(isModal)
      .map { requestData -> Either<NSURLRequest, NSURLRequest> in
        if let navigation = requestData.navigation,
          case .project(_, .pledge(.bigPrint), _) = navigation { return Either.left(requestData.request) }
        return Either.right(requestData.request)
    }

    let retryAfterSessionStartedRequest = requestData
      .combinePrevious()
      .takeWhen(userSessionStarted)
      .map { previous, _ in previous.request }

    let thanksRequestOrRacingRequest = requestData
      .map { requestData -> Either<NSURLRequest, NSURLRequest>? in
        guard let navigation = requestData.navigation else { return nil }
        if case .project(_, .checkout(_, .thanks(let racing)), _) = navigation {
          guard let r = racing else { return Either.left(requestData.request) }
          return r ? Either.right(requestData.request) : Either.left(requestData.request)
        }
        return nil
      }
      .ignoreNil()

    let thanksRequest = thanksRequestOrRacingRequest
      .map { $0.left }
      .ignoreNil()
      .ignoreValues()

    let racingRequest = thanksRequestOrRacingRequest
      .map { $0.right }
      .ignoreNil()

    self.closeLoginTout = userSessionStarted

    self.goToSafariBrowser = modalRequestOrSafariRequest
      .map { $0.right?.URL }
      .ignoreNil()

    let thanksRequestOrRacingSuccessful = Signal.merge(
      thanksRequest,
      self.checkoutRacingViewModel.outputs.goToThanks
    )

    self.goToThanks = project
      .takeWhen(thanksRequestOrRacingSuccessful)

    self.goToWebModal = modalRequestOrSafariRequest
      .map { $0.left }
      .ignoreNil()

    self.openLoginTout = requestData
      .filter { $0.navigation == .signup }
      .ignoreValues()

    let checkoutCancelled = Signal.merge(
      projectRequest,
      self.cancelButtonTappedProperty.signal
      )

    self.popViewController = Signal.merge(checkoutCancelled, self.failureAlertButtonTappedProperty.signal)

    self.shouldStartLoadResponseProperty <~ requestData
      .map { $0.shouldStartLoad }

    self.webViewLoadRequest = combineLatest(
      Signal.merge(initialRequest, retryAfterSessionStartedRequest, webViewRequest),
      applePayCapable
      )
      .map(prepared(request:applePayCapable:))

    let stripeToken = self.stripeTokenAndErrorProperty.signal.map(first).ignoreNil()

    self.paymentAuthorizationStatusProperty <~ self.stripeTokenAndErrorProperty.signal
      .map { _, error in error == nil ? .Success : .Failure }

    self.evaluateJavascript = self.didAuthorizePaymentProperty.signal.ignoreNil()
      .takePairWhen(stripeToken)
      .map(applePayCheckoutNextJS(forPaymentData:stripeToken:))
      .ignoreNil()

    self.setStripeAppleMerchantIdentifier = applePayCapable
      .filter(isTrue)
      .mapConst(PKPaymentAuthorizationViewController.merchantIdentifier)

    self.setStripePublishableKey = applePayCapable
      .filter(isTrue)
      .map { _ in AppEnvironment.current.config?.stripePublishableKey }
      .ignoreNil()

    racingRequest
      .observeNext { [weak self] request in
        guard let url = request.URL?.URLByDeletingLastPathComponent else { return }
        self?.checkoutRacingViewModel.inputs.configureWith(url: url)
    }

    configData
      .takeWhen(self.paymentAuthorizationWillAuthorizeProperty.signal)
      .observeNext {
        AppEnvironment.current.koala.trackShowApplePaySheet(
          project: $0.project,
          reward: $0.reward,
          pledgeContext: $0.pledgeContext
        )
    }

    configData
      .takeWhen(self.didAuthorizePaymentProperty.signal)
      .observeNext {
        AppEnvironment.current.koala.trackApplePayAuthorizedPayment(
          project: $0.project,
          reward: $0.reward,
          pledgeContext: $0.pledgeContext
        )
    }

    configData
      .takeWhen(self.stripeTokenAndErrorProperty.signal.filter(isNotNil • first))
      .observeNext {
        AppEnvironment.current.koala.trackStripeTokenCreatedForApplePay(
          project: $0.project,
          reward: $0.reward,
          pledgeContext: $0.pledgeContext
        )
    }

    configData
      .takeWhen(self.stripeTokenAndErrorProperty.signal.filter(isNotNil • second))
      .observeNext {
        AppEnvironment.current.koala.trackStripeTokenErroredForApplePay(
          project: $0.project,
          reward: $0.reward,
          pledgeContext: $0.pledgeContext
        )
    }

    let applePaySuccessful = Signal.merge(
      self.paymentAuthorizationWillAuthorizeProperty.signal.mapConst(false),
      self.didAuthorizePaymentProperty.signal.mapConst(true)
    )

    combineLatest(configData, applePaySuccessful)
      .takeWhen(self.paymentAuthorizationFinishedProperty.signal)
      .observeNext { configData, successful in

        if successful {
          AppEnvironment.current.koala.trackApplePayFinished(
            project: configData.project,
            reward: configData.reward,
            pledgeContext: configData.pledgeContext
          )
        } else {
          AppEnvironment.current.koala.trackApplePaySheetCanceled(
            project: configData.project,
            reward: configData.reward,
            pledgeContext: configData.pledgeContext
          )
        }
    }

    configData
      .takeWhen(checkoutCancelled)
      .observeNext {
        AppEnvironment.current.koala.trackCheckoutCancel(
          project: $0.project,
          reward: $0.reward,
          pledgeContext: $0.pledgeContext
        )
    }
  }
  // swiftlint:enable cyclomatic_complexity
  // swiftlint:enable function_body_length

  private let cancelButtonTappedProperty = MutableProperty()
  public func cancelButtonTapped() { self.cancelButtonTappedProperty.value = () }

  private let configDataProperty = MutableProperty<ConfigData?>(nil)
  public func configureWith(initialRequest initialRequest: NSURLRequest,
                                           project: Project,
                                           reward: Reward,
                                           applePayCapable: Bool) {

    self.configDataProperty.value = ConfigData(initialRequest: initialRequest,
                                               project: project,
                                               reward: reward,
                                               applePayCapable: applePayCapable)
  }

  private let failureAlertButtonTappedProperty = MutableProperty()
  public func failureAlertButtonTapped() { self.failureAlertButtonTappedProperty.value = () }

  private let didAuthorizePaymentProperty = MutableProperty<PaymentData?>(nil)
  public func paymentAuthorization(didAuthorizePayment payment: PaymentData) {
    self.didAuthorizePaymentProperty.value = payment
  }

  private let paymentAuthorizationFinishedProperty = MutableProperty()
  public func paymentAuthorizationDidFinish() {
    self.paymentAuthorizationFinishedProperty.value = ()
  }

  private let paymentAuthorizationWillAuthorizeProperty = MutableProperty()
  public func paymentAuthorizationWillAuthorizePayment() {
    self.paymentAuthorizationWillAuthorizeProperty.value = ()
  }

  private let shouldStartLoadProperty = MutableProperty<(NSURLRequest, UIWebViewNavigationType)?>(nil)
  private let shouldStartLoadResponseProperty = MutableProperty(false)
  public func shouldStartLoad(withRequest request: NSURLRequest,
                                          navigationType: UIWebViewNavigationType) -> Bool {
    self.shouldStartLoadProperty.value = (request, navigationType)
    return self.shouldStartLoadResponseProperty.value
  }

  private let stripeTokenAndErrorProperty = MutableProperty(String?.None, NSError?.None)
  private let paymentAuthorizationStatusProperty = MutableProperty(PKPaymentAuthorizationStatus.Failure)
  public func stripeCreatedToken(stripeToken stripeToken: String?, error: NSError?)
    -> PKPaymentAuthorizationStatus {

      self.stripeTokenAndErrorProperty.value = (stripeToken, error)
      return self.paymentAuthorizationStatusProperty.value
  }

  private let userSessionStartedProperty = MutableProperty()
  public func userSessionStarted() { self.userSessionStartedProperty.value = () }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let closeLoginTout: Signal<Void, NoError>
  public let evaluateJavascript: Signal<String, NoError>
  public let goToPaymentAuthorization: Signal<PKPaymentRequest, NoError>
  public let goToSafariBrowser: Signal<NSURL, NoError>
  public let goToThanks: Signal<Project, NoError>
  public let goToWebModal: Signal<NSURLRequest, NoError>
  public let openLoginTout: Signal<Void, NoError>
  public let popViewController: Signal<Void, NoError>
  public let setStripeAppleMerchantIdentifier: Signal<String, NoError>
  public let setStripePublishableKey: Signal<String, NoError>
  public var showAlert: Signal<String, NoError> {
    return self.checkoutRacingViewModel.outputs.showAlert
  }
  public let webViewLoadRequest: Signal<NSURLRequest, NoError>

  public var inputs: CheckoutViewModelInputs { return self }
  public var outputs: CheckoutViewModelOutputs { return self }
}

private func isLoadableByWebView(request request: NSURLRequest, navigation: Navigation?) -> Bool {
  let preparedWebViewRequest = isNavigationLoadedByWebView(navigation: navigation)
    && AppEnvironment.current.apiService.isPrepared(request: request)
  return preparedWebViewRequest || isStripeRequest(request: request)
}

private func isModal(requestData requestData: RequestData) -> Bool {
  guard let url = requestData.request.URL else { return false }
  guard let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else { return false }
  guard let queryItems = components.queryItems else { return false }

  return queryItems.filter { $0.name == "modal" }.first?.value == "true"
}

private func isNavigationLoadedByWebView(navigation navigation: Navigation?) -> Bool {
  guard let nav = navigation else { return false }
  switch nav {
  case
    .checkout(_, .payments(.new)),
    .checkout(_, .payments(.root)),
    .checkout(_, .payments(.useStoredCard)),
    .project(_, .pledge(.changeMethod), _),
    .project(_, .pledge(.destroy), _),
    .project(_, .pledge(.edit), _),
    .project(_, .pledge(.new), _),
    .project(_, .pledge(.root), _):
    return true
  default:
    return false
  }
}

private func isStripeRequest(request request: NSURLRequest) -> Bool {
  return request.URL?.host?.hasSuffix("stripe.com") == true
}

private func applePayCheckoutNextJS(forPaymentData paymentData: PaymentData, stripeToken: String)
  -> String? {

  let tokenData = paymentData.tokenData

  let json: [String:[String:String]] = [
    "apple_pay_token": [
      "transaction_identifier": tokenData.transactionIdentifier,
      "payment_network": tokenData.paymentMethodData.network,
      "payment_instrument_name": tokenData.paymentMethodData.displayName
      ].compact(),
    "stripe_token": [
      "id": stripeToken
    ]
  ]

  return (try? NSJSONSerialization.dataWithJSONObject(json, options: []))
    .flatMap { String(data: $0, encoding: NSUTF8StringEncoding) }
    .map { json in "window.checkout_apple_pay_next(\(json));" }
}

private func paymentRequest(fromBase64Payload payload: String) -> PKPaymentRequest? {

  return NSData(base64EncodedString: payload, options: [])
    .flatMap { try? NSJSONSerialization.JSONObjectWithData($0, options: []) }
    .flatMap { (decode($0) as Decoded<PKPaymentRequest>).value }
}

private func prepared(request baseRequest: NSURLRequest, applePayCapable: Bool) -> NSURLRequest {

  var applePayHeader: [String:String] = [:]
  applePayHeader["Kickstarter-Apple-Pay"] = applePayCapable ? "1" : nil

  guard let request = AppEnvironment.current.apiService.preparedRequest(forRequest: baseRequest).mutableCopy()
    as? NSMutableURLRequest else {
      return baseRequest
  }

  request.allHTTPHeaderFields = (request.allHTTPHeaderFields ?? [:]).withAllValuesFrom(applePayHeader)

  return request
}

private struct ConfigData {
  private let initialRequest: NSURLRequest
  private let project: Project
  private let reward: Reward
  private let applePayCapable: Bool

  private var pledgeContext: Koala.PledgeContext {
    return Library.pledgeContext(forProject: self.project, reward: self.reward)
  }
}

private struct RequestData {
  private let request: NSURLRequest
  private let navigation: Navigation?
  private let shouldStartLoad: Bool
  private let webViewNavigationType: UIWebViewNavigationType
}
