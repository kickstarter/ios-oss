import Library
import Prelude
import UIKit

internal class DeprecatedWebViewController: UIViewController {
  private let viewModel: DeprecatedWebViewModelType = DeprecatedWebViewModel()

  private let activityIndicator = UIActivityIndicatorView()
  private let loadingOverlayView = UIView()
  internal let webView = UIWebView()

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.view.addSubview(self.webView)
    self.view.addSubview(self.loadingOverlayView)
    self.loadingOverlayView.addSubview(self.activityIndicator)

    NSLayoutConstraint.activateConstraints([
      self.webView.topAnchor.constraintEqualToAnchor(self.view.topAnchor),
      self.webView.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor),
      self.webView.leadingAnchor.constraintEqualToAnchor(self.view.leadingAnchor),
      self.webView.trailingAnchor.constraintEqualToAnchor(self.view.trailingAnchor),

      self.loadingOverlayView.topAnchor.constraintEqualToAnchor(self.webView.topAnchor),
      self.loadingOverlayView.bottomAnchor.constraintEqualToAnchor(self.webView.bottomAnchor),
      self.loadingOverlayView.leadingAnchor.constraintEqualToAnchor(self.webView.leadingAnchor),
      self.loadingOverlayView.trailingAnchor.constraintEqualToAnchor(self.webView.trailingAnchor),

      activityIndicator.centerXAnchor.constraintEqualToAnchor(self.webView.centerXAnchor),
      activityIndicator.centerYAnchor.constraintEqualToAnchor(self.webView.centerYAnchor)
    ])

    self.webView.delegate = self

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    self.activityIndicator
      |> UIActivityIndicatorView.lens.translatesAutoresizingMaskIntoConstraints .~ false
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .White
      |> UIActivityIndicatorView.lens.color .~ .ksr_navy_900

    self.loadingOverlayView
      |> UIView.lens.translatesAutoresizingMaskIntoConstraints .~ false
      |> UIView.lens.backgroundColor .~ UIColor(white: 1.0, alpha: 0.8)

    self.webView
      |> UIWebView.lens.suppressesIncrementalRendering .~ true
      |> UIWebView.lens.translatesAutoresizingMaskIntoConstraints .~ false
      |> UIWebView.lens.scrollView.decelerationRate .~ UIScrollViewDecelerationRateNormal
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadingOverlayIsHiddenAndAnimate
      .observeForUI()
      .observeNext { [weak self] hidden, animate in

        if !hidden {
          self?.activityIndicator.startAnimating()
          self?.loadingOverlayView.hidden = false
          self?.loadingOverlayView.alpha = 0.0
        }

        UIView.animateWithDuration(animate ? 0.2 : 0.0, animations: {
          self?.loadingOverlayView.alpha = hidden ? 0.0 : 1.0
        }, completion: { _ in
          if hidden {
            self?.activityIndicator.stopAnimating()
            self?.loadingOverlayView.hidden = true
          }
      })
    }
  }

  deinit {
    self.webView.delegate = nil
  }
}

extension DeprecatedWebViewController: UIWebViewDelegate {
  // Call super from subclasses that override this method.
  internal func webViewDidStartLoad(webView: UIWebView) {
    self.viewModel.inputs.webViewDidStartLoad()
  }

  // Call super from subclasses that override this method.
  internal func webViewDidFinishLoad(webView: UIWebView) {
    self.viewModel.inputs.webViewDidFinishLoad()
  }

  // Call super from subclasses that override this method.
  #if swift(>=2.3)
  internal func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
    self.viewModel.inputs.webViewDidFail(withError: error)
  }
  #else
  internal func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
    self.viewModel.inputs.webViewDidFail(withError: error)
  }
  #endif
}
