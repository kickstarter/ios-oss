import KsApi
import Library
import PassKit
import Prelude
import ReactiveCocoa
import SafariServices
import Stripe
import UIKit

internal final class CheckoutViewController: DeprecatedWebViewController {
  private weak var loginToutViewController: UIViewController? = nil
  private let viewModel: CheckoutViewModelType = CheckoutViewModel()

  internal static func configuredWith(initialRequest initialRequest: NSURLRequest,
                                                     project: Project,
                                                     reward: Reward) -> CheckoutViewController {

      let vc = Storyboard.Checkout.instantiate(CheckoutViewController)
      vc.viewModel.inputs.configureWith(
        initialRequest: initialRequest,
        project: project,
        reward: reward,
        applePayCapable: PKPaymentAuthorizationViewController.applePayCapable()
      )
      return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem.leftBarButtonItem =
      UIBarButtonItem(title: Strings.general_navigation_buttons_cancel(),
                      style: .Plain,
                      target: self,
                      action: #selector(cancelButtonTapped))

    self.viewModel.inputs.viewDidLoad()
  }

  // swiftlint:disable function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.closeLoginTout
      .observeForControllerAction()
      .observeNext { [weak self] _ in self?.closeLoginTout() }

    self.viewModel.outputs.evaluateJavascript
      .observeForControllerAction()
      .observeNext { [weak self] js in
        self?.webView.stringByEvaluatingJavaScriptFromString(js)
    }

    self.viewModel.outputs.setStripePublishableKey
      .observeForUI()
      .observeNext { STPPaymentConfiguration.sharedConfiguration().publishableKey = $0 }

    self.viewModel.outputs.setStripeAppleMerchantIdentifier
      .observeForUI()
      .observeNext { STPPaymentConfiguration.sharedConfiguration().appleMerchantIdentifier = $0 }

    self.viewModel.outputs.goToSafariBrowser
      .observeForControllerAction()
      .observeNext { [weak self] url in self?.goToSafariBrowser(url: url) }

    self.viewModel.outputs.goToThanks
      .observeForControllerAction()
      .observeNext { [weak self] project in self?.goToThanks(project: project) }

    self.viewModel.outputs.goToWebModal
      .observeForControllerAction()
      .observeNext { [weak self] request in self?.goToWebModal(request: request) }

    self.viewModel.outputs.openLoginTout
      .observeForControllerAction()
      .observeNext { [weak self] _ in self?.openLoginTout() }

    self.viewModel.outputs.popViewController
      .observeForControllerAction()
      .observeNext { [weak self] _ in self?.popViewController() }

    self.viewModel.outputs.showAlert
      .observeForControllerAction()
      .observeNext { [weak self] message in self?.showAlert(message: message) }

    self.viewModel.outputs.webViewLoadRequest
      .observeForControllerAction()
      .observeNext { [weak self] request in
        self?.webView.loadRequest(request)
    }

    self.viewModel.outputs.goToPaymentAuthorization
      .observeForControllerAction()
      .observeNext { [weak self] in self?.goToPaymentAuthorization(request: $0) }

    self.viewModel.outputs.dismissViewController
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.dismissViewControllerAnimated(true, completion: nil)
    }

    NSNotificationCenter.defaultCenter()
      .addObserverForName(CurrentUserNotifications.sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }
  }
  // swiftlint:disable function_body_length

  internal func webView(webView: UIWebView,
                        shouldStartLoadWithRequest request: NSURLRequest,
                        navigationType: UIWebViewNavigationType) -> Bool {
    return self.viewModel.inputs.shouldStartLoad(withRequest: request, navigationType: navigationType)
  }

  @objc private func cancelButtonTapped() {
    self.viewModel.inputs.cancelButtonTapped()
  }

  private func closeLoginTout() {
    self.loginToutViewController?.dismissViewControllerAnimated(true, completion: nil)
  }

  private func goToPaymentAuthorization(request request: PKPaymentRequest) {
    let vc = PKPaymentAuthorizationViewController(paymentRequest: request)
    vc.delegate = self
    self.presentViewController(vc, animated: true, completion: nil)
  }

  private func goToSafariBrowser(url url: NSURL) {
    let controller = SFSafariViewController(URL: url)
    controller.modalPresentationStyle = .OverFullScreen
    self.presentViewController(controller, animated: true, completion: nil)
  }

  private func goToThanks(project project: Project) {
    let thanksVC = ThanksViewController.configuredWith(project: project)
    let stack = self.navigationController?.viewControllers
    guard let root = stack?.first else {
      assertionFailure("Unable to find root view controller!")
      return
    }
    self.navigationController?.setViewControllers([root, thanksVC], animated: true)
  }

  private func goToWebModal(request request: NSURLRequest) {
    let vc = WebModalViewController.configuredWith(request: request)
    let nav = UINavigationController(rootViewController: vc)
    self.presentViewController(nav, animated: true, completion: nil)
  }

  private func openLoginTout() {
    let vc = LoginToutViewController.configuredWith(loginIntent: .backProject)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .FormSheet

    self.presentViewController(nav, animated: true, completion: nil)
  }

  private func popViewController() {
    self.navigationController?.popToRootViewControllerAnimated(true)
  }

  private func showAlert(message message: String) {
    self.presentViewController(
      UIAlertController.alert(
        message: message,
        handler: { [weak self] _ in
          self?.viewModel.inputs.failureAlertButtonTapped()
        }
      ),
      animated: true,
      completion: nil
    )
  }
}

extension CheckoutViewController: PKPaymentAuthorizationViewControllerDelegate {

  internal func paymentAuthorizationViewControllerWillAuthorizePayment(
    controller: PKPaymentAuthorizationViewController) {
    self.viewModel.inputs.paymentAuthorizationWillAuthorizePayment()
  }

  internal func paymentAuthorizationViewController(
    controller: PKPaymentAuthorizationViewController,
    didAuthorizePayment payment: PKPayment,
                        completion: (PKPaymentAuthorizationStatus) -> Void) {

    self.viewModel.inputs.paymentAuthorization(didAuthorizePayment: .init(payment: payment))

    STPAPIClient.sharedClient().createTokenWithPayment(payment) { [weak self] token, error in
      if let status = self?.viewModel.inputs.stripeCreatedToken(stripeToken: token?.tokenId, error: error) {
        completion(status)
      } else {
        completion(.Failure)
      }
    }
  }

  internal func paymentAuthorizationViewControllerDidFinish(
    controller: PKPaymentAuthorizationViewController) {

    controller.dismissViewControllerAnimated(true) {
      self.viewModel.inputs.paymentAuthorizationDidFinish()
    }
  }
}
