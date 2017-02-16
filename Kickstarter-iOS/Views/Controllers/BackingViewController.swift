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
  @IBOutlet fileprivate weak var backerRewardDescriptionLabel: UILabel!
  @IBOutlet fileprivate weak var backerSequenceLabel: UILabel!
  @IBOutlet fileprivate weak var backerShippingAmountLabel: UILabel!
  @IBOutlet fileprivate weak var contentView: UIView!
  @IBOutlet fileprivate weak var dividerView: UIView!
  @IBOutlet fileprivate weak var estimatedDeliveryDateLabel: UILabel!
  @IBOutlet fileprivate weak var estimatedDeliveryLabel: UILabel!
  @IBOutlet fileprivate weak var estimatedDeliveryStackView: UIStackView!
  //@IBOutlet fileprivate weak var loadingIndicatorView: UIActivityIndicatorView!
  //@IBOutlet fileprivate weak var loadingOverlayView: UIView!
  @IBOutlet fileprivate weak var messageCreatorButton: UIButton!
  @IBOutlet fileprivate weak var pledgeCardView: UIView!
  @IBOutlet fileprivate weak var pledgeContainerView: UIView!
  @IBOutlet fileprivate weak var pledgedLabel: UILabel!
  @IBOutlet fileprivate weak var rewardCardView: UIView!
  @IBOutlet fileprivate weak var rewardContainerView: UIView!
  @IBOutlet fileprivate weak var rewardLabel: UILabel!
  @IBOutlet fileprivate weak var rewardTitleLabel: UILabel!
  @IBOutlet fileprivate weak var shippingLabel: UILabel!
  @IBOutlet fileprivate weak var statusDescriptionLabel: UILabel!
  @IBOutlet fileprivate weak var statusSubtitleLabel: UILabel!
  @IBOutlet fileprivate weak var statusTitleLabel: UILabel!
  @IBOutlet fileprivate weak var viewMessagesButton: UIButton!

  fileprivate let viewModel: BackingViewModelType = BackingViewModel()

  internal static func configuredWith(project: Project, backer: User?) -> BackingViewController {
    let vc = Storyboard.Backing.instantiate(BackingViewController.self)
    vc.viewModel.inputs.configureWith(project: project, backer: backer)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    _ = self.messageCreatorButton
      |> UIButton.lens.targets .~ [(self, #selector(messageCreatorTapped), .touchUpInside)]

    _ = self.viewMessagesButton
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

    _ = self
      |> baseControllerStyle()
      |> UIViewController.lens.title %~ { _ in Strings.project_view_button() }

    _ = self.backerNameLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 18)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    _ = self.backerSequenceLabel
      |> UILabel.lens.font .~ .ksr_subhead(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_600

    _ = self.messageCreatorButton
      |> navyButtonStyle
      |> UIButton.lens.accessibilityHint %~ {  _ in Strings.Opens_message_composer() }

    _ = self.viewMessagesButton
      |> borderButtonStyle
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.backer_modal_view_messages() }
      |> UIButton.lens.accessibilityHint %~ { _ in Strings.accessibility_dashboard_buttons_messages_hint() }

    _ = self.pledgedLabel
      |> UILabel.lens.font .~ UIFont.ksr_title3(size: 17)
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_900
      |> UILabel.lens.text %~ { _ in localizedString(key: "todo", defaultValue: "Total pledged") }

    _ = self.backerPledgeAmountAndDateLabel
      |> UILabel.lens.font .~ .ksr_title3(size: 15)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    _ = self.statusTitleLabel
      |> UILabel.lens.font .~ .ksr_caption1(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_500

    _ = self.backerRewardDescriptionLabel
      |> UILabel.lens.font .~ .ksr_title3(size: 15)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    _ = self.backerShippingAmountLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    _ = self.backerAvatarImageView
      |> UIImageView.lens.accessibilityElementsHidden .~ true

//    _ = self.loadingIndicatorView
//      |> UIActivityIndicatorView.lens.animating .~ true
//      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .white
//      |> UIActivityIndicatorView.lens.color .~ .ksr_navy_900

    _ = self.rewardLabel
      |> UILabel.lens.font .~ UIFont.ksr_title3(size: 17)
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_900
      |> UILabel.lens.text %~ { _ in localizedString(key: "todo", defaultValue: "Reward selected") }

    _ = self.dividerView |> separatorStyle

    _ = self.contentView
      |> UIView.lens.layoutMargins .~ UIEdgeInsets(top: Styles.grid(4), left: Styles.grid(2),
                                                   bottom: Styles.grid(4), right: Styles.grid(2))

    _ = self.shippingLabel
      |> UILabel.lens.font .~ .ksr_caption1(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_500
      |> UILabel.lens.text %~ { _ in localizedString(key: "todo", defaultValue: "Shipping amount:") }

    _ = self.estimatedDeliveryLabel
      |> UILabel.lens.font .~ .ksr_caption1(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_500
      |> UILabel.lens.text %~ { _ in Strings.Estimated_delivery() }

    _ = self.estimatedDeliveryDateLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    _ = self.statusDescriptionLabel
      |> UILabel.lens.font .~ .ksr_caption1(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_500

    _ = [self.pledgeCardView, self.rewardCardView]
      ||> dropShadowStyle()

    _ = [self.pledgeContainerView, self.rewardContainerView]
      ||> UIView.lens.layoutMargins .~ UIEdgeInsets(all: Styles.grid(2))
  }

  // swiftlint:disable:next function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()
    self.actionsStackView.rac.hidden = self.viewModel.outputs.hideActionsStackView
    self.actionsStackView.rac.axis = self.viewModel.outputs.rootStackViewAxis
    self.backerNameLabel.rac.text = self.viewModel.outputs.backerName
    self.backerPledgeAmountAndDateLabel.rac.text = self.viewModel.outputs.backerPledgeAmountAndDate
    self.backerPledgeAmountAndDateLabel.rac.accessibilityLabel =
      self.viewModel.outputs.backerPledgeAmountAndDateAccessibilityLabel
    self.statusSubtitleLabel.rac.text = self.viewModel.outputs.backerPledgeStatus
    self.backerRewardDescriptionLabel.rac.text = self.viewModel.outputs.backerRewardDescription
    self.backerSequenceLabel.rac.text = self.viewModel.outputs.backerSequence
    self.backerShippingAmountLabel.rac.text = self.viewModel.outputs.backerShippingAmount
    self.backerShippingAmountLabel.rac.accessibilityLabel =
      self.viewModel.outputs.backerShippingAmountAccessibilityLabel
    self.estimatedDeliveryDateLabel.rac.text = self.viewModel.outputs.estimatedDeliveryDateLabelText
    self.estimatedDeliveryStackView.rac.hidden = self.viewModel.outputs.estimatedDeliveryStackViewHidden
    self.messageCreatorButton.rac.title = self.viewModel.outputs.messageButtonTitleText
    //self.loadingOverlayView.rac.hidden = self.viewModel.outputs.loadingOverlayIsHidden

    self.viewModel.outputs.backerAvatarURL
      .observeForControllerAction()
      .on(event: { [weak backerAvatarImageView] _ in
        backerAvatarImageView?.af_cancelImageRequest()
        backerAvatarImageView?.image = nil
      })
      .skipNil()
      .observeValues { [weak backerAvatarImageView] url in
        backerAvatarImageView?.af_setImage(withURL: url)
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
