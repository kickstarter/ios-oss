import KsApi
import Library
import Prelude
import UIKit

final class CommentViewMoreRepliesFailedCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var bodyTextLabel: UILabel = { UILabel(frame: .zero) }()

  private lazy var retryImageView = {
    UIImageView(frame: .zero)
      |> \.image .~ Library.image(named: "circle-back")
      |> \.contentMode .~ .scaleAspectFit
  }()

  private lazy var retryImageViewStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rootStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.bindStyles()
    self.configureViews()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = self.bodyTextLabel
      |> bodyTextLabelStyle

    _ = self.retryImageViewStackView
      |> \.axis .~ .vertical

    _ = self.rootStackView
      |> rootStackViewStyle
  }

  // MARK: - Configuration

  internal func configureWith(value _: Void) {
    return
  }

  private func configureViews() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.retryImageViewStackView, self.bodyTextLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.retryImageView, UIView()], self.retryImageViewStackView)
      |> ksr_addArrangedSubviewsToStackView()

    NSLayoutConstraint.activate([
      self.retryImageView.widthAnchor.constraint(equalToConstant: Styles.grid(3))
    ])
  }
}

// MARK: Styles

private let bodyTextLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_subhead()
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.textColor .~ .ksr_celebrate_700
    |> \.text .~ Strings.Couldnt_load_more_comments_Tap_to_retry()
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .horizontal
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.insetsLayoutMarginsFromSafeArea .~ false
    |> \.layoutMargins .~ .init(
      top: Styles.grid(1),
      left: Styles.grid(CommentCellStyles.Content.leftIndentWidth),
      bottom: Styles.grid(1),
      right: Styles.grid(1)
    )
    |> \.spacing .~ Styles.grid(1)
}
