import KsApi
import Library
import Prelude
import ReactiveCocoa
import UIKit

internal final class WebModalViewController: WebViewController {
  private let viewModel: WebModalViewModelType = WebModalViewModel()

  internal static func configuredWith(request request: NSURLRequest) -> WebModalViewController {
    let vc = Storyboard.WebModal.instantiate(WebModalViewController)
    vc.viewModel.inputs.configureWith(request: request)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem.rightBarButtonItem =
      UIBarButtonItem(title: Strings.general_navigation_buttons_close(),
                      style: .Plain,
                      target: self,
                      action: #selector(closeButtonTapped))

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.dismissViewController
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.dismissViewControllerAnimated(true, completion: nil)
    }

    self.viewModel.outputs.webViewLoadRequest
      .observeForControllerAction()
      .observeNext { [weak self] request in
        self?.webView.loadRequest(request)
    }
  }

  @objc private func closeButtonTapped() {
    self.viewModel.inputs.closeButtonTapped()
  }

  internal func webView(webView: WKWebView,
                        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
                                                        decisionHandler: (WKNavigationActionPolicy) -> Void) {
    decisionHandler(self.viewModel.inputs.decidePolicyFor(navigationAction: navigationAction))
  }
}
