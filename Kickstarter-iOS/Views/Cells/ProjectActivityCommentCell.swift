import Library
import KsApi
import Prelude
import Prelude_UIKit
import UIKit

internal protocol ProjectActivityCommentCellDelegate: class {
  func projectActivityCommentCellGoToBacking(project: Project, user: User)
  func projectActivityCommentCellGoToSendReply(project: Project, update: Update?, comment: Comment)
}

internal final class ProjectActivityCommentCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: ProjectActivityCommentCellViewModelType = ProjectActivityCommentCellViewModel()
  internal weak var delegate: ProjectActivityCommentCellDelegate?

  @IBOutlet fileprivate weak var authorImageView: UIImageView!
  @IBOutlet fileprivate weak var backingButton: UIButton!
  @IBOutlet fileprivate weak var bodyLabel: UILabel!
  @IBOutlet fileprivate weak var bodyView: UIView!
  @IBOutlet fileprivate weak var bulletSeparatorView: UIView!
  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var containerStackView: UIStackView!
  @IBOutlet fileprivate weak var footerDividerView: UIView!
  @IBOutlet fileprivate weak var footerStackView: UIStackView!
  @IBOutlet fileprivate weak var headerDividerView: UIView!
  @IBOutlet fileprivate weak var headerStackView: UIStackView!
  @IBOutlet fileprivate weak var replyButton: UIButton!
  @IBOutlet fileprivate weak var titleLabel: UILabel!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    _ = self.backingButton
      |> UIButton.lens.targets .~ [(self, #selector(backingButtonPressed), .touchUpInside)]

    _ = self.replyButton
      |> UIButton.lens.targets .~ [(self, #selector(replyButtonPressed), .touchUpInside)]
  }

  internal func configureWith(value activityAndProject: (Activity, Project)) {
    self.viewModel.inputs.configureWith(activity: activityAndProject.0,
                                        project: activityAndProject.1)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.footerStackView.rac.hidden = self.viewModel.outputs.pledgeFooterIsHidden

    self.viewModel.outputs.authorImageURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.authorImageView.af_cancelImageRequest()
        self?.authorImageView.image = nil
        })
      .skipNil()
      .observeValues { [weak self] url in
        self?.authorImageView.ksr_setImageWithURL(url)
    }

    self.rac.accessibilityLabel = self.viewModel.outputs.cellAccessibilityLabel
    self.rac.accessibilityValue = self.viewModel.outputs.cellAccessibilityValue

    self.viewModel.outputs.notifyDelegateGoToBacking
      .observeForUI()
      .observeValues { [weak self] project, user in
        self?.delegate?.projectActivityCommentCellGoToBacking(project: project, user: user)
    }

    self.viewModel.outputs.notifyDelegateGoToSendReply
      .observeForUI()
      .observeValues { [weak self] project, update, comment in
        self?.delegate?.projectActivityCommentCellGoToSendReply(
          project: project, update: update, comment: comment
        )
    }

    self.bodyLabel.rac.text = self.viewModel.outputs.body

    self.viewModel.outputs.title
      .observeForUI()
      .observeValues { [weak titleLabel] title in
        guard let titleLabel = titleLabel else { return }

        titleLabel.attributedText = title.simpleHtmlAttributedString(font: .ksr_title3(size: 14),
          bold: UIFont.ksr_title3(size: 14).bolded,
          italic: nil
        )

        _ = titleLabel |> projectActivityTitleLabelStyle
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> ProjectActivityCommentCell.lens.contentView.layoutMargins %~~ { layoutMargins, cell in
        cell.traitCollection.isRegularRegular
          ? projectActivityRegularRegularLayoutMargins
          : layoutMargins
      }
      |> UITableViewCell.lens.accessibilityHint %~ { _ in Strings.Opens_comments() }

    _ = self.backingButton
      |> projectActivityFooterButton
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.dashboard_activity_pledge_info() }

    _ = self.bodyLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_500
      |> UILabel.lens.font %~~ { _, label in
          label.traitCollection.isRegularRegular
            ? UIFont.ksr_body()
            : UIFont.ksr_body(size: 14)
      }

    _ = self.bodyView
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.grid(3), leftRight: Styles.grid(2))

    _ = self.bulletSeparatorView
      |> projectActivityBulletSeparatorViewStyle

    _ = self.cardView
      |> dropShadowStyle()

    _ = self.footerDividerView
      |> projectActivityDividerViewStyle

    _ = self.footerStackView
      |> projectActivityFooterStackViewStyle
      |> UIStackView.lens.layoutMargins .~ .init(all: Styles.grid(2))

    _ = self.headerDividerView
      |> projectActivityDividerViewStyle

    _ = self.headerStackView
      |> projectActivityHeaderStackViewStyle

    _ = self.replyButton
      |> projectActivityFooterButton
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.dashboard_activity_reply() }
  }

  @objc fileprivate func backingButtonPressed(_ button: UIButton) {
    self.viewModel.inputs.backingButtonPressed()
  }

  @objc fileprivate func replyButtonPressed(_ button: UIButton) {
    self.viewModel.inputs.replyButtonPressed()
  }
}
