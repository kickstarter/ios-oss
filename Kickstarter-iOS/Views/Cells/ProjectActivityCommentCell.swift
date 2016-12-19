import Library
import KsApi
import Prelude
import Prelude_UIKit
import UIKit

internal protocol ProjectActivityCommentCellDelegate: class {
  func projectActivityCommentCellGoToBacking(project project: Project, user: User)
  func projectActivityCommentCellGoToSendReply(project project: Project, update: Update?, comment: Comment)
}

internal final class ProjectActivityCommentCell: UITableViewCell, ValueCell {
  private let viewModel: ProjectActivityCommentCellViewModelType = ProjectActivityCommentCellViewModel()
  internal weak var delegate: ProjectActivityCommentCellDelegate?

  @IBOutlet private weak var authorImageView: UIImageView!
  @IBOutlet private weak var backingButton: UIButton!
  @IBOutlet private weak var bodyLabel: UILabel!
  @IBOutlet private weak var bodyView: UIView!
  @IBOutlet private weak var bulletSeparatorView: UIView!
  @IBOutlet private weak var cardView: UIView!
  @IBOutlet private weak var containerStackView: UIStackView!
  @IBOutlet private weak var footerDividerView: UIView!
  @IBOutlet private weak var footerStackView: UIStackView!
  @IBOutlet private weak var headerDividerView: UIView!
  @IBOutlet private weak var headerStackView: UIStackView!
  @IBOutlet private weak var replyButton: UIButton!
  @IBOutlet private weak var titleLabel: UILabel!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    self.backingButton
      |> UIButton.lens.targets .~ [(self, #selector(backingButtonPressed), .TouchUpInside)]

    self.replyButton
      |> UIButton.lens.targets .~ [(self, #selector(replyButtonPressed), .TouchUpInside)]
  }

  internal func configureWith(value activityAndProject: (Activity, Project)) {
    self.viewModel.inputs.configureWith(activity: activityAndProject.0,
                                        project: activityAndProject.1)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.authorImageURL
      .observeForUI()
      .on(next: { [weak self] _ in
        self?.authorImageView.af_cancelImageRequest()
        self?.authorImageView.image = nil
        })
      .skipNil()
      .observeNext { [weak self] url in
        self?.authorImageView.af_setImageWithURL(url)
    }

    self.rac.accessibilityLabel = self.viewModel.outputs.cellAccessibilityLabel
    self.rac.accessibilityValue = self.viewModel.outputs.cellAccessibilityValue

    self.viewModel.outputs.notifyDelegateGoToBacking
      .observeForUI()
      .observeNext { [weak self] project, user in
        self?.delegate?.projectActivityCommentCellGoToBacking(project: project, user: user)
    }

    self.viewModel.outputs.notifyDelegateGoToSendReply
      .observeForUI()
      .observeNext { [weak self] project, update, comment in
        self?.delegate?.projectActivityCommentCellGoToSendReply(
          project: project, update: update, comment: comment
        )
    }

    self.bodyLabel.rac.text = self.viewModel.outputs.body

    self.viewModel.outputs.title.observeForUI()
      .observeNext { [weak titleLabel] title in
        guard let titleLabel = titleLabel else { return }

        titleLabel.attributedText = title.simpleHtmlAttributedString(font: .ksr_title3(size: 14),
          bold: UIFont.ksr_title3(size: 14).bolded,
          italic: nil
        )

        titleLabel |> projectActivityTitleLabelStyle
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> ProjectActivityCommentCell.lens.contentView.layoutMargins %~~ { layoutMargins, cell in
        cell.traitCollection.isRegularRegular
          ? projectActivityRegularRegularLayoutMargins
          : layoutMargins
      }
      |> UITableViewCell.lens.accessibilityHint %~ { _ in Strings.Opens_comments() }

    self.backingButton
      |> projectActivityFooterButton
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.dashboard_activity_pledge_info() }

    self.bodyLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.font %~~ { _, label in
          label.traitCollection.isRegularRegular
            ? UIFont.ksr_body()
            : UIFont.ksr_body(size: 14)
      }

    self.bodyView
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.grid(3), leftRight: Styles.grid(2))

    self.bulletSeparatorView
      |> projectActivityBulletSeparatorViewStyle

    self.cardView
      |> dropShadowStyle()

    self.footerDividerView
      |> projectActivityDividerViewStyle

    self.footerStackView
      |> projectActivityFooterStackViewStyle
      |> UIStackView.lens.layoutMargins .~ .init(all: Styles.grid(2))

    self.headerDividerView
      |> projectActivityDividerViewStyle

    self.headerStackView
      |> projectActivityHeaderStackViewStyle

    self.replyButton
      |> projectActivityFooterButton
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.dashboard_activity_reply() }
  }

  @objc private func backingButtonPressed(button: UIButton) {
    self.viewModel.inputs.backingButtonPressed()
  }

  @objc private func replyButtonPressed(button: UIButton) {
    self.viewModel.inputs.replyButtonPressed()
  }
}
