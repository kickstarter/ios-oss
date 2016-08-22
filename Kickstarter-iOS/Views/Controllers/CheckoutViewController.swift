import KsApi
import Library
import Prelude
import ReactiveCocoa
import UIKit

internal final class CheckoutViewController: DeprecatedWebViewController {
  private weak var loginToutViewController: UIViewController? = nil
  private let viewModel: CheckoutViewModelType = CheckoutViewModel()

  internal static func configuredWith(project project: Project,
                                              reward: Reward?,
                                              intent: CheckoutIntent) -> CheckoutViewController {
    let vc = Storyboard.Checkout.instantiate(CheckoutViewController)
    vc.viewModel.inputs.configureWith(project: project, reward: reward, intent: intent)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.closeLoginTout
      .observeForUI()
      .observeNext { [weak self] _ in self?.closeLoginTout() }

    self.viewModel.outputs.goToThanks
      .observeOn(QueueScheduler.mainQueueScheduler)
      .observeNext { [weak self] project in self?.goToThanks(project: project) }

    self.viewModel.outputs.openLoginTout
      .observeForUI()
      .observeNext { [weak self] _ in self?.openLoginTout() }

    self.viewModel.outputs.popViewController
      .observeForUI()
      .observeNext { [weak self] _ in self?.popViewController() }

    self.viewModel.outputs.webViewLoadRequest
      .observeForUI()
      .observeNext { [weak self] request in
        self?.webView.loadRequest(request)
    }

    NSNotificationCenter.defaultCenter()
      .addObserverForName(CurrentUserNotifications.sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }
  }

  func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest,
               navigationType: UIWebViewNavigationType) -> Bool {
    return self.viewModel.inputs.shouldStartLoad(withRequest: request, navigationType: navigationType)
  }

  private func closeLoginTout() {
    self.loginToutViewController?.dismissViewControllerAnimated(true, completion: nil)
  }

  private func goToThanks(project project: Project) {
    let vc = ThanksViewController.configuredWith(project: project)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func openLoginTout() {
    let vc = LoginToutViewController.configuredWith(loginIntent: .backProject)
    self.presentViewController(UINavigationController(rootViewController: vc),
                               animated: true,
                               completion: nil)
  }

  private func popViewController() {
    self.navigationController?.popViewControllerAnimated(true)
  }
}
