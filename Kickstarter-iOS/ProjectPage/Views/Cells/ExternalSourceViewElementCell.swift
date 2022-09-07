import KsApi
import Library
import Prelude
import Prelude_UIKit
import WebKit

class ExternalSourceViewElementCell: UITableViewCell, ValueCell {
  // MARK: Properties

  private lazy var webView: WKWebView = {
    let configuration = WKWebViewConfiguration()
    configuration.allowsInlineMediaPlayback = true
    configuration.suppressesIncrementalRendering = true
    configuration.applicationNameForUserAgent = "Kickstarter-iOS"

    let webView = WKWebView(frame: .zero, configuration: configuration)

    webView.customUserAgent = Service.userAgent

    return webView
  }()

  private let viewModel: ExternalSourceViewElementCellViewModelType = ExternalSourceViewElementCellViewModel()
  private var contentHeightConstraint: NSLayoutConstraint?

  // MARK: Initializers

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureViews()
    self.setupDelegate()
    self.setupConstraints()
    self.bindStyles()
    self.bindViewModel()
  }

  // MARK: Lifecycle

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: View Model

  internal override func bindViewModel() {
    self.viewModel.outputs.htmlText
      .observeForUI()
      .on(event: { [weak self] _ in
        guard let emptyContentURL = URL(string: "about:blank") else { return }

        let request = URLRequest(url: emptyContentURL)

        self?.webView.load(request)
      })
      .observeValues { [weak self] htmlText in
        guard let url = URL(string: htmlText + "?playsinline=1") else { return }

        let request = URLRequest(url: url)

        self?.webView.load(request)
      }

    self.viewModel.outputs.contentHeight
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.contentHeightConstraint?.isActive = false
      })
      .observeValues { [weak self] value in
        self?.contentHeightConstraint = self?.webView.heightAnchor.constraint(equalToConstant: CGFloat(value))
        self?.contentHeightConstraint?.isActive = true
      }
  }

  // MARK: View Styles

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> \.separatorInset .~
      .init(
        top: 0,
        left: 0,
        bottom: 0,
        right: self.bounds.size.width + ProjectHeaderCellStyles.Layout.insets
      )

    _ = self.contentView
      |> \.layoutMargins .~ .init(
        topBottom: Styles.gridHalf(3),
        leftRight: Styles.grid(3)
      )
  }

  // MARK: Helpers

  func configureWith(value: ExternalSourceViewElement) {
    self.viewModel.inputs.configureWith(element: value)
  }

  private func configureViews() {
    _ = (self.webView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }

  private func setupDelegate() {
    self.webView.uiDelegate = self
  }

  private func setupConstraints() {
    self.contentHeightConstraint = self.webView.heightAnchor.constraint(equalToConstant: .zero)
    self.contentHeightConstraint?.priority = .defaultHigh
    self.contentHeightConstraint?.isActive = true
  }
}

extension ExternalSourceViewElementCell: WKUIDelegate {
  func webView(_: WKWebView,
               createWebViewWith _: WKWebViewConfiguration,
               for navigationAction: WKNavigationAction,
               windowFeatures _: WKWindowFeatures) -> WKWebView? {
    let canOpenInNewWindow = navigationAction.targetFrame == nil || navigationAction.targetFrame?
      .isMainFrame == false

    if canOpenInNewWindow,
      let urlToLoad = navigationAction.request.url,
      AppEnvironment.current.application.canOpenURL(urlToLoad) {
      AppEnvironment.current.application.open(urlToLoad, options: [:], completionHandler: nil)
    }

    return nil
  }
}
