import KsApi
import Library
import Prelude
import UIKit

final class CommentCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var userImageView = { UIImageView(frame: .zero)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rootStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var separatorView: UIView = { UIView(frame: .zero)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var checkmarkImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var userNameLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var postTimeLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var titleLabelsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var commentLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var replyButton = { UIButton(frame: .zero) }()
  private lazy var flagButton = { UIButton(frame: .zero) }()
  private lazy var topColumnStackView: UIStackView = { UIStackView(frame: .zero) }()
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
      |> \.selectionStyle .~ .none

    _ = self.commentLabel
      |> \.lineBreakMode .~ .byWordWrapping
      |> \.numberOfLines .~ 0
      |> \.textColor .~ .ksr_support_700
      |> \.textAlignment .~ .left
      |> \.font .~ UIFont.ksr_callout()
      |> \.adjustsFontForContentSizeCategory .~ true

    _ = self.userNameLabel
      |> \.numberOfLines .~ 1
      |> \.textColor .~ .ksr_support_700
      |> \.textAlignment .~ .left
      |> \.font .~ UIFont.ksr_callout().weighted(.semibold)
      |> \.adjustsFontForContentSizeCategory .~ true

    _ = self.postTimeLabel
      |> \.numberOfLines .~ 1
      |> \.textColor .~ .ksr_support_400
      |> \.textAlignment .~ .left
      |> \.font .~ UIFont.ksr_footnote()
      |> \.adjustsFontForContentSizeCategory .~ true

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.topColumnStackView
      |> topStackViewStyle

    _ = self.titleLabelsStackView
      |> labelsStackViewStyle

    _ = self.separatorView
      |> separatorViewStyle

    _ = self.replyButton
      |> replyButtonStyle

    _ = self.flagButton
      |> UIButton.lens.image(for: .normal) %~ { _ in UIImage(named: "flag") }
  }

  // MARK: - Configuration

  internal func configureWith(value: DemoComment) {
    self.commentLabel.text = value.body
    self.userNameLabel.text = value.username == nil ? (value.firstName + " " + value.lastName) : value
      .username
    self.postTimeLabel.text = value.postTime
    self.userImageView
      .ksr_setRoundedImageWith(URL(string: value.imageURL)!)
  }

  private func configureViews() {
    _ = ([self.topColumnStackView, self.commentLabel, self.bottomColumnStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.userNameLabel, self.postTimeLabel], self.titleLabelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.userImageView, self.titleLabelsStackView], self.topColumnStackView)
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
      self.userImageView.widthAnchor.constraint(equalToConstant: Styles.grid(7)),
      self.userImageView.heightAnchor.constraint(equalToConstant: Styles.grid(7)),
      self.replyButton.widthAnchor.constraint(equalToConstant: 70),
      self.replyButton.heightAnchor.constraint(equalToConstant: 20),
      self.flagButton.widthAnchor.constraint(equalToConstant: Styles.grid(3)),
      self.flagButton.heightAnchor.constraint(equalToConstant: Styles.grid(3)),
      self.rootStackView.bottomAnchor.constraint(equalTo: self.separatorView.topAnchor, constant: 1),
      self.separatorView.heightAnchor.constraint(equalToConstant: 1),
      self.separatorView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
      self.separatorView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
      self.separatorView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
    ])
  }
}

// MARK: Styles

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.layoutMargins .~ .init(all: Styles.grid(3))
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.insetsLayoutMarginsFromSafeArea .~ false
    |> \.spacing .~ Styles.grid(3)
}

private let labelsStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.spacing .~ Styles.grid(1)
}

private let topStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .horizontal
    |> \.spacing .~ Styles.grid(2)
}

private let separatorViewStyle: ViewStyle = { (view: UIView) in
  view
    |> \.backgroundColor .~ UIColor.hex(0xF0F0F0)
    |> \.accessibilityElementsHidden .~ true
}

private let replyButtonStyle: ButtonStyle = { button in
  button
    |> UIButton.lens.title(for: .normal) %~ { _ in "Reply" }
    |> UIButton.lens.titleLabel.font .~ UIFont.ksr_subhead()
    |> UIButton.lens.image(for: .normal) .~ Library.image(named: "reply")
    |> UIButton.lens.titleColor(for: .normal) .~ UIColor.hex(0x656969)
    |> UIButton.lens.tintColor .~ UIColor.hex(0x656969)
    |> UIButton.lens.titleEdgeInsets .~ UIEdgeInsets(left: 7.17)
    |> UIButton.lens.contentHorizontalAlignment .~ .left
}
