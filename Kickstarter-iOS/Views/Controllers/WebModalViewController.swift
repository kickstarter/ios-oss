import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class WebModalViewController: WebViewController {
  fileprivate let viewModel: WebModalViewModelType = WebModalViewModel()

  internal static func configuredWith(request: URLRequest) -> WebModalViewController {
    let vc: WebModalViewController = Storyboard.WebModal.instantiate()
    vc.viewModel.inputs.configureWith(request: request)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem.leftBarButtonItem =
      UIBarButtonItem(title: Strings.general_navigation_buttons_close(),
                      style: .plain,
                      target: self,
                      action: #selector(closeButtonTapped))

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.dismissViewController
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.dismiss(animated: true, completion: nil)
    }

    self.viewModel.outputs.webViewLoadRequest
      .observeForControllerAction()
      .observeValues { [weak self] request in
        _ = self?.webView.load(request)
    }
  }

  @objc fileprivate func closeButtonTapped() {
    self.viewModel.inputs.closeButtonTapped()
  }

  internal func webView(_ webView: WKWebView,
                        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
                                                        decisionHandler: (WKNavigationActionPolicy) -> Void) {
    decisionHandler(self.viewModel.inputs.decidePolicyFor(navigationAction: navigationAction))
  }
}
