import Library
import KsApi
import Prelude
import UIKit

internal final class CommentCell: UITableViewCell, ValueCell {
  fileprivate let viewModel = CommentCellViewModel()

  @IBOutlet fileprivate weak var authorAndTimestampStackView: UIStackView!
  @IBOutlet fileprivate weak var authorStackView: UIStackView!
  @IBOutlet fileprivate weak var avatarImageView: UIImageView!
  @IBOutlet fileprivate weak var bodyTextView: UITextView!
  @IBOutlet fileprivate weak var commentStackView: UIStackView!
  @IBOutlet fileprivate weak var creatorLabel: UILabel!
  @IBOutlet fileprivate weak var creatorView: UIView!
  @IBOutlet fileprivate weak var nameLabel: UILabel!
  @IBOutlet fileprivate weak var rootStackView: UIStackView!
  @IBOutlet fileprivate weak var separatorView: UIView!
  @IBOutlet fileprivate weak var timestampLabel: UILabel!
  @IBOutlet fileprivate weak var youLabel: UILabel!
  @IBOutlet fileprivate weak var youView: UIView!

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> CommentCell.lens.contentView.layoutMargins .~
      .init(topBottom: Styles.grid(3), leftRight: Styles.grid(2))

    self.bodyTextView
      |> UITextView.lens.scrollEnabled .~ false
      |> UITextView.lens.textContainerInset .~ UIEdgeInsets.zero
      |> UITextView.lens.textContainer.lineFragmentPadding .~ 0

    self.authorAndTimestampStackView
      |> UIStackView.lens.spacing .~ Styles.gridHalf(1)

    self.authorStackView
      |> UIStackView.lens.spacing .~ Styles.gridHalf(1)

    self.commentStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    self.creatorLabel
      |> authorBadgeLabelStyle
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.text %~ { _ in Strings.update_comments_creator() }

    self.creatorView
      |> authorBadgeViewStyle
      |> UIView.lens.backgroundColor .~ .ksr_navy_700

    self.nameLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 16.0)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    self.rootStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    self.separatorView
      |> separatorStyle

    self.timestampLabel
      |> UILabel.lens.font .~ .ksr_body(size: 12.0)
      |> UILabel.lens.textColor .~ .ksr_text_navy_600

    self.youLabel
      |> authorBadgeLabelStyle
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.text %~ { _ in Strings.update_comments_you() }

    self.youView
      |> authorBadgeViewStyle
      |> UIView.lens.backgroundColor .~ .ksr_green_500
  }

  internal override func bindViewModel() {
    self.viewModel.outputs.avatarUrl
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.avatarImageView.af_cancelImageRequest()
        self?.avatarImageView.image = nil
        })
      .skipNil()
      .observeValues { [weak self] url in
        self?.avatarImageView.af_setImage(withURL: url)
    }

    self.viewModel.outputs.bodyColor
      .observeForUI()
      .observeValues { [weak self] color in
        self?.bodyTextView.textColor = color
    }

    self.viewModel.outputs.bodyFont
      .observeForUI()
      .observeValues { [weak self] font in
        self?.bodyTextView.font = font
    }

    self.bodyTextView.rac.text = self.viewModel.outputs.body
    self.creatorView.rac.hidden = self.viewModel.outputs.creatorHidden
    self.nameLabel.rac.text = self.viewModel.outputs.name
    self.timestampLabel.rac.text = self.viewModel.outputs.timestamp
    self.youView.rac.hidden = self.viewModel.outputs.youHidden
  }

  internal func configureWith(value: (Comment, Project, User?)) {
    self.viewModel.inputs.comment(value.0, project: value.1, viewer: value.2)
  }
}
