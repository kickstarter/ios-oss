import Library
import UIKit

internal class DeprecatedWebViewController: UIViewController {
  internal let webView = UIWebView()

  override func loadView() {
    super.loadView()

    self.view.addSubview(self.webView)
    self.webView.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
    self.webView.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true
    self.webView.leadingAnchor.constraintEqualToAnchor(self.view.leadingAnchor).active = true
    self.webView.trailingAnchor.constraintEqualToAnchor(self.view.trailingAnchor).active = true
    self.webView.translatesAutoresizingMaskIntoConstraints = false

    self.webView.delegate = self
  }

  deinit {
    self.webView.delegate = nil
  }
}

extension DeprecatedWebViewController: UIWebViewDelegate {
}
