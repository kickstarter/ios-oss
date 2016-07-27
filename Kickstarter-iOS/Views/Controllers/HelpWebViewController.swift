import Library
import Prelude
import UIKit

internal final class HelpWebViewController: WebViewController {
  private let viewModel: HelpWebViewModelType = HelpWebViewModel()

  internal func configureWith(helpType helpType: HelpType) {
    self.viewModel.inputs.configureWith(helpType: helpType)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindViewModel() {
    self.viewModel.outputs.webViewLoadRequest
      .observeForUI()
      .observeNext { [weak self] in self?.webView.loadRequest($0) }
  }
}
