import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import WebKit

internal class WebViewController: UIViewController {
  internal let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
  internal var bottomAnchorConstraint: NSLayoutConstraint?

  // Enables us to pass the http cookie from Perimeter X for additional protection
  private var webKitCookieStore: WKHTTPCookieStore?

  override func loadView() {
    super.loadView()

    self.webView.configuration.suppressesIncrementalRendering = true
    self.webView.configuration.allowsInlineMediaPlayback = true
    self.webView.configuration.applicationNameForUserAgent = "Kickstarter-iOS"
    self.webView.customUserAgent = Service.userAgent

    self.webKitCookieStore = WKWebsiteDataStore.default().httpCookieStore

    self.view.addSubview(self.webView)

    let bottomAnchorConstraint = self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    self.bottomAnchorConstraint = bottomAnchorConstraint

    NSLayoutConstraint.activate(
      [
        self.webView.topAnchor.constraint(equalTo: self.view.topAnchor),
        bottomAnchorConstraint,
        self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
        self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
      ]
    )
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

  func webView(
    _: WKWebView,
    decidePolicyFor _: WKNavigationResponse,
    decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
  ) {
    if let newCookie = AppEnvironment.current.apiService.perimeterXClient.cookie {
      self.webKitCookieStore?.setCookie(newCookie, completionHandler: {
        print("Perimeter X mobile VID cookie set.")
      })
    }
    decisionHandler(.allow)
  }
}

extension WebViewController: WKUIDelegate {
  func webView(
    _ webView: WKWebView,
    createWebViewWith _: WKWebViewConfiguration,
    for navigationAction: WKNavigationAction,
    windowFeatures _: WKWindowFeatures
  ) -> WKWebView? {
    if navigationAction.targetFrame == nil {
      webView.load(navigationAction.request)
    }
    return nil
  }
}

extension WebViewController: WKNavigationDelegate {}

extension WebViewController: UIScrollViewDelegate {}

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

extension Lens where Whole: WebViewControllerProtocol, Part == WKWebView {
  internal var scrollView: Lens<Whole, UIScrollView> {
    return Whole.lens.webView .. Part.lens.scrollView
  }
}
