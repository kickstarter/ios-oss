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
  @IBOutlet private weak var backerShippingAmountLabel: UILabel!
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

  internal static func configuredWith(project project: Project, backer: User?) -> BackingViewController {
    let vc = Storyboard.Backing.instantiate(BackingViewController)
    vc.viewModel.inputs.configureWith(project: project, backer: backer)
    return vc
  }

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

    self
      |> baseControllerStyle()
      |> UIViewController.lens.title %~ { _ in Strings.project_view_button() }

    self.backerPledgeAmountAndDateLabel |> UILabel.lens.font .~ .ksr_body()
    self.backerPledgeStatusLabel |> UILabel.lens.font .~ .ksr_body()
    self.backerRewardDescriptionLabel |> UILabel.lens.font .~ .ksr_body()
    self.backerSequenceLabel |> UILabel.lens.font .~ .ksr_subhead()
    self.backerShippingAmountLabel |> UILabel.lens.font .~ .ksr_body()
    self.backerShippingDescriptionLabel |> UILabel.lens.font .~ .ksr_body()
    self.backerAvatarImageView |> UIImageView.lens.accessibilityElementsHidden .~ true

    self.messageCreatorButton
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.social_message_creator() }
      |> greenButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.social_message_creator() }
      |> UIButton.lens.accessibilityHint %~ {  _ in "Opens message creator." }

    self.pledgedLabel
      |> UILabel.lens.font .~ .ksr_headline()
      |> UILabel.lens.text %~ { _ in Strings.backer_modal_pledged_title() }
      |> UILabel.lens.accessibilityLabel %~ { _ in Strings.backer_modal_pledged_title() }

    self.rewardLabel
      |> UILabel.lens.font .~ .ksr_headline()
      |> UILabel.lens.text %~ { _ in Strings.backer_modal_reward_title() }
      |> UILabel.lens.accessibilityLabel %~ { _ in Strings.backer_modal_reward_title() }

    self.rewardSeperatorView |> separatorStyle

    self.rootStackView
      |> UIStackView.lens.layoutMargins .~ UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true

    self.shippingLabel
      |> UILabel.lens.font .~ .ksr_headline()
      |> UILabel.lens.text %~ { _ in Strings.backer_modal_shipping_title() }
      |> UILabel.lens.accessibilityLabel %~ { _ in Strings.backer_modal_shipping_title() }

    self.shippingSeperatorView |> separatorStyle

    self.viewMessagesButton
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.backer_modal_view_messages() }
      |> neutralButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.backer_modal_view_messages() }
      |> UIButton.lens.accessibilityHint %~ {  _ in "Opens messages." }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.backerNameLabel.rac.text = self.viewModel.outputs.backerName
    self.backerNameLabel.rac.accessibilityLabel = self.viewModel.outputs.backerNameAccessibilityLabel
    self.backerPledgeAmountAndDateLabel.rac.text = self.viewModel.outputs.backerPledgeAmountAndDate
    self.backerPledgeAmountAndDateLabel.rac.accessibilityLabel =
      self.viewModel.outputs.backerPledgeAmountAndDateAccessibilityLabel
    self.backerPledgeStatusLabel.rac.text = self.viewModel.outputs.backerPledgeStatus
    self.backerPledgeStatusLabel.rac.accessibilityLabel =
      self.viewModel.outputs.backerPledgeStatusAccessibilityLabel
    self.backerRewardDescriptionLabel.rac.text = self.viewModel.outputs.backerRewardDescription
    self.backerRewardDescriptionLabel.rac.accessibilityLabel =
      self.viewModel.outputs.backerRewardDescriptionAccessibilityLabel
    self.backerSequenceLabel.rac.text = self.viewModel.outputs.backerSequence
    self.backerSequenceLabel.rac.accessibilityLabel =
      self.viewModel.outputs.backerSequenceAccessibilityLabel
    self.backerShippingAmountLabel.rac.text = self.viewModel.outputs.backerShippingAmount
    self.backerShippingAmountLabel.rac.accessibilityLabel =
      self.viewModel.outputs.backerShippingAmountAccessibilityLabel
    self.backerShippingDescriptionLabel.rac.text = self.viewModel.outputs.backerShippingDescription
    self.backerShippingDescriptionLabel.rac.accessibilityLabel =
      self.viewModel.outputs.backerShippingDescriptionAccessibilityLabel

    self.viewModel.outputs.backerAvatarURL
      .observeForControllerAction()
      .on(next: { [weak backerAvatarImageView] _ in
        backerAvatarImageView?.af_cancelImageRequest()
        backerAvatarImageView?.image = nil
        })
      .ignoreNil()
      .observeNext { [weak backerAvatarImageView] url in
        backerAvatarImageView?.af_setImageWithURL(url)
    }

    self.viewModel.outputs.goToMessages
      .observeForControllerAction()
      .observeNext { [weak self] project, backing in
        self?.goToMessages(project: project, backing: backing)
    }

    self.viewModel.outputs.goToMessageCreator
      .observeForControllerAction()
      .observeNext { [weak self] messageSubject, context in
        self?.goToMessageCreator(messageSubject: messageSubject, context: context)
    }
  }

  @objc private func messageCreatorTapped(button: UIButton) {
    self.viewModel.inputs.messageCreatorTapped()
  }

  @objc private func viewMessagesTapped(button: UIButton) {
    self.viewModel.inputs.viewMessagesTapped()
  }

  private func goToMessages(project project: Project, backing: Backing) {
    let vc = MessagesViewController.configuredWith(project: project, backing: backing)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func goToMessageCreator(messageSubject messageSubject: MessageSubject,
                                                 context: Koala.MessageDialogContext) {
    let vc = MessageDialogViewController.configuredWith(messageSubject: messageSubject, context: context)
    vc.modalPresentationStyle = .FormSheet
    vc.delegate = self
    self.presentViewController(UINavigationController(rootViewController: vc),
                               animated: true,
                               completion: nil)
  }
}

extension BackingViewController: MessageDialogViewControllerDelegate {
  internal func messageDialogWantsDismissal(dialog: MessageDialogViewController) {
    dialog.dismissViewControllerAnimated(true, completion: nil)
  }

  internal func messageDialog(dialog: MessageDialogViewController, postedMessage message: Message) {
  }
}
