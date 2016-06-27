import Library
import UIKit

internal class WebViewController: UIViewController {
  private let configuration = WKWebViewConfiguration()
  internal let webView = WKWebView()

  override func loadView() {
    super.loadView()

    self.view.addSubview(self.webView)
    self.webView.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
    self.webView.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true
    self.webView.leadingAnchor.constraintEqualToAnchor(self.view.leadingAnchor).active = true
    self.webView.trailingAnchor.constraintEqualToAnchor(self.view.trailingAnchor).active = true
    self.webView.translatesAutoresizingMaskIntoConstraints = false

    self.webView.UIDelegate = self
    self.webView.navigationDelegate = self
  }
}

extension WebViewController: WKUIDelegate {

}

extension WebViewController: WKNavigationDelegate {
}
