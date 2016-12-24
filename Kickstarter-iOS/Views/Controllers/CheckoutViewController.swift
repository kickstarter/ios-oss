import KsApi
import Library
import PassKit
import Prelude
import ReactiveSwift
import SafariServices
import Stripe
import UIKit

internal final class CheckoutViewController: DeprecatedWebViewController {
  fileprivate weak var loginToutViewController: UIViewController? = nil
  fileprivate let viewModel: CheckoutViewModelType = CheckoutViewModel()

  internal static func configuredWith(initialRequest: URLRequest,
                                                     project: Project,
                                                     reward: Reward) -> CheckoutViewController {

      let vc = Storyboard.Checkout.instantiate(CheckoutViewController.self)
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
                      style: .plain,
                      target: self,
                      action: #selector(cancelButtonTapped))

    self.viewModel.inputs.viewDidLoad()
  }

  // swiftlint:disable function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.closeLoginTout
      .observeForControllerAction()
      .observeValues { [weak self] _ in self?.closeLoginTout() }

    self.viewModel.outputs.evaluateJavascript
      .observeForControllerAction()
      .observeValues { [weak self] js in
        self?.webView.stringByEvaluatingJavaScript(from: js)
    }

    self.viewModel.outputs.setStripePublishableKey
      .observeForUI()
      .observeValues { STPPaymentConfiguration.shared().publishableKey = $0 }

    self.viewModel.outputs.setStripeAppleMerchantIdentifier
      .observeForUI()
      .observeValues { STPPaymentConfiguration.shared().appleMerchantIdentifier = $0 }

    self.viewModel.outputs.goToSafariBrowser
      .observeForControllerAction()
      .observeValues { [weak self] url in self?.goToSafariBrowser(url: url) }

    self.viewModel.outputs.goToThanks
      .observeForControllerAction()
      .observeValues { [weak self] project in self?.goToThanks(project: project) }

    self.viewModel.outputs.goToWebModal
      .observeForControllerAction()
      .observeValues { [weak self] request in self?.goToWebModal(request: request) }

    self.viewModel.outputs.openLoginTout
      .observeForControllerAction()
      .observeValues { [weak self] _ in self?.openLoginTout() }

    self.viewModel.outputs.popViewController
      .observeForControllerAction()
      .observeValues { [weak self] _ in self?.popViewController() }

    self.viewModel.outputs.showAlert
      .observeForControllerAction()
      .observeValues { [weak self] message in self?.showAlert(message: message) }

    self.viewModel.outputs.webViewLoadRequest
      .observeForControllerAction()
      .observeValues { [weak self] request in
        self?.webView.loadRequest(request)
    }

    self.viewModel.outputs.goToPaymentAuthorization
      .observeForControllerAction()
      .observeValues { [weak self] in self?.goToPaymentAuthorization(request: $0) }

    self.viewModel.outputs.dismissViewController
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.dismiss(animated: true, completion: nil)
    }

    NotificationCenter.default
      .addObserver(forName: NSNotification.Name(rawValue: CurrentUserNotifications.sessionStarted), object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }
  }
  // swiftlint:disable function_body_length

  internal func webView(_ webView: UIWebView,
                        shouldStartLoadWithRequest request: URLRequest,
                        navigationType: UIWebViewNavigationType) -> Bool {
    return self.viewModel.inputs.shouldStartLoad(withRequest: request, navigationType: navigationType)
  }

  @objc fileprivate func cancelButtonTapped() {
    self.viewModel.inputs.cancelButtonTapped()
  }

  fileprivate func closeLoginTout() {
    self.loginToutViewController?.dismiss(animated: true, completion: nil)
  }

  fileprivate func goToPaymentAuthorization(request: PKPaymentRequest) {
    let vc = PKPaymentAuthorizationViewController(paymentRequest: request)
    vc.delegate = self
    self.present(vc, animated: true, completion: nil)
  }

  fileprivate func goToSafariBrowser(url: URL) {
    let controller = SFSafariViewController(url: url)
    controller.modalPresentationStyle = .overFullScreen
    self.present(controller, animated: true, completion: nil)
  }

  fileprivate func goToThanks(project: Project) {
    let thanksVC = ThanksViewController.configuredWith(project: project)
    let stack = self.navigationController?.viewControllers
    guard let root = stack?.first else {
      assertionFailure("Unable to find root view controller!")
      return
    }
    self.navigationController?.setViewControllers([root, thanksVC], animated: true)
  }

  fileprivate func goToWebModal(request: URLRequest) {
    let vc = WebModalViewController.configuredWith(request: request)
    let nav = UINavigationController(rootViewController: vc)
    self.present(nav, animated: true, completion: nil)
  }

  fileprivate func openLoginTout() {
    let vc = LoginToutViewController.configuredWith(loginIntent: .backProject)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet

    self.present(nav, animated: true, completion: nil)
  }

  fileprivate func popViewController() {
    self.navigationController?.popToRootViewController(animated: true)
  }

  fileprivate func showAlert(message: String) {
    self.present(
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
    _ controller: PKPaymentAuthorizationViewController) {
    self.viewModel.inputs.paymentAuthorizationWillAuthorizePayment()
  }

  internal func paymentAuthorizationViewController(
    _ controller: PKPaymentAuthorizationViewController,
    didAuthorizePayment payment: PKPayment,
                        completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {

    self.viewModel.inputs.paymentAuthorization(didAuthorizePayment: .init(payment: payment))

    STPAPIClient.shared().createToken(with: payment) { [weak self] token, error in
      if let status = self?.viewModel.inputs.stripeCreatedToken(stripeToken: token?.tokenId, error: error as NSError?) {
        completion(status)
      } else {
        completion(.failure)
      }
    }
  }

  internal func paymentAuthorizationViewControllerDidFinish(
    _ controller: PKPaymentAuthorizationViewController) {

    controller.dismiss(animated: true) {
      self.viewModel.inputs.paymentAuthorizationDidFinish()
    }
  }
}
