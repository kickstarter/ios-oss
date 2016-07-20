import Library
import KsApi
import Prelude
import Prelude_UIKit
import UIKit

internal final class ProjectActivityCommentCell: UITableViewCell, ValueCell {
  private let viewModel: ProjectActivityCommentCellViewModelType = ProjectActivityCommentCellViewModel()

  @IBOutlet private weak var addCommentButton: UIButton!
  @IBOutlet private weak var authorImageView: UIImageView!
  @IBOutlet private weak var bodyLabel: UILabel!
  @IBOutlet private weak var bodyView: UIView!
  @IBOutlet private weak var bulletSeparatorView: UIView!
  @IBOutlet private weak var cardView: UIView!
  @IBOutlet private weak var footerDividerView: UIView!
  @IBOutlet private weak var footerStackView: UIStackView!
  @IBOutlet private weak var headerDividerView: UIView!
  @IBOutlet private weak var headerStackView: UIStackView!
  @IBOutlet private weak var pledgeInfoButton: UIButton!
  @IBOutlet private weak var titleLabel: UILabel!

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
      .ignoreNil()
      .observeNext { [weak self] url in
        self?.authorImageView.af_setImageWithURL(url)
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

    self |> baseTableViewCellStyle()

    self.addCommentButton
      |> projectActivityFooterButton
      |> UIButton.lens.titleText(forState: .Normal) %~ { _ in Strings.dashboard_activity_reply() }

    self.bodyLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.font .~ .ksr_body(size: 14)

    self.bodyView |> UIView.lens.layoutMargins .~ .init(topBottom: 20, leftRight: 12)

    self.bulletSeparatorView |> projectActivityBulletSeparatorViewStyle

    self.cardView |> projectActivityCardStyle

    self.footerDividerView |> projectActivityDividerViewStyle

    self.footerStackView |> projectActivityFooterStackViewStyle

    self.headerDividerView |> projectActivityDividerViewStyle

    self.headerStackView |> projectActivityHeaderStackViewStyle

    self.pledgeInfoButton
      |> projectActivityFooterButton
      |> UIButton.lens.titleText(forState: .Normal) %~ { _ in Strings.dashboard_activity_pledge_info() }
  }
}
