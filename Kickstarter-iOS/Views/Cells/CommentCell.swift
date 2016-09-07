import Library
import KsApi
import Prelude
import UIKit

internal final class CommentCell: UITableViewCell, ValueCell {
  private let viewModel = CommentCellViewModel()

  @IBOutlet internal weak var authorAndTimestampStackView: UIStackView!
  @IBOutlet internal weak var authorStackView: UIStackView!
  @IBOutlet internal weak var avatarImageView: UIImageView!
  @IBOutlet internal weak var bodyLabel: UILabel!
  @IBOutlet internal weak var commentStackView: UIStackView!
  @IBOutlet internal weak var creatorLabel: UILabel!
  @IBOutlet internal weak var creatorView: UIView!
  @IBOutlet internal weak var nameLabel: UILabel!
  @IBOutlet internal weak var rootStackView: UIStackView!
  @IBOutlet internal weak var timestampLabel: UILabel!
  @IBOutlet internal weak var youLabel: UILabel!
  @IBOutlet internal weak var youView: UIView!

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> CommentCell.lens.contentView.layoutMargins .~
      .init(topBottom: Styles.grid(3), leftRight: Styles.grid(2))

    self.authorAndTimestampStackView
      |> UIStackView.lens.spacing .~ Styles.gridHalf()

    self.authorStackView
      |> UIStackView.lens.spacing .~ Styles.gridHalf()

    self.commentStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    self.creatorLabel
      |> authorBadgeLabelStyle
      |> UILabel.lens.textColor .~ .whiteColor()
      |> UILabel.lens.text %~ { _ in Strings.update_comments_creator() }

    self.creatorView
      |> authorBadgeViewStyle
      |> UIView.lens.backgroundColor .~ .ksr_navy_700

    self.nameLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 16.0)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    self.rootStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    self.timestampLabel
      |> UILabel.lens.font .~ .ksr_body(size: 12.0)
      |> UILabel.lens.textColor .~ .ksr_text_navy_600

    self.youLabel
      |> authorBadgeLabelStyle
      |> UILabel.lens.textColor .~ .whiteColor()
      |> UILabel.lens.text %~ { _ in Strings.update_comments_you() }

    self.youView
      |> authorBadgeViewStyle
      |> UIView.lens.backgroundColor .~ .ksr_green_500
  }

  internal override func bindViewModel() {
    self.viewModel.outputs.avatarUrl
      .observeForUI()
      .on(next: { [weak self] _ in
        self?.avatarImageView.af_cancelImageRequest()
        self?.avatarImageView.image = nil
        })
      .ignoreNil()
      .observeNext { [weak self] url in
        self?.avatarImageView.af_setImageWithURL(url)
    }

    self.bodyLabel.rac.text = self.viewModel.outputs.body
    self.bodyLabel.rac.textColor = self.viewModel.outputs.bodyColor
    self.bodyLabel.rac.font = self.viewModel.outputs.bodyFont
    self.creatorView.rac.hidden = self.viewModel.outputs.creatorHidden
    self.nameLabel.rac.text = self.viewModel.outputs.name
    self.timestampLabel.rac.text = self.viewModel.outputs.timestamp
    self.youView.rac.hidden = self.viewModel.outputs.youHidden
  }

  internal func configureWith(value value: (Comment, Project, User?)) {
    self.viewModel.inputs.comment(value.0, project: value.1, viewer: value.2)
  }
}
