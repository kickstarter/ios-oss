import KsApi
import Library
import Prelude
import UIKit

internal final class CommentCellHeaderStackView: UIStackView {
  // MARK: - Properties

  private lazy var authorNameLabel: UILabel = { UILabel(frame: .zero) }()

  private lazy var authorBadgeLabel: PaddingLabel = {
    PaddingLabel(frame: .zero)
  }()

  private lazy var authorNameBadgeLabelsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var authorNameTimeLabelsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var circleAvatarImageView = { CircleAvatarImageView(frame: .zero)
    |> \.backgroundColor .~ .ksr_support_100
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var postTimeLabel: UILabel = { UILabel(frame: .zero) }()
  private let viewModel = CommentCellViewModel()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.bindViewModel()
    self.bindStyles()
    self.configureViews()
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
      |> \.alignment .~ .center

    _ = self.authorNameTimeLabelsStackView
      |> \.axis .~ .vertical
      |> \.spacing .~ Styles.grid(1)

    _ = self.authorNameBadgeLabelsStackView
      |> \.axis .~ .horizontal
      |> \.spacing .~ Styles.grid(1)

    _ = self.authorNameLabel
      |> \.numberOfLines .~ 1
      |> \.textColor .~ .ksr_support_700
      |> \.textAlignment .~ .left
      |> \.font .~ UIFont.ksr_callout().weighted(.semibold)
      |> \.adjustsFontForContentSizeCategory .~ true

    _ = self.postTimeLabel
      |> \.numberOfLines .~ 2
      |> \.textColor .~ .ksr_support_400
      |> \.textAlignment .~ .left
      |> \.font .~ UIFont.ksr_footnote()
      |> \.adjustsFontForContentSizeCategory .~ true

    self.viewModel.inputs.bindStyles()
  }

  // MARK: - Configuration

  internal func configureWith(comment: Comment) {
    self.viewModel.inputs.configureWith(comment: comment, project: nil)
  }

  private func configureViews() {
    _ = ([self.circleAvatarImageView, self.authorNameTimeLabelsStackView], self)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.authorNameBadgeLabelsStackView, self.postTimeLabel], self.authorNameTimeLabelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.authorNameLabel, self.authorBadgeLabel, UIView()], self.authorNameBadgeLabelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.authorBadgeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

    NSLayoutConstraint.activate([
      self.circleAvatarImageView.widthAnchor.constraint(equalToConstant: Styles.grid(7)),
      self.circleAvatarImageView.heightAnchor.constraint(equalToConstant: Styles.grid(7))
    ])
  }

  private func configureUserBadgeStyle(from badge: Comment.AuthorBadge) {
    var style: PaddingLabelStyle = { $0 }
    var stackViewAlignment: UIStackView.Alignment = .center

    switch badge {
    case .collaborator, .creator:
      style = setStyleForCreatorAndCollaborator(
        text: badge == .creator
          ? Strings.Creator()
          : Strings.Collaborator()
      )
      stackViewAlignment = .center
    case .superbacker:
      style = superbackerAuthorBadgeStyle
      stackViewAlignment = .top
    case .you:
      style = youAuthorBadgeStyle
    default:
      style = resetTextStyle
    }

    _ = self.authorBadgeLabel
      |> authorBadgeLabelStyle
      |> style

    _ = self.authorNameBadgeLabelsStackView
      |> \.alignment .~ stackViewAlignment
  }

  // MARK: View Model

  override func bindViewModel() {
    self.viewModel.outputs.authorImageURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.circleAvatarImageView.af.cancelImageRequest()
        self?.circleAvatarImageView.image = nil
      })
      .observeValues { [weak self] url in
        self?.circleAvatarImageView
          .ksr_setImageWithURL(url)
      }

    self.viewModel.outputs.authorBadge
      .observeForUI()
      .observeValues(self.configureUserBadgeStyle)

    self.authorNameLabel.rac.text = self.viewModel.authorName
    self.postTimeLabel.rac.text = self.viewModel.postTime
  }
}

private func setStyleForCreatorAndCollaborator(text: String) -> PaddingLabelStyle {
  let style: PaddingLabelStyle = { label in
    label
      |> \.text .~ text
      |> \.font .~ UIFont.ksr_footnote()
      |> \.textColor .~ UIColor.ksr_create_700
      |> \.backgroundColor .~ UIColor.ksr_create_700.withAlphaComponent(0.06)
      |> roundedStyle(cornerRadius: Styles.grid(1))
      |> \.adjustsFontForContentSizeCategory .~ true
  }
  return style
}
