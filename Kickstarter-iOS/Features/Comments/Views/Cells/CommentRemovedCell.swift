import KsApi
import Library
import Prelude
import UIKit

protocol CommentRemovedCellDelegate: AnyObject {
  func commentRemovedCell(_ cell: CommentRemovedCell, didTapURL: URL)
}

final class CommentRemovedCell: UITableViewCell, ValueCell {
  weak var delegate: CommentRemovedCellDelegate?

  // MARK: - Properties

  private lazy var rootStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var infoImageView = {
    UIImageView(frame: .zero)
      |> \.image .~ Library.image(named: "info")
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var commentTextView: UITextView = {
    UITextView(frame: .zero)
      |> \.delegate .~ self
  }()

  private lazy var rowStackView: UIStackView = {
    UIStackView(frame: .zero)
  }()

  private lazy var commentCellHeaderStackView: CommentCellHeaderStackView = {
    CommentCellHeaderStackView(frame: .zero)
  }()

  private lazy var viewRepliesView: ViewRepliesView = { ViewRepliesView(frame: .zero) }()

  private let viewModel = CommentCellViewModel()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.setupConstraints()
    self.bindStyles()
    self.configureViews()
    self.bindViewModel()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = self.rootStackView
      |> commentCellRootStackViewStyle

    _ = self.rowStackView
      |> rowStackViewStyle

    _ = self.commentTextView
      |> tappableLinksViewStyle

    self.viewModel.inputs.bindStyles()
  }

  // MARK: - Configuration

  internal func configureWith(value: Comment) {
    self.commentCellHeaderStackView
      .configureWith(comment: value)
    self.viewModel.inputs.configureWith(comment: value, project: nil)
  }

  private func configureViews() {
    self.rowStackView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    _ = ([self.commentCellHeaderStackView, self.rowStackView, self.viewRepliesView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.infoImageView, self.commentTextView], self.rowStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    NSLayoutConstraint.activate([
      self.infoImageView.widthAnchor.constraint(equalToConstant: Styles.grid(4)),
      self.infoImageView.heightAnchor.constraint(equalToConstant: Styles.grid(4))
    ])
  }

  // MARK: - View model

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewRepliesView.rac.hidden = self.viewModel.outputs.viewRepliesViewHidden

    self.viewModel.outputs.notifyDelegateLinkTappedWithURL
      .observeForUI()
      .observeValues { [weak self] url in
        guard let self = self else { return }
        self.delegate?.commentRemovedCell(self, didTapURL: url)
      }

    self.viewModel.outputs.body
      .observeForUI()
      .observeValues { body in
        self.commentTextView.attributedText = attributedText(body)
      }
  }
}

// MARK: Styles

private let rowStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.alignment .~ .top
    |> \.spacing .~ Styles.grid(1)
}

// MARK: - Functions

private func attributedText(_ text: String) -> NSAttributedString? {
  let attributes: [NSAttributedString.Key: Any] = [
    .font: UIFont.ksr_callout(),
    .foregroundColor: UIColor.ksr_support_400,
    .underlineStyle: false
  ]

  guard let attributedString = try? NSMutableAttributedString(
    data: Data(text.utf8),
    options: [
      .documentType: NSAttributedString.DocumentType.html,
      .characterEncoding: String.Encoding.utf8.rawValue
    ],
    documentAttributes: nil
  ) else { return nil }

  let fullRange = (attributedString.string as NSString).range(of: attributedString.string)
  attributedString.addAttributes(attributes, range: fullRange)

  return attributedString
}

// MARK: - UITextViewDelegate

extension CommentRemovedCell: UITextViewDelegate {
  func textView(
    _: UITextView, shouldInteractWith _: NSTextAttachment,
    in _: NSRange, interaction _: UITextItemInteraction
  ) -> Bool {
    return false
  }

  func textView(
    _: UITextView, shouldInteractWith url: URL, in _: NSRange,
    interaction _: UITextItemInteraction
  ) -> Bool {
    self.viewModel.inputs.linkTapped(url: url)
    return false
  }
}
