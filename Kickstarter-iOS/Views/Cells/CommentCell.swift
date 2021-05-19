import KsApi
import Library
import Prelude
import UIKit

final class CommentCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  fileprivate let viewModel = CommentCellViewModel()

  private lazy var rootStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var separatorView: UIView = { UIView(frame: .zero)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var bodyTextView: UITextView = { UITextView(frame: .zero) }()
  private lazy var replyButton = { UIButton(frame: .zero) }()
  private lazy var flagButton = { UIButton(frame: .zero) }()
  private lazy var commentCellHeaderStackView: CommentCellHeaderStackView = {
    CommentCellHeaderStackView(frame: .zero)
  }()

  private lazy var bottomColumnStackView: UIStackView = { UIStackView(frame: .zero) }()

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

    _ = self.bodyTextView
      |> commentBodyTextViewStyle

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.separatorView
      |> separatorViewStyle

    _ = self.replyButton
      |> replyButtonStyle

    _ = self.flagButton
      |> UIButton.lens.image(for: .normal) %~ { _ in UIImage(named: "flag") }
  }

  // MARK: - Configuration

  internal func configureWith(value: DemoComment) {
    self.commentCellHeaderStackView.configureWith(comment: value)
    self.viewModel.inputs.configureWith(comment: value)
  }

  private func configureViews() {
    _ = ([self.commentCellHeaderStackView, self.bodyTextView, self.bottomColumnStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.replyButton, UIView(), self.flagButton], self.bottomColumnStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent(priority: .defaultHigh)

    _ = (self.separatorView, self.contentView)
      |> ksr_addSubviewToParent()

    NSLayoutConstraint.activate([
      self.replyButton.widthAnchor.constraint(equalToConstant: Styles.grid(12)),
      self.replyButton.heightAnchor.constraint(equalToConstant: Styles.grid(3)),
      self.flagButton.widthAnchor.constraint(equalToConstant: Styles.grid(3)),
      self.flagButton.heightAnchor.constraint(equalToConstant: Styles.grid(3)),
      self.rootStackView.bottomAnchor.constraint(equalTo: self.separatorView.topAnchor, constant: 1),
      self.separatorView.heightAnchor.constraint(equalToConstant: 1),
      self.separatorView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
      self.separatorView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
      self.separatorView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
    ])
  }

  // MARK: - View model

  internal override func bindViewModel() {
    self.bodyTextView.rac.text = self.viewModel.outputs.body
  }
}

// MARK: Styles

private let replyButtonStyle: ButtonStyle = { button in
  button
    |> UIButton.lens
    .title(for: .normal) %~ { _ in localizedString(key: "Reply_a_comment", defaultValue: "Reply") }
    |> UIButton.lens.titleLabel.font .~ UIFont.ksr_subhead()
    |> UIButton.lens.image(for: .normal) .~ Library.image(named: "reply")
    |> UIButton.lens.titleColor(for: .normal) .~ UIColor.ksr_support_400
    |> UIButton.lens.tintColor .~ UIColor.ksr_support_400
    |> UIButton.lens.titleEdgeInsets .~ UIEdgeInsets(left: Styles.grid(1))
    |> UIButton.lens.contentHorizontalAlignment .~ .left
}
