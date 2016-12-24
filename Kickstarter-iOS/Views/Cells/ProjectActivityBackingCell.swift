import Library
import KsApi
import Prelude
import Prelude_UIKit
import UIKit

internal protocol ProjectActivityBackingCellDelegate: class {
  func projectActivityBackingCellGoToBacking(project: Project, user: User)
  func projectActivityBackingCellGoToSendMessage(project: Project, backing: Backing)
}

internal final class ProjectActivityBackingCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: ProjectActivityBackingCellViewModelType = ProjectActivityBackingCellViewModel()
  internal weak var delegate: ProjectActivityBackingCellDelegate?

  @IBOutlet fileprivate weak var backerImageView: CircleAvatarImageView!
  @IBOutlet fileprivate weak var backingButton: UIButton!
  @IBOutlet fileprivate weak var bulletSeparatorView: UIView!
  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var footerDividerView: UIView!
  @IBOutlet fileprivate weak var footerStackView: UIStackView!
  @IBOutlet fileprivate weak var headerDividerView: UIView!
  @IBOutlet fileprivate weak var headerStackView: UIStackView!
  @IBOutlet fileprivate weak var pledgeAmountLabel: UILabel!
  @IBOutlet fileprivate weak var pledgeAmountLabelsStackView: UIStackView!
  @IBOutlet fileprivate weak var pledgeAmountsStackView: UIView!
  @IBOutlet fileprivate weak var pledgeDetailsSeparatorView: UIView!
  @IBOutlet fileprivate weak var pledgeDetailsStackView: UIStackView!
  @IBOutlet fileprivate weak var previousPledgeAmountLabel: UILabel!
  @IBOutlet fileprivate weak var previousPledgeStrikethroughView: UIView!
  @IBOutlet fileprivate weak var rewardLabel: UILabel!
  @IBOutlet fileprivate weak var sendMessageButton: UIButton!
  @IBOutlet fileprivate weak var titleLabel: UILabel!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    self.backingButton
      |> UIButton.lens.targets .~ [(self, #selector(backingButtonPressed), .touchUpInside)]

    self.sendMessageButton
      |> UIButton.lens.targets .~ [(self, #selector(sendMessageButtonPressed), .touchUpInside)]
  }

  internal func configureWith(value activityAndProject: (Activity, Project)) {
    self.viewModel.inputs.configureWith(activity: activityAndProject.0,
                                        project: activityAndProject.1)
  }

  // swiftlint:disable function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()

    self.rac.accessibilityLabel = self.viewModel.outputs.cellAccessibilityLabel
    self.rac.accessibilityValue = self.viewModel.outputs.cellAccessibilityValue

    self.viewModel.outputs.backerImageURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.backerImageView.af_cancelImageRequest()
        self?.backerImageView.image = nil
        })
      .skipNil()
      .observeValues { [weak self] url in
        self?.backerImageView.af_setImage(withURL: url)
    }

    self.viewModel.outputs.notifyDelegateGoToBacking
      .observeForUI()
      .observeValues { [weak self] project, user in
        self?.delegate?.projectActivityBackingCellGoToBacking(project: project, user: user)
    }

    self.viewModel.outputs.notifyDelegateGoToSendMessage
      .observeForUI()
      .observeValues { [weak self] project, backing in
        self?.delegate?.projectActivityBackingCellGoToSendMessage(project: project, backing: backing)
    }

    self.pledgeAmountLabel.rac.hidden = self.viewModel.outputs.pledgeAmountLabelIsHidden

    self.pledgeAmountLabel.rac.text = self.viewModel.outputs.pledgeAmount

    self.pledgeAmountsStackView.rac.hidden = self.viewModel.outputs.pledgeAmountsStackViewIsHidden

    self.pledgeDetailsSeparatorView.rac.hidden =
      self.viewModel.outputs.pledgeDetailsSeparatorStackViewIsHidden

    self.previousPledgeAmountLabel.rac.hidden = self.viewModel.outputs.previousPledgeAmountLabelIsHidden

    self.previousPledgeAmountLabel.rac.text = self.viewModel.outputs.previousPledgeAmount

    self.rewardLabel.rac.hidden = self.viewModel.outputs.rewardLabelIsHidden

    self.sendMessageButton.rac.hidden = self.viewModel.outputs.sendMessageButtonAndBulletSeparatorHidden

    self.bulletSeparatorView.rac.hidden = self.viewModel.outputs.sendMessageButtonAndBulletSeparatorHidden

    self.viewModel.outputs.reward.observeForUI()
      .observeValues { [weak rewardLabel] title in
        guard let rewardLabel = rewardLabel else { return }

        rewardLabel.attributedText = title.simpleHtmlAttributedString(
          font: .ksr_body(size: 12),
          bold: UIFont.ksr_body(size: 12).bolded,
          italic: nil
        )

        rewardLabel
          |> UILabel.lens.numberOfLines .~ 0
          |> UILabel.lens.textColor .~ .ksr_text_navy_600
    }

    self.viewModel.outputs.title.observeForUI()
      .observeValues { [weak titleLabel] title in
        guard let titleLabel = titleLabel else { return }

        titleLabel.attributedText = title.simpleHtmlAttributedString(font: .ksr_title3(size: 14),
          bold: UIFont.ksr_title3(size: 14).bolded,
          italic: nil
        )

        titleLabel |> projectActivityTitleLabelStyle
    }
  }
  // swiftlint:enable function_body_length

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> ProjectActivityBackingCell.lens.contentView.layoutMargins %~~ { layoutMargins, cell in
        cell.traitCollection.isRegularRegular
          ? projectActivityRegularRegularLayoutMargins
          : layoutMargins
      }
      |> UITableViewCell.lens.accessibilityHint %~ { _ in Strings.Opens_pledge_info() }

    self.backingButton
      |> projectActivityFooterButton
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.dashboard_activity_pledge_info() }

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

    self.pledgeAmountLabel
      |> UILabel.lens.textColor .~ .ksr_text_green_700
      |> UILabel.lens.font .~ .ksr_callout(size: 24)

    self.pledgeAmountLabelsStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    self.pledgeDetailsStackView
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: Styles.grid(3), leftRight: Styles.grid(2))
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true

    self.previousPledgeAmountLabel
      |> UILabel.lens.font .~ .ksr_callout(size: 24)
      |> UILabel.lens.textColor .~ .ksr_navy_500

    self.previousPledgeStrikethroughView
      |> UIView.lens.backgroundColor .~ .ksr_navy_500

    self.sendMessageButton
      |> projectActivityFooterButton
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.dashboard_activity_send_message() }
  }

  @objc fileprivate func backingButtonPressed(_ button: UIButton) {
    self.viewModel.inputs.backingButtonPressed()
  }

  @objc fileprivate func sendMessageButtonPressed(_ button: UIButton) {
    self.viewModel.inputs.sendMessageButtonPressed()
  }
}
