import Library
import Prelude
import UIKit

internal final class HelpWebViewController: WebViewController {
  private let viewModel: HelpWebViewModelType = HelpWebViewModel()

  internal static func configuredWith(helpType helpType: HelpType) -> HelpWebViewController {
    let vc = Storyboard.Help.instantiate(HelpWebViewController)
    vc.viewModel.inputs.configureWith(helpType: helpType)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: Strings.general_navigation_buttons_close(),
      style: .Plain,
      target: self,
      action: #selector(closeButtonTapped)
    )

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindViewModel() {
    self.viewModel.outputs.webViewLoadRequest
      .observeForControllerAction()
      .observeNext { [weak self] in self?.webView.loadRequest($0) }
  }

  @objc private func closeButtonTapped() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}
