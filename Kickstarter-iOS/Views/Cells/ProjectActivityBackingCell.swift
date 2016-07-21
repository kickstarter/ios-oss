import Library
import KsApi
import Prelude
import Prelude_UIKit
import UIKit

internal final class ProjectActivityBackingCell: UITableViewCell, ValueCell {
  private let viewModel: ProjectActivityBackingCellViewModelType = ProjectActivityBackingCellViewModel()

  @IBOutlet private weak var backerImageView: CircleAvatarImageView!
  @IBOutlet private weak var bulletSeparatorView: UIView!
  @IBOutlet private weak var cardView: UIView!
  @IBOutlet private weak var footerDividerView: UIView!
  @IBOutlet private weak var footerStackView: UIStackView!
  @IBOutlet private weak var headerDividerView: UIView!
  @IBOutlet private weak var headerStackView: UIStackView!
  @IBOutlet private weak var pledgeAmountLabel: UILabel!
  @IBOutlet private weak var pledgeAmountLabelsStackView: UIStackView!
  @IBOutlet private weak var pledgeAmountsStackView: UIView!
  @IBOutlet private weak var pledgeDetailsStackView: UIStackView!
  @IBOutlet private weak var pledgeInfoButton: UIButton!
  @IBOutlet private weak var previousPledgeAmountLabel: UILabel!
  @IBOutlet private weak var previousPledgeStrikethroughView: UIView!
  @IBOutlet private weak var rewardLabel: UILabel!
  @IBOutlet private weak var sendMessageButton: UIButton!
  @IBOutlet private weak var titleLabel: UILabel!

  internal func configureWith(value activityAndProject: (Activity, Project)) {
    self.viewModel.inputs.configureWith(activity: activityAndProject.0,
                                        project: activityAndProject.1)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.backerImageURL
      .observeForUI()
      .on(next: { [weak self] _ in
        self?.backerImageView.af_cancelImageRequest()
        self?.backerImageView.image = nil
        })
      .ignoreNil()
      .observeNext { [weak self] url in
        self?.backerImageView.af_setImageWithURL(url)
    }

    self.pledgeAmountLabel.rac.hidden = self.viewModel.outputs.pledgeAmountLabelIsHidden

    self.pledgeAmountLabel.rac.text = self.viewModel.outputs.pledgeAmount

    self.pledgeAmountsStackView.rac.hidden = self.viewModel.outputs.pledgeAmountsStackViewIsHidden

    self.previousPledgeAmountLabel.rac.hidden = self.viewModel.outputs.previousPledgeAmountLabelIsHidden

    self.previousPledgeAmountLabel.rac.text = self.viewModel.outputs.previousPledgeAmount

    self.viewModel.outputs.reward.observeForUI()
      .observeNext { [weak rewardLabel] title in
        guard let rewardLabel = rewardLabel else { return }

        rewardLabel.attributedText = title.simpleHtmlAttributedString(font: .ksr_body(size: 12),
          bold: UIFont.ksr_body(size: 12).bolded,
          italic: nil
        )

        rewardLabel
          |> UILabel.lens.numberOfLines .~ 0
          |> UILabel.lens.textColor .~ .ksr_text_navy_600
    }

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

    self.bulletSeparatorView |> projectActivityBulletSeparatorViewStyle

    self.cardView |> projectActivityCardStyle

    self.footerStackView |> projectActivityFooterStackViewStyle

    self.footerDividerView |> projectActivityDividerViewStyle

    self.headerDividerView |> projectActivityDividerViewStyle

    self.headerStackView |> projectActivityHeaderStackViewStyle

    self.pledgeAmountLabel
      |> UILabel.lens.textColor .~ .ksr_text_green_700
      |> UILabel.lens.font .~ .ksr_callout(size: 24)

    self.pledgeAmountLabelsStackView |> UIStackView.lens.spacing .~ 10

    self.pledgeDetailsStackView
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: 14, leftRight: 12)
      <> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      <> UIStackView.lens.spacing .~ 10

    self.pledgeInfoButton
      |> projectActivityFooterButton
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.dashboard_activity_pledge_info() }

    self.previousPledgeAmountLabel
      |> UILabel.lens.font .~ .ksr_callout(size: 24)
      |> UILabel.lens.textColor .~ .ksr_navy_500

    self.previousPledgeStrikethroughView |> UIView.lens.backgroundColor .~ .ksr_navy_500

    self.sendMessageButton
      |> projectActivityFooterButton
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.dashboard_activity_send_message() }
  }
}
