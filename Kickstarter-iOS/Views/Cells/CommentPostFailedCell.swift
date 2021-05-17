import KsApi
import Library
import Prelude
import UIKit

final class CommentPostFailedCell: UITableViewCell, ValueCell {
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

  private lazy var userNameLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var userNameTagLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var postTimeLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var usernameLabelsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var usernameTimeLabelsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var commentLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var tapRetryPostButton = { UIButton(frame: .zero) }()
  private lazy var topColumnStackView: UIStackView = { UIStackView(frame: .zero) }()

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

    _ = self.userNameLabel
      |> \.numberOfLines .~ 1
      |> \.textColor .~ .ksr_support_700
      |> \.textAlignment .~ .left
      |> \.font .~ UIFont.ksr_callout().weighted(.semibold)
      |> \.adjustsFontForContentSizeCategory .~ true

    _ = self.userNameTagLabel
      |> \.numberOfLines .~ 1
      |> \.textColor .~ .ksr_create_500
      |> \.textAlignment .~ .left
      |> \.font .~ UIFont.ksr_callout().bolded
      |> \.adjustsFontForContentSizeCategory .~ true

    _ = self.postTimeLabel
      |> \.numberOfLines .~ 1
      |> \.textColor .~ .ksr_support_400
      |> \.textAlignment .~ .left
      |> \.font .~ UIFont.ksr_footnote()
      |> \.adjustsFontForContentSizeCategory .~ true

    _ = self.commentLabel
      |> \.lineBreakMode .~ .byWordWrapping
      |> \.numberOfLines .~ 0
      |> \.textColor .~ .ksr_support_400
      |> \.textAlignment .~ .left
      |> \.font .~ UIFont.ksr_callout()
      |> \.adjustsFontForContentSizeCategory .~ true

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.topColumnStackView
      |> \.axis .~ .horizontal
      |> \.spacing .~ Styles.grid(2)

    _ = self.usernameLabelsStackView
      |> \.axis .~ .horizontal
      |> \.spacing .~ Styles.grid(1)

    _ = self.usernameTimeLabelsStackView
      |> \.axis .~ .vertical
      |> \.spacing .~ Styles.grid(1)

    _ = self.separatorView
      |> \.backgroundColor .~ UIColor.hex(0xF0F0F0)
      |> \.accessibilityElementsHidden .~ true

    _ = self.tapRetryPostButton
      |> tapRetryPostButtonStyle
  }

  // MARK: - Configuration

  internal func configureWith(value: DemoComment) {
    self.userNameLabel.text = value.username == nil ? (value.firstName + " " + value.lastName) : value
      .username
    self.postTimeLabel.text = value.postTime
    self.userImageView
      .ksr_setRoundedImageWith(URL(string: value.imageURL)!)
    self.userNameTagLabel.text = value.type == .backer ? nil : value.type.rawValue.capitalized
    self.commentLabel.text = value.body
  }

  private func configureViews() {
    _ = ([self.topColumnStackView, self.commentLabel, self.tapRetryPostButton], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.userNameLabel, self.userNameTagLabel, UIView()], self.usernameLabelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.usernameLabelsStackView, self.postTimeLabel], self.usernameTimeLabelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.userImageView, self.usernameTimeLabelsStackView], self.topColumnStackView)
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

private let tapRetryPostButtonStyle: ButtonStyle = { button in
  button
    |> UIButton.lens.title(for: .normal) %~ { _ in "Failed to post. Tap to retry" }
    |> UIButton.lens.titleLabel.font .~ UIFont.ksr_subhead()
    |> UIButton.lens.image(for: .normal) .~ Library.image(named: "circle-back")
    |> UIButton.lens.titleColor(for: .normal) .~ UIColor.ksr_celebrate_700
    |> UIButton.lens.tintColor .~ UIColor.ksr_celebrate_700
    |> UIButton.lens.titleEdgeInsets .~ UIEdgeInsets(left: 7.17)
    |> UIButton.lens.contentHorizontalAlignment .~ .left
}
