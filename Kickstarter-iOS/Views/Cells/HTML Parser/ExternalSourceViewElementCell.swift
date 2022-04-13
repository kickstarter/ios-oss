import KsApi
import Library
import Prelude
import Prelude_UIKit
import WebKit

class ExternalSourceViewElementCell: UITableViewCell, ValueCell {
  // MARK: Properties

  private lazy var webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
  private var contentHeightConstraint: NSLayoutConstraint?
  private let viewModel: ExternalSourceViewElementCellViewModelType = ExternalSourceViewElementCellViewModel()

  // MARK: Initializers

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureViews()
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
        guard let url = URL(string: htmlText + "?playsinline=0") else { return }

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
    self.webView.configuration.suppressesIncrementalRendering = true
    self.webView.configuration.allowsInlineMediaPlayback = false
    self.webView.configuration.applicationNameForUserAgent = "Kickstarter-iOS"
    self.webView.customUserAgent = Service.userAgent

    _ = (self.webView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }

  private func setupConstraints() {
    self.contentHeightConstraint = self.webView.heightAnchor.constraint(equalToConstant: .zero)
    self.contentHeightConstraint?.priority = .defaultHigh
    self.contentHeightConstraint?.isActive = true
  }
}
