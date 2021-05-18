import KsApi
import Library
import Prelude
import UIKit

internal final class CommentCellHeaderStackView: UIStackView {
  private lazy var userImageView = { UIImageView(frame: .zero)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var userNameLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var userNameTagLabel: PaddingLabel = { PaddingLabel(frame: .zero) }()
  private lazy var postTimeLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var usernameLabelsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var usernameTimeLabelsStackView: UIStackView = { UIStackView(frame: .zero) }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    _ = self
      |> \.axis .~ .horizontal
      |> \.spacing .~ Styles.grid(2)

    _ = self.usernameTimeLabelsStackView
      |> \.axis .~ .vertical
      |> \.spacing .~ Styles.grid(1)

    _ = self.usernameLabelsStackView
      |> \.axis .~ .horizontal
      |> \.spacing .~ Styles.grid(1)
      |> \.alignment .~ .leading

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

    _ = ([self.userImageView, self.usernameTimeLabelsStackView], self)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.usernameLabelsStackView, self.postTimeLabel], self.usernameTimeLabelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    let emptyView = UIView()
    _ = ([self.userNameLabel, self.userNameTagLabel, emptyView], self.usernameLabelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    NSLayoutConstraint.activate([
      self.userImageView.widthAnchor.constraint(equalToConstant: Styles.grid(7)),
      self.userImageView.heightAnchor.constraint(equalToConstant: Styles.grid(7))
    ])
  }

  required init(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  internal func configureWith(comment: DemoComment) {
    self.userNameLabel.text = comment.username == nil
      ? (comment.firstName + " " + comment.lastName)
      : comment.username

    self.postTimeLabel.text = comment.postTime
    self.userImageView
      .ksr_setRoundedImageWith(URL(string: comment.imageURL)!)

    switch comment.type {
    case .creator:
      _ = self.userNameTagLabel
        |> creatorTagLabelStyle
    case .superbacker:
      _ = self.userNameTagLabel
        |> \.insets .~ .zero
        |> superbackerTagLabelStyle

      _ = self
        |> \.alignment .~ .top
    case .you:
      _ = self.userNameTagLabel
        |> youTagLabelStyle
    default:
      break
    }
  }
}

// MARK: Styles

private let creatorTagLabelStyle: LabelStyle = { label in
  label
    |> \.text .~ "Creator"
    |> \.font .~ UIFont.ksr_footnote()
    |> \.textColor .~ UIColor.ksr_create_700
    |> \.backgroundColor .~ UIColor.ksr_create_700.withAlphaComponent(0.06)
    |> roundedStyle(cornerRadius: Styles.grid(1))
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.textAlignment .~ NSTextAlignment.right
}

private let youTagLabelStyle: LabelStyle = { label in
  label
    |> \.text .~ "You"
    |> \.font .~ UIFont.ksr_footnote()
    |> \.textColor .~ UIColor.ksr_trust_700
    |> \.backgroundColor .~ UIColor.ksr_trust_100
    |> roundedStyle(cornerRadius: Styles.grid(1))
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.textAlignment .~ NSTextAlignment.right
}

private let superbackerTagLabelStyle: LabelStyle = { label in
  label
    |> \.text .~ "SUPERBACKER"
    |> \.font .~ UIFont.ksr_headline(size: 10)
    |> \.textColor .~ UIColor.ksr_celebrate_500
    |> \.adjustsFontForContentSizeCategory .~ true
}

// MARK: Helper Class

private class PaddingLabel: UILabel {
  var insets = UIEdgeInsets(all: Styles.grid(1))

  override func drawText(in rect: CGRect) {
    super.drawText(in: rect.inset(by: self.insets))
  }

  override var intrinsicContentSize: CGSize {
    let size = super.intrinsicContentSize
    return CGSize(
      width: size.width + self.insets.left + self.insets.right,
      height: size.height + self.insets.top + self.insets.bottom
    )
  }
}
