import KsApi
import Library
import Prelude
import Prelude_UIKit
import WebKit

internal protocol ExternalSourceViewElementCellDelegate: AnyObject {
  func resetContentHeight()
  func resetWebViewContent()
}

class ExternalSourceViewElementCell: UITableViewCell, ValueCell {
  // MARK: Properties

  private lazy var webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
  private var contentHeightConstraint: NSLayoutConstraint?
  private let viewModel: ExternalSourceViewElementCellViewModelType = ExternalSourceViewElementCellViewModel()

  weak var delegate: ExternalSourceViewElementCellDelegate?

  // MARK: Initializers

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.delegate = self

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
      .observeValues { [weak self] htmlText in
        guard let url = URL(string: htmlText) else { return }

        let request = URLRequest(url: url)

        self?.webView.load(request)
      }

    self.viewModel.outputs.contentHeight
      .observeForUI()
      .observeValues { [weak self] value in
        self?.contentHeightConstraint = self?.webView.heightAnchor.constraint(equalToConstant: CGFloat(value))
        self?.viewModel.inputs.toggleContentHeight(true)
      }

    self.viewModel.outputs.toggleContentHeight
      .observeForUI()
      .observeValues { [weak self] isActive in
        self?.contentHeightConstraint?.isActive = isActive
      }

    self.viewModel.outputs.resetWebViewContent
      .observeForUI()
      .observeValues { [weak self] emptyHTML in
        guard let emptyContentURL = URL(string: emptyHTML) else { return }

        let request = URLRequest(url: emptyContentURL)

        self?.webView.load(request)
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
    self.webView.configuration.allowsInlineMediaPlayback = true
    self.webView.configuration.applicationNameForUserAgent = "Kickstarter-iOS"
    self.webView.customUserAgent = Service.userAgent
    self.delegate = self

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

extension ExternalSourceViewElementCell: ExternalSourceViewElementCellDelegate {
  func resetContentHeight() {
    self.viewModel.inputs.toggleContentHeight(false)
  }

  func resetWebViewContent() {
    self.viewModel.inputs.resetWebView()
  }
}
