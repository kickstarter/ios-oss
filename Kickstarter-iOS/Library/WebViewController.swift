import Library
import Prelude
import Prelude_UIKit
import UIKit

internal class WebViewController: UIViewController {
  internal let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())

  override func loadView() {
    super.loadView()

    self.webView.configuration.suppressesIncrementalRendering = true
    self.webView.configuration.allowsInlineMediaPlayback = true
    self.webView.configuration.applicationNameForUserAgent = "Kickstarter-iOS"

    self.view.addSubview(self.webView)
    self.webView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
    self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    self.webView.translatesAutoresizingMaskIntoConstraints = false

    self.webView.uiDelegate = self
    self.webView.navigationDelegate = self
    self.webView.scrollView.delegate = self
  }

  deinit {
    self.webView.uiDelegate = nil
    self.webView.navigationDelegate = nil
    self.webView.scrollView.delegate = nil
  }
}

extension WebViewController: WKUIDelegate {

}

extension WebViewController: WKNavigationDelegate {
}

extension WebViewController: UIScrollViewDelegate {
}

internal protocol WebViewControllerProtocol: UIViewControllerProtocol {
  var webView: WKWebView { get }
}

extension WebViewController: WebViewControllerProtocol {}

extension LensHolder where Object: WebViewControllerProtocol {
  internal var webView: Lens<Object, WKWebView> {
    return Lens(
      view: { $0.webView },
      set: { $1 }
    )
  }
}

extension LensType where Whole: WebViewControllerProtocol, Part == WKWebView {
  internal var scrollView: Lens<Whole, UIScrollView> {
    return Whole.lens.webView • Part.lens.scrollView
  }
}
