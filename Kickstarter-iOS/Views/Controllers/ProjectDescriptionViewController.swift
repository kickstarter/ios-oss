import KsApi
import Library
import Prelude
import UIKit

private let contentSizeKeyPath = "contentSize"

internal final class ProjectDescriptionViewController: WebViewController {
  private let viewModel: ProjectDescriptionViewModelType = ProjectDescriptionViewModel()

  private var headerView: UIView?
  private var footerView: UIView?

  internal func configureWith(project project: Project) {
    self.viewModel.inputs.configureWith(project: project)
  }

  internal func expandDescription() {
    self.viewModel.inputs.expandDescription()
  }

  internal func transfer(headerView headerView: UIView?,
                                    footerView: UIView?,
                                    previousContentOffset: CGPoint?) {
    self.headerView = headerView
    self.footerView = footerView
    self.footerView?.hidden = true

    if let headerView = headerView, footerView = footerView {
      self.webView.scrollView.addSubview(headerView)
      self.webView.scrollView.addSubview(footerView)
      self.viewModel.inputs.transferredHeaderAndFooter(atContentOffset: previousContentOffset)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()
    self.webView.scrollView.addObserver(self, forKeyPath: contentSizeKeyPath, options: [], context: nil)
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.viewModel.inputs.viewDidAppear()
  }

  override func observeValueForKeyPath(keyPath: String?,
                                       ofObject object: AnyObject?,
                                                change: [String : AnyObject]?,
                                                context: UnsafeMutablePointer<Void>) {

    if keyPath == contentSizeKeyPath {
      self.viewModel.inputs.observedWebViewContentSizeChange(self.webView.scrollView.contentSize)
    }
  }

  deinit {
    self.webView.scrollView.removeObserver(self, forKeyPath: contentSizeKeyPath)
  }

  override func bindStyles() {
    super.bindStyles()

    self
      |> baseControllerStyle()
      |> (WebViewController.lens.webView.scrollView • UIScrollView.lens.delaysContentTouches) .~ false
      |> (WebViewController.lens.webView.scrollView • UIScrollView.lens.canCancelContentTouches) .~ true
      |> (WebViewController.lens.webView.scrollView • UIScrollView.lens.delaysContentTouches) .~ false
      |> (WebViewController.lens.webView.scrollView • UIScrollView.lens.clipsToBounds) .~ false
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadWebViewRequest
      .observeForUI()
      .observeNext { [weak self] in
        self?.webView.loadRequest($0)
    }

    self.viewModel.outputs.layoutFooterAndHeader
      .observeForUI()
      .observeNext { [weak self] descriptionExpanded, contentOffset in
        self?.layoutFooterAndHeader(descriptionExpanded: descriptionExpanded, contentOffset: contentOffset)
    }

    self.footerView?.rac.hidden = self.viewModel.outputs.footerHidden
  }

  private func layoutFooterAndHeader(descriptionExpanded descriptionExpanded: Bool,
                                                         contentOffset: CGPoint?) {

    guard let headerView = self.headerView, footerView = self.footerView else { return }

    headerView.frame.size = headerView.systemLayoutSizeFittingSize(
      CGSize(width: self.view.frame.width, height: 0),
      withHorizontalFittingPriority: UILayoutPriorityRequired,
      verticalFittingPriority: UILayoutPriorityDefaultLow
    )
    headerView.frame.origin = .zero

    footerView.frame.size = footerView.systemLayoutSizeFittingSize(
      CGSize(width: self.view.frame.width, height: 0),
      withHorizontalFittingPriority: UILayoutPriorityRequired,
      verticalFittingPriority: UILayoutPriorityDefaultLow
    )

    let script = "document.body.style.padding = '\(Int(headerView.frame.height))px 0px 0px 0px';"
    self.webView.evaluateJavaScript(script) { _, _ in

      if descriptionExpanded {
        self.webView.scrollView.contentInset.bottom = footerView.frame.height
      } else {
        self.webView.scrollView.contentInset.bottom = 800 + footerView.frame.height + headerView.frame.height
          - self.webView.scrollView.contentSize.height
      }

      footerView.frame.origin.y = self.webView.scrollView.contentSize.height
        + self.webView.scrollView.contentInset.bottom
        - footerView.frame.height
      footerView.hidden = false
    }

    if let contentOffset = contentOffset {
      self.webView.scrollView.contentOffset = contentOffset
    }
  }

  internal func webView(webView: WKWebView,
                        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
                                                        decisionHandler: (WKNavigationActionPolicy) -> Void) {

    decisionHandler(self.viewModel.inputs.decidePolicyFor(navigationAction: navigationAction))
  }

  internal func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
    self.viewModel.inputs.webViewDidFinishNavigation()
  }

  internal func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    // NB: Hack to get scroll view to use normal deceleration. If we set this in `viewDidLoad` it will
    // not hold. Doing it here causes it to stick for some reason.
    if self.webView.scrollView.decelerationRate != UIScrollViewDecelerationRateNormal {
      self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }
  }
}
