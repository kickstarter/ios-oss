import Library
import Prelude
import UIKit

internal final class HelpWebViewController: WebViewController {
  fileprivate let viewModel: HelpWebViewModelType = HelpWebViewModel()

  internal static func configuredWith(helpType: HelpType) -> HelpWebViewController {
    let vc: HelpWebViewController = Storyboard.Help.instantiate()
    vc.viewModel.inputs.configureWith(helpType: helpType)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    if self.navigationController?.viewControllers.count == .some(1) {
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(
        title: Strings.general_navigation_buttons_close(),
        style: .plain,
        target: self,
        action: #selector(closeButtonTapped)
      )
    }

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindViewModel() {
    self.viewModel.outputs.webViewLoadRequest
      .observeForControllerAction()
      .observeValues { [weak self] in _ = self?.webView.load($0) }
  }

  @objc fileprivate func closeButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }
}
