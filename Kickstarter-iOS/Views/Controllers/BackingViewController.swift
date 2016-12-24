import KsApi
import Library
import Prelude
import Prelude_UIKit
import ReactiveSwift
import UIKit

internal final class BackingViewController: UIViewController {
  @IBOutlet fileprivate weak var actionsStackView: UIStackView!
  @IBOutlet fileprivate weak var backerAvatarImageView: UIImageView!
  @IBOutlet fileprivate weak var backerNameLabel: UILabel!
  @IBOutlet fileprivate weak var backerPledgeAmountAndDateLabel: UILabel!
  @IBOutlet fileprivate weak var backerPledgeStatusLabel: UILabel!
  @IBOutlet fileprivate weak var backerRewardDescriptionLabel: UILabel!
  @IBOutlet fileprivate weak var backerSequenceLabel: UILabel!
  @IBOutlet fileprivate weak var backerShippingAmountLabel: UILabel!
  @IBOutlet fileprivate weak var backerShippingDescriptionLabel: UILabel!
  @IBOutlet fileprivate weak var messageCreatorButton: UIButton!
  @IBOutlet fileprivate weak var pledgedLabel: UILabel!
  @IBOutlet fileprivate weak var rewardLabel: UILabel!
  @IBOutlet fileprivate weak var rewardSeperatorView: UIView!
  @IBOutlet fileprivate weak var rootStackView: UIStackView!
  @IBOutlet fileprivate weak var shippingLabel: UILabel!
  @IBOutlet fileprivate weak var shippingSeperatorView: UIView!
  @IBOutlet fileprivate weak var viewMessagesButton: UIButton!

  fileprivate let viewModel: BackingViewModelType = BackingViewModel()

  internal static func configuredWith(project: Project, backer: User?) -> BackingViewController {
    let vc = Storyboard.Backing.instantiate(BackingViewController)
    vc.viewModel.inputs.configureWith(project: project, backer: backer)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.messageCreatorButton
      |> UIButton.lens.targets .~ [(self, #selector(messageCreatorTapped), .touchUpInside)]

    self.viewMessagesButton
      |> UIButton.lens.targets .~ [(self, #selector(viewMessagesTapped), .touchUpInside)]

    self.viewModel.inputs.viewDidLoad()

    if self.traitCollection.userInterfaceIdiom == .pad {
      self.navigationItem.leftBarButtonItem = .close(self, selector: #selector(closeButtonTapped))
    }
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  internal override func bindStyles() {
    super.bindStyles()

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
      |> greenButtonStyle
      |> UIButton.lens.accessibilityHint %~ {  _ in Strings.Opens_message_composer() }

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
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.backer_modal_view_messages() }
      |> neutralButtonStyle
      |> UIButton.lens.accessibilityHint %~ { _ in Strings.accessibility_dashboard_buttons_messages_hint() }
  }

  internal override func bindViewModel() {
    super.bindViewModel()
    self.actionsStackView.rac.hidden = self.viewModel.outputs.hideActionsStackView
    self.actionsStackView.rac.axis = self.viewModel.outputs.rootStackViewAxis
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
    self.messageCreatorButton.rac.title = self.viewModel.outputs.messageButtonTitleText

    self.viewModel.outputs.backerAvatarURL
      .observeForControllerAction()
      .on(event: { [weak backerAvatarImageView] _ in
        backerAvatarImageView?.af_cancelImageRequest()
        backerAvatarImageView?.image = nil
        })
      .skipNil()
      .observeValues { [weak backerAvatarImageView] url in
        backerAvatarImageView?.af_setImageWithURL(url)
    }

    self.viewModel.outputs.goToMessages
      .observeForControllerAction()
      .observeValues { [weak self] project, backing in
        self?.goToMessages(project: project, backing: backing)
    }

    self.viewModel.outputs.goToMessageCreator
      .observeForControllerAction()
      .observeValues { [weak self] messageSubject, context in
        self?.goToMessageCreator(messageSubject: messageSubject, context: context)
    }
  }

  @objc fileprivate func messageCreatorTapped(_ button: UIButton) {
    self.viewModel.inputs.messageCreatorTapped()
  }

  @objc fileprivate func viewMessagesTapped(_ button: UIButton) {
    self.viewModel.inputs.viewMessagesTapped()
  }

  fileprivate func goToMessages(project: Project, backing: Backing) {
    let vc = MessagesViewController.configuredWith(project: project, backing: backing)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  fileprivate func goToMessageCreator(messageSubject: MessageSubject,
                                                 context: Koala.MessageDialogContext) {
    let vc = MessageDialogViewController.configuredWith(messageSubject: messageSubject, context: context)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet
    vc.delegate = self
    self.present(nav, animated: true, completion: nil)
  }

  @objc fileprivate func closeButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }
}

extension BackingViewController: MessageDialogViewControllerDelegate {
  internal func messageDialogWantsDismissal(_ dialog: MessageDialogViewController) {
    dialog.dismiss(animated: true, completion: nil)
  }

  internal func messageDialog(_ dialog: MessageDialogViewController, postedMessage message: Message) {
  }
}
