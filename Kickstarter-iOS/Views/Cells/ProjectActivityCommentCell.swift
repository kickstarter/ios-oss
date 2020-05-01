import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal protocol ProjectActivityCommentCellDelegate: AnyObject {
  func projectActivityCommentCellGoToBacking(project: Project, user: User)
  func projectActivityCommentCellGoToSendReply(project: Project, update: Update?, comment: Comment)
}

internal final class ProjectActivityCommentCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: ProjectActivityCommentCellViewModelType = ProjectActivityCommentCellViewModel()
  internal weak var delegate: ProjectActivityCommentCellDelegate?

  @IBOutlet fileprivate var authorImageView: UIImageView!
  @IBOutlet fileprivate var backingButton: UIButton!
  @IBOutlet fileprivate var bodyLabel: UILabel!
  @IBOutlet fileprivate var bodyView: UIView!
  @IBOutlet fileprivate var bulletSeparatorView: UIView!
  @IBOutlet fileprivate var cardView: UIView!
  @IBOutlet fileprivate var containerStackView: UIStackView!
  @IBOutlet fileprivate var footerDividerView: UIView!
  @IBOutlet fileprivate var footerStackView: UIStackView!
  @IBOutlet fileprivate var headerDividerView: UIView!
  @IBOutlet fileprivate var headerStackView: UIStackView!
  @IBOutlet fileprivate var replyButton: UIButton!
  @IBOutlet fileprivate var titleLabel: UILabel!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    _ = self.backingButton
      |> UIButton.lens.targets .~ [(self, #selector(self.backingButtonPressed), .touchUpInside)]

    _ = self.replyButton
      |> UIButton.lens.targets .~ [(self, #selector(self.replyButtonPressed), .touchUpInside)]
  }

  internal func configureWith(value activityAndProject: (Activity, Project)) {
    self.viewModel.inputs.configureWith(
      activity: activityAndProject.0,
      project: activityAndProject.1
    )
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.footerStackView.rac.hidden = self.viewModel.outputs.pledgeFooterIsHidden

    self.viewModel.outputs.authorImageURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.authorImageView.af.cancelImageRequest()
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

        titleLabel.attributedText = title.simpleHtmlAttributedString(
          base: [
            NSAttributedString.Key.font: UIFont.ksr_title3(size: 14),
            NSAttributedString.Key.foregroundColor: UIColor.ksr_text_dark_grey_400
          ],
          bold: [
            NSAttributedString.Key.font: UIFont.ksr_title3(size: 14),
            NSAttributedString.Key.foregroundColor: UIColor.ksr_soft_black
          ],
          italic: nil
        )
          ?? .init()
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

    _ = self.authorImageView
      |> ignoresInvertColorsImageViewStyle

    _ = self.backingButton
      |> projectActivityFooterButton
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.dashboard_activity_pledge_info() }

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
      |> dropShadowStyleMedium()

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
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.dashboard_activity_reply() }

    _ = self.titleLabel
      |> UILabel.lens.numberOfLines .~ 2
  }

  @objc fileprivate func backingButtonPressed(_: UIButton) {
    self.viewModel.inputs.backingButtonPressed()
  }

  @objc fileprivate func replyButtonPressed(_: UIButton) {
    self.viewModel.inputs.replyButtonPressed()
  }
}
