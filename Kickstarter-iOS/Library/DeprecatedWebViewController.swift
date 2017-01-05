import Library
import Prelude
import UIKit

internal class DeprecatedWebViewController: UIViewController {
  fileprivate let viewModel: DeprecatedWebViewModelType = DeprecatedWebViewModel()

  fileprivate let activityIndicator = UIActivityIndicatorView()
  fileprivate let loadingOverlayView = UIView()
  internal let webView = UIWebView()

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.view.addSubview(self.webView)
    self.view.addSubview(self.loadingOverlayView)
    self.loadingOverlayView.addSubview(self.activityIndicator)

    NSLayoutConstraint.activate([
      self.webView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),

      self.loadingOverlayView.topAnchor.constraint(equalTo: self.webView.topAnchor),
      self.loadingOverlayView.bottomAnchor.constraint(equalTo: self.webView.bottomAnchor),
      self.loadingOverlayView.leadingAnchor.constraint(equalTo: self.webView.leadingAnchor),
      self.loadingOverlayView.trailingAnchor.constraint(equalTo: self.webView.trailingAnchor),

      activityIndicator.centerXAnchor.constraint(equalTo: self.webView.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: self.webView.centerYAnchor)
    ])

    self.webView.delegate = self

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    self.activityIndicator
      |> UIActivityIndicatorView.lens.translatesAutoresizingMaskIntoConstraints .~ false
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .white
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
      .observeValues { [weak self] hidden, animate in

        if !hidden {
          self?.activityIndicator.startAnimating()
          self?.loadingOverlayView.isHidden = false
          self?.loadingOverlayView.alpha = 0.0
        }

        UIView.animate(withDuration: animate ? 0.2 : 0.0, animations: {
          self?.loadingOverlayView.alpha = hidden ? 0.0 : 1.0
        }, completion: { _ in
          if hidden {
            self?.activityIndicator.stopAnimating()
            self?.loadingOverlayView.isHidden = true
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
  internal func webViewDidStartLoad(_ webView: UIWebView) {
    self.viewModel.inputs.webViewDidStartLoad()
  }

  // Call super from subclasses that override this method.
  internal func webViewDidFinishLoad(_ webView: UIWebView) {
    self.viewModel.inputs.webViewDidFinishLoad()
  }

  // Call super from subclasses that override this method.
  internal func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
    self.viewModel.inputs.webViewDidFail(withError: error as NSError?)
  }
}
