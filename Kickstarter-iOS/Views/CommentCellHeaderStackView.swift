import KsApi
import Library
import Prelude
import UIKit

internal final class CommentCellHeaderStackView: UIStackView {
  // MARK: - Properties

  fileprivate let viewModel = CommentCellViewModel()

  private lazy var avatarImageView = { UIImageView(frame: .zero)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var userNameLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var usernameLabelsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var userNameTagLabel: PaddingLabel = { PaddingLabel(frame: .zero) }()
  private lazy var usernameTimeLabelsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var postTimeLabel: UILabel = { UILabel(frame: .zero) }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.bindStyles()
    self.configureViews()
    self.bindViewModel()
  }

  required init(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()
    _ = self
      |> \.axis .~ .horizontal
      |> \.spacing .~ Styles.grid(2)

    _ = self.usernameTimeLabelsStackView
      |> \.axis .~ .vertical
      |> \.spacing .~ Styles.grid(1)

    _ = self.usernameLabelsStackView
      |> \.axis .~ .horizontal
      |> \.spacing .~ Styles.grid(1)

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
      |> \.numberOfLines .~ 2
      |> \.textColor .~ .ksr_support_400
      |> \.textAlignment .~ .left
      |> \.font .~ UIFont.ksr_footnote()
      |> \.adjustsFontForContentSizeCategory .~ true
  }

  // MARK: - Configuration

  internal func configureWith(comment: DemoComment) {
    self.viewModel.inputs.configureWith(comment: comment)
  }

  internal func configureUserTagStyle(from userTag: DemoComment.UserTagEnum) {
    switch userTag {
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

  private func configureViews() {
    _ = ([self.avatarImageView, self.usernameTimeLabelsStackView], self)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.usernameLabelsStackView, self.postTimeLabel], self.usernameTimeLabelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.userNameLabel, self.userNameTagLabel, UIView()], self.usernameLabelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.userNameTagLabel.setContentCompressionResistancePriority(.init(1_000), for: .horizontal)
    self.userNameTagLabel.setContentHuggingPriority(.init(1_000), for: .horizontal)

    NSLayoutConstraint.activate([
      self.avatarImageView.widthAnchor.constraint(equalToConstant: Styles.grid(7)),
      self.avatarImageView.heightAnchor.constraint(equalToConstant: Styles.grid(7))
    ])
  }

  // MARK: View Model

  override func bindViewModel() {
    self.viewModel.outputs.avatarImageURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.avatarImageView.af.cancelImageRequest()
        self?.avatarImageView.image = nil
      })
      .skipNil()
      .observeValues { [weak self] url in
        self?.avatarImageView.ksr_setRoundedImageWith(url)
      }

    self.viewModel.outputs.userTag
      .observeForUI()
      .observeValues(self.configureUserTagStyle)

    self.userNameLabel.rac.text = self.viewModel.authorName
    self.postTimeLabel.rac.text = self.viewModel.postTime
  }
}

// MARK: Styles

private let creatorTagLabelStyle: LabelStyle = { label in
  label
    |> \.text .~ Strings.Creator()
    |> \.font .~ UIFont.ksr_footnote()
    |> \.textColor .~ UIColor.ksr_create_700
    |> \.backgroundColor .~ UIColor.ksr_create_700.withAlphaComponent(0.06)
    |> roundedStyle(cornerRadius: Styles.grid(1))
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.textAlignment .~ NSTextAlignment.right
}

// TODO: Internationalized in the near future.

private let youTagLabelStyle: LabelStyle = { label in
  label
    |> \.text .~ localizedString(key: "You_tag_for_comment_author", defaultValue: "You")
    |> \.font .~ UIFont.ksr_footnote()
    |> \.textColor .~ UIColor.ksr_trust_700
    |> \.backgroundColor .~ UIColor.ksr_trust_100
    |> roundedStyle(cornerRadius: Styles.grid(1))
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.textAlignment .~ NSTextAlignment.right
}

// TODO: Internationalized in the near future.

private let superbackerTagLabelStyle: LabelStyle = { label in
  label
    |> \.text .~ localizedString(key: "Superbacker", defaultValue: "SUPERBACKER")
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
