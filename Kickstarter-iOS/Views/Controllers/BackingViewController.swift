import KsApi
import Library
import Prelude
import Prelude_UIKit
import ReactiveCocoa
import UIKit

internal final class BackingViewController: UIViewController {
  @IBOutlet private weak var actionsStackView: UIStackView!
  @IBOutlet private weak var backerAvatarImageView: UIImageView!
  @IBOutlet private weak var backerNameLabel: UILabel!
  @IBOutlet private weak var backerPledgeAmountAndDateLabel: UILabel!
  @IBOutlet private weak var backerPledgeStatusLabel: UILabel!
  @IBOutlet private weak var backerRewardDescriptionLabel: UILabel!
  @IBOutlet private weak var backerSequenceLabel: UILabel!
  @IBOutlet private weak var backerShippingCostLabel: UILabel!
  @IBOutlet private weak var backerShippingDescriptionLabel: UILabel!
  @IBOutlet private weak var messageCreatorButton: UIButton!
  @IBOutlet private weak var pledgedLabel: UILabel!
  @IBOutlet private weak var rewardLabel: UILabel!
  @IBOutlet private weak var rewardSeperatorView: UIView!
  @IBOutlet private weak var rootStackView: UIStackView!
  @IBOutlet private weak var shippingLabel: UILabel!
  @IBOutlet private weak var shippingSeperatorView: UIView!
  @IBOutlet private weak var viewMessagesButton: UIButton!

  private let viewModel: BackingViewModelType = BackingViewModel()

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.messageCreatorButton
      |> UIButton.lens.targets .~ [(self, #selector(messageCreatorTapped), .TouchUpInside)]

    self.viewMessagesButton
      |> UIButton.lens.targets .~ [(self, #selector(viewMessagesTapped), .TouchUpInside)]

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    self.actionsStackView
      |> UIStackView.lens.axis %~ {_ in AppEnvironment.current.language == .en ? .Horizontal : .Vertical }

    self |> baseControllerStyle()

    self.backerPledgeAmountAndDateLabel |> UILabel.lens.font .~ .ksr_body()
    self.backerPledgeStatusLabel |> UILabel.lens.font .~ .ksr_body()
    self.backerRewardDescriptionLabel |> UILabel.lens.font .~ .ksr_body()
    self.backerSequenceLabel |> UILabel.lens.font .~ .ksr_subhead()
    self.backerShippingCostLabel |> UILabel.lens.font .~ .ksr_body()
    self.backerShippingDescriptionLabel |> UILabel.lens.font .~ .ksr_body()

    self.messageCreatorButton
      |> UIButton.lens.titleText(forState: .Normal) %~ { _ in Strings.social_message_creator() }
      |> greenButtonStyle

    self.pledgedLabel
      |> UILabel.lens.font .~ .ksr_headline()
      |> UILabel.lens.text %~ { _ in Strings.backer_modal_pledged_title() }

    self.rewardLabel
      |> UILabel.lens.font .~ .ksr_headline()
      |> UILabel.lens.text %~ { _ in Strings.backer_modal_reward_title() }

    self.rewardSeperatorView |> separatorStyle

    self.rootStackView
      |> UIStackView.lens.layoutMargins .~ UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true

    self.shippingLabel
      |> UILabel.lens.font .~ .ksr_headline()
      |> UILabel.lens.text %~ { _ in Strings.backer_modal_shipping_title() }

    self.shippingSeperatorView |> separatorStyle

    self.viewMessagesButton
      |> UIButton.lens.titleText(forState: .Normal) %~ { _ in Strings.backer_modal_view_messages() }
      |> neutralButtonStyle
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.backerNameLabel.rac.text = self.viewModel.outputs.backerName
    self.backerPledgeAmountAndDateLabel.rac.text = self.viewModel.outputs.backerPledgeAmountAndDate
    self.backerPledgeStatusLabel.rac.text = self.viewModel.outputs.backerPledgeStatus
    self.backerRewardDescriptionLabel.rac.text = self.viewModel.outputs.backerRewardDescription
    self.backerSequenceLabel.rac.text = self.viewModel.outputs.backerSequence
    self.backerShippingDescriptionLabel.rac.text = self.viewModel.outputs.backerShippingDescription
    self.backerShippingCostLabel.rac.text = self.viewModel.outputs.backerShippingCost

    self.viewModel.outputs.backerAvatarURL
      .observeForUI()
      .on(next: { [weak backerAvatarImageView] _ in
        backerAvatarImageView?.af_cancelImageRequest()
        backerAvatarImageView?.image = nil
        })
      .ignoreNil()
      .observeNext { [weak backerAvatarImageView] url in
        backerAvatarImageView?.af_setImageWithURL(url)
    }

    self.viewModel.outputs.goToMessages
      .observeForUI()
      .observeNext { [weak self] project, backing in
        self?.goToMessages(project: project, backing: backing)
    }
  }

  internal func configureWith(project project: Project, backer: User?) {
    self.viewModel.inputs.configureWith(project: project, backer: backer)
  }

  @objc private func messageCreatorTapped(button: UIButton) {
    self.viewModel.inputs.messageCreatorTapped()
  }

  @objc private func viewMessagesTapped(button: UIButton) {
    self.viewModel.inputs.viewMessagesTapped()
  }

  private func goToMessages(project project: Project, backing: Backing) {
    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MessagesViewController")

    if let messages = vc as? MessagesViewController {
      messages.configureWith(project: project, backing: backing)
      self.navigationController?.pushViewController(messages, animated: true)
    }
  }
}
