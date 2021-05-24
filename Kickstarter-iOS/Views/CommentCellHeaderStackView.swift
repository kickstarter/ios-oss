import KsApi
import Library
import Prelude
import UIKit

internal final class CommentCellHeaderStackView: UIStackView {
  // MARK: - Properties

  fileprivate let viewModel = CommentCellViewModel()

  private lazy var circleAvatarImageView = { CircleAvatarImageView(frame: .zero)
    |> \.backgroundColor .~ .ksr_support_100
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var authorNameLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var authorBadgeLabel: PaddingLabel = { PaddingLabel(frame: .zero) }()
  private lazy var authorNameBadgeLabelsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var authorNameTimeLabelsStackView: UIStackView = { UIStackView(frame: .zero) }()
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

    _ = self.authorBadgeLabel
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

  internal func configureWith(comment: Comment, user: User?) {
    self.viewModel.inputs.configureWith(comment: comment, viewer: user)
  }

  private func configureViews() {
    _ = ([self.circleAvatarImageView, self.authorNameTimeLabelsStackView], self)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.authorNameBadgeLabelsStackView, self.postTimeLabel], self.authorNameTimeLabelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.authorNameLabel, self.authorBadgeLabel, UIView()], self.authorNameBadgeLabelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.authorBadgeLabel.setContentCompressionResistancePriority(.init(1_000), for: .horizontal)
    self.authorBadgeLabel.setContentHuggingPriority(.init(1_000), for: .horizontal)

    NSLayoutConstraint.activate([
      self.circleAvatarImageView.widthAnchor.constraint(equalToConstant: Styles.grid(7)),
      self.circleAvatarImageView.heightAnchor.constraint(equalToConstant: Styles.grid(7))
    ])
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

    self.viewModel.outputs.authorBadgeStyleStackViewAligment
      .observeForUI()
      .observeValues { [weak self] authorBadgeLabelStyle, stackViewAlignment in
        guard let self = self else { return }
        _ = self.authorBadgeLabel
          |> authorBadgeLabelStyle

        _ = self.authorNameBadgeLabelsStackView
          |> \.alignment .~ stackViewAlignment
      }

    self.authorNameLabel.rac.text = self.viewModel.authorName
    self.postTimeLabel.rac.text = self.viewModel.postTime
  }
}
